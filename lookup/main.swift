//
//  main.swift
//  lookup
//
//  Created by Masayoshi Sekimura on 2/8/15.
//  Copyright (c) 2015 sekimura.org. All rights reserved.
//

import Foundation
import CoreServices

func main() {
  let args = [String](Process.arguments)

  if args.count > 1 {
    var word : String = args[1]
    var range : CFRange =  CFRangeMake(0, (word as NSString).length)
    var result : String? = DCSCopyTextDefinition(nil, word, range)?.takeRetainedValue()
    if result == nil {
      println("No entries found")
      return
    }
    println(result!)
  }

}

main()