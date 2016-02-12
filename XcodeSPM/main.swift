//
//  main.swift
//  XcodeSPM
//
//  Created by Francescu Santoni on 27/01/16.
//  Copyright © 2016 Francescu. All rights reserved.
//

import Foundation


let env = NSProcessInfo.processInfo().environment

let libsPath = env["XPM_LIBS"] ?? "./Libs/"

func buildPath(configuration: String) -> String {
    let buildPath = env["XPM_BUILD"] ?? "./.build/"
    return (buildPath as NSString).stringByAppendingPathComponent(configuration)
}

let nsLibs = libsPath as NSString

let fileManager = NSFileManager.defaultManager()

enum Command {
    case Build(configuration: String)
    case Open
    case Clean
    case Help
    case Error(String)
    
    //Private
    case SPM(configuration: String)
    
    init(buildArguments: [String]) {
        if buildArguments.count < 2 {
            self = .Build(configuration: "debug")
            return
        }
        
        guard let arg = buildArguments.first where arg == "-c" || arg == "--configuration" else {
            self = .Build(configuration: "debug")
            return
        }
        
        self = .Build(configuration: buildArguments[1])
    }
    
    init(arguments: [String] = Process.arguments) {
        if arguments.count <= 1 {
            self = Command(buildArguments: [])
            return
        }
        
        let command = arguments[1]
        
        switch command {
        case "build":
            var args = arguments
            args.removeFirst(2)
            self = Command(buildArguments: args)
        case "open":
            self = .Open
        case "clean":
            self = .Clean
        case "help":
            self = .Help
        default:
            self = .Error(command)
        }
        
    }
    
    func execute() {
        switch self {
        case .Build(let configuration):
            do {
                if fileManager.fileExistsAtPath(libsPath) == true {
                    try fileManager.removeItemAtPath(libsPath)
                }
                try fileManager.createDirectoryAtPath(libsPath, withIntermediateDirectories: true, attributes: nil)
                
                let build = buildPath(configuration)
                let nsBuild = build as NSString
                
                let files = try fileManager.contentsOfDirectoryAtPath(build)
                
                
                try files.filter { $0.hasSuffix(".a") }
                    .map { (nsBuild.stringByAppendingPathComponent($0), nsLibs.stringByAppendingPathComponent("lib" + $0)) }
                    .forEach {
                        print("\($0.0) -> \($0.1)")
                        try fileManager.copyItemAtPath($0.0, toPath: $0.1)
                    }
            }
            catch {
                print("Error : \(error)")
            }
            
        case .Clean:
            print("swift build --clean")
            let task = NSTask()
            task.launchPath = "/bin/sh"
            task.arguments = ["-c", "swift build --clean"]
            task.launch()
            
            if fileManager.fileExistsAtPath(libsPath) {
                _ = try? fileManager.removeItemAtPath(libsPath)
                print("removed \(libsPath)")
            }
            
            if fileManager.fileExistsAtPath("./Packages") {
                _ = try? fileManager.removeItemAtPath("./Packages")
                print("removed ./Packages")
            }
            
        case .Open:
            let task = NSTask()
            task.launchPath = "/usr/bin/open"
            task.arguments = [libsPath]
            task.launch()
            
        case .Error(let command):
            print("Error \(command) doesn't exists")
            Command.Help.execute()
            
        case .SPM(let configuration):
            print("swift build")
            let task = NSTask()
            task.launchPath = "/bin/sh"
            task.arguments = ["-c", "swift build --configuration \(configuration)"]
            task.launch()
            
        default:
            print("Not implemented yet")
        }
    }
}

let command = Command()
command.execute()




