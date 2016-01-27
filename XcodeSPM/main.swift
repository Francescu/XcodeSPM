//
//  main.swift
//  XcodeSPM
//
//  Created by Francescu Santoni on 27/01/16.
//  Copyright © 2016 Francescu. All rights reserved.
//

import Foundation

print("Hello, World!")

let env = NSProcessInfo.processInfo().environment

let buildPath = "../.build/debug/"
let libPath = "./Libs/"

do {
    let fileManager = NSFileManager.defaultManager()
    
    // Clean lib directory
    if fileManager.fileExistsAtPath(libPath) {
        try fileManager.removeItemAtPath(libPath)
    }
    try fileManager.createDirectoryAtPath(libPath, withIntermediateDirectories: true, attributes: nil)
    
    let files = try fileManager.contentsOfDirectoryAtPath(buildPath)
    
    try files.filter { $0.hasSuffix(".a") }
        .map { ((buildPath as NSString).stringByAppendingPathComponent($0), (libPath as NSString).stringByAppendingPathComponent("lib" + $0)) }
        .forEach { try fileManager.copyItemAtPath($0.0, toPath: $0.1)}

}
catch let error as NSError {
    print("Error : \(error.localizedDescription)")
}