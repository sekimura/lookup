#!/usr/bin/env xcrun swift
// vi: ft=swift

import Foundation
import CoreServices
import AppKit


func correctSpell(textString : String) -> String? {
    let checker = NSSpellChecker.sharedSpellChecker()
    let range = NSMakeRange(0, (textString as NSString).length)
    let corrected = checker.correctionForWordRange(range, inString:textString, language:"en", inSpellDocumentWithTag:0)
    return corrected
}

func querySuggestion(query : String) -> String? {
    let escaped = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    let url = NSURL(string:"https://www.google.com/s?sclient=psy-ab&q=\(escaped)")!
    let request = NSURLRequest(URL:url)

    let semaphore = dispatch_semaphore_create(0)
    let session = NSURLSession.sharedSession()
    var suggestion: String?
    let task = session.dataTaskWithRequest(request) {
        (data, response, error) -> Void in

        defer { dispatch_semaphore_signal(semaphore) }

        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!,
                options: NSJSONReadingOptions.MutableContainers) as! NSArray
            if (json.count > 2) {
                let idx = json.count - 1
                guard let dict = json[idx] as? NSDictionary else { return }
                guard let suggestionObject = dict.objectForKey("o") as? String else { return }
                suggestion = suggestionObject
                    .stringByReplacingOccurrencesOfString("<sc>", withString:"", options:NSStringCompareOptions.LiteralSearch)
                    .stringByReplacingOccurrencesOfString("</sc>", withString:"", options:NSStringCompareOptions.LiteralSearch)
            }
        } catch {}
    }
    task.resume()
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    return suggestion
}

func getDefinition(textString : String) -> String? {
    let range : CFRange = CFRangeMake(0, textString.utf16.count)
    if let definition = DCSCopyTextDefinition(nil, textString, range) {
        return definition.takeUnretainedValue() as String
    }
    return nil
}

func main() {
    let args = [String](Process.arguments)

    if args.count < 2 {
        print([
            "",
            "Usage:",
            "    \(args[0]) lackadaisical",
            "    \(args[0]) lazy susan",
            "",
        ].joinWithSeparator("\n"))
        exit(0)
    }

    let word = args[1...(args.count - 1)].joinWithSeparator(" ")

    if let d = getDefinition(word) {
        print(d)
        exit(0)
    }

    if let corrected = correctSpell(word) {
        if let d = getDefinition(corrected) {
            print("Did you mean: \(corrected) (by NSSpellChecker)")
            print(d)
            exit(0)
        }
    }

    if let suggestion = querySuggestion(word) {
        if let d = getDefinition(suggestion) {
            print("Did you mean: \(suggestion) (by Google Suggestion)")
            print(d)
            exit(0)
        }
    }


    print("No entries found")
    exit(1)
}

main()
