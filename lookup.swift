#!/usr/bin/env xcrun swift
// vi: ft=swift

import Foundation
import CoreServices
import AppKit


func correct_spell(textString : String) -> String? {
    let checker = NSSpellChecker.sharedSpellChecker()
    let range = NSMakeRange(0, (textString as NSString).length)
    let corrected : NSString? = checker.correctionForWordRange(range, inString:textString, language:"en", inSpellDocumentWithTag:0);
    if corrected != nil {
      return corrected as String?
    }
    return nil
}

func query_suggestion(query : String) -> String? {
    let escaped = query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    let url = NSURL(string:"https://www.google.com/s?sclient=psy-ab&q=\(escaped)")!
    let req = NSURLRequest(URL:url)

    var error: NSError?
    var res: NSURLResponse?
    let data: NSData? =  NSURLConnection.sendSynchronousRequest(req, returningResponse:&res, error:&error)

    if error != nil {
      return nil
    }

    let json: NSArray = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments, error:&error) as NSArray
    if error != nil {
      return nil
    }

    if (json.count > 2) {
      let idx = json.count - 1
      let dict = json[idx] as NSDictionary
      var hint: String? = dict.objectForKey("o") as String?
      if hint == nil {
          return nil
      }
      hint = hint!.stringByReplacingOccurrencesOfString("<sc>", withString:"", options:NSStringCompareOptions.LiteralSearch)
      hint = hint!.stringByReplacingOccurrencesOfString("</sc>", withString:"", options:NSStringCompareOptions.LiteralSearch)
      return hint
    } else {
      return nil
    }
}

func get_definition(textString : String) -> String? {
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

  let word = " ".join(args[1...(args.count - 1)])

  var result: String? = get_definition(word)
  if result != nil {
    println(result!)
    return
  }

  let corrected = correct_spell(word)
  if corrected != nil {
    result = get_definition(corrected!)
    if result != nil {
      println("Did you mean: \(corrected!)")
      println(result!)
      return
    }
  }

  let suggestion: String? = query_suggestion(word)
  if suggestion != nil {
    result = get_definition(suggestion!)
    if result != nil {
      println("Did you mean: \(suggestion!)")
      println(result!)
      return
    }
  }

  println("No entries found")

}

main()