#!/usr/bin/env xcrun swift
// vi: ft=swift

import Foundation
import CoreServices
import AppKit

func correctSpell(_ text: String) -> String? {
    let checker = NSSpellChecker.shared()
    let range = NSRange(location: 0, length: text.characters.count)
    return checker.correction(forWordRange:range, in:text, language:"en", inSpellDocumentWithTag:0)
}

func querySuggestion(_ query: String) -> String? {
    guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        return nil
    }
    let sess = URLSession(configuration: .default)
    let sema = DispatchSemaphore(value: 0)
    var suggestion: String?
    if let url = URL(string: "https://www.google.com/s?sclient=psy-ab&q=\(encoded)") {
        sess.dataTask(with: url) { (data, _, _) in
            defer { sema.signal() }
            do {
                guard let data = data else { return }

                let json = try? JSONSerialization.jsonObject(with: data, options: [])

                guard let array = json as? [Any], array.count > 2  else { return }
                guard let dict = array[array.endIndex - 1] as? [String: Any] else { return }
                guard var value = dict["o"] as? String else { return }

                // remove <s> prefix and </s> suffix
                value.removeSubrange(value.startIndex...value.index(value.startIndex, offsetBy: 3))
                value.removeSubrange(value.index(value.endIndex, offsetBy:-5)..<value.endIndex)

                suggestion = value
            }
        }.resume()
    }
    sema.wait()
    return suggestion
}

func getDefinition(_ text: String) -> String? {
    let range = CFRangeMake(0, (text as NSString).length)
    guard let definition = DCSCopyTextDefinition(nil, text as CFString, range) else {
        return nil
    }
    return definition.takeUnretainedValue() as String
}

func main() -> Int32 {
    let args = CommandLine.arguments

    if args.count < 2 {
        print([
            "",
            "Usage:",
            "    \(args[0]) lackadaisical",
            "    \(args[0]) lazy susan",
            ""
        ].joined(separator: "\n"))
        return 0
    }

    let word = args[1...(args.count - 1)].joined(separator: " ")

    if let d = getDefinition(word) {
        print(d)
        return 0
    }

    if let corrected = correctSpell(word) {
        if let d = getDefinition(corrected) {
            print("Did you mean: \(corrected) (by NSSpellChecker)")
            print(d)
            return 0
        }
    }

    if let suggestion = querySuggestion(word) {
        if let d = getDefinition(suggestion) {
            print("Did you mean: \(suggestion) (by Google Suggestion)")
            print(d)
            return 0
        }
    }

    print("No entries found")
    return 1
}

exit(main())
