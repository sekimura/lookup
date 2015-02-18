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
    let escaped = query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    let url = NSURL(string:"https://www.google.com/s?sclient=psy-ab&q=\(escaped)")!
    let req = NSURLRequest(URL:url)

    var error: NSError?
    var res: NSURLResponse?
    if let data =  NSURLConnection.sendSynchronousRequest(req, returningResponse:&res, error:&error) {
        if error != nil {
            return nil
        }

        if let json = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments, error:&error) as? NSArray {
            if error != nil {
                return nil
            }

            if (json.count > 2) {
                let idx = json.count - 1
                if let dict = json[idx] as? NSDictionary {
                    if let suggestion = dict.objectForKey("o") as? String {
                        return suggestion
                            .stringByReplacingOccurrencesOfString("<sc>", withString:"", options:NSStringCompareOptions.LiteralSearch)
                            .stringByReplacingOccurrencesOfString("</sc>", withString:"", options:NSStringCompareOptions.LiteralSearch)
                    }
                }
            }
        }
    }
    return nil
}

func getDefinition(textString : String) -> String? {
    let range : CFRange = CFRangeMake(0, countElements(textString))
    return DCSCopyTextDefinition(nil, textString, range)?.takeRetainedValue()
}

func main() {
    let args = [String](Process.arguments)

    if args.count < 2 {
        println("\n".join([
            "",
            "Usage:",
            "    \(args[0]) lackadaisical",
            "    \(args[0]) lazy susan",
            "",
        ]))
        return
    }

    var word = " ".join(args[1...(args.count - 1)])

    if let d = getDefinition(word) {
        println(d)
        return
    }

    if let corrected = correctSpell(word) {
        if let d = getDefinition(corrected) {
            println("Did you mean: \(corrected)")
            println(d)
            return
        }
    }

    if let suggestion = querySuggestion(word) {
        if let d = getDefinition(suggestion) {
            println("Did you mean: \(suggestion)")
            println(d)
            return
        }
    }

    println("No entries found")
}

main()
