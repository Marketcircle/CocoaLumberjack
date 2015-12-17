// Software License Agreement (BSD License)
//
// Copyright (c) 2014-2015, Deusty, LLC
// All rights reserved.
//
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Neither the name of Deusty nor the names of its contributors may be used
//   to endorse or promote products derived from this software without specific
//   prior written permission of Deusty, LLC.

import Foundation
import CocoaLumberjack

extension DDLogFlag {
    public static func fromLogLevel(logLevel: DDLogLevel) -> DDLogFlag {
        return DDLogFlag(rawValue: logLevel.rawValue)
    }
	
	public init(_ logLevel: DDLogLevel) {
		self = DDLogFlag(rawValue: logLevel.rawValue)
	}
    
    ///returns the log level, or the lowest equivalant.
    public func toLogLevel() -> DDLogLevel {
        if let ourValid = DDLogLevel(rawValue: self.rawValue) {
            return ourValid
        } else {
            let logFlag = self
            if logFlag.intersect(.Verbose) == .Verbose {
                return .Verbose
            } else if logFlag.intersect(.Debug) == .Debug {
                return .Debug
            } else if logFlag.intersect(.Info) == .Info {
                return .Info
            } else if logFlag.intersect(.Warning) == .Warning {
                return .Warning
            } else if logFlag.intersect(.Error) == .Error {
                return .Error
            } else {
                return .Off
            }
        }
    }
}

public var defaultDebugLevel = DDLogLevel.Verbose

public func resetDefaultDebugLevel() {
    defaultDebugLevel = DDLogLevel.Verbose
}

public func SwiftLogMacro(isAsynchronous: Bool, level: DDLogLevel, flag flg: DDLogFlag, context: Int = 0, file: StaticString = __FILE__, function: StaticString = __FUNCTION__, line: UInt = __LINE__, tag: AnyObject? = nil, @autoclosure(escaping) string: () -> String) {
    if isAsynchronous {
        SwiftLogMacroAsync(level, flag: flg, tag: tag, string: string)
    }
    else {
        SwiftLogMacroSync(level, flag: flg, tag: tag, string: string)
    }
}

public func SwiftLogMacroSync(level: DDLogLevel, flag flg: DDLogFlag, context: Int = 0, file: StaticString = __FILE__, line: UInt = __LINE__, tag: AnyObject? = nil, @autoclosure(escaping) string: () -> String) {
    if level.rawValue & flg.rawValue != 0 {
        // Tell the DDLogMessage constructor to copy the C strings that get passed to it. 
        // Using string interpolation to prevent integer overflow warning when using StaticString.stringValue
        let logMessage = DDLogMessage(message: string(), flag: flg, context: context, tag: tag)
        DDLog.logMessage(logMessage)
    }
}

public func SwiftLogMacroAsync(level: DDLogLevel, flag flg: DDLogFlag, context: Int = 0, file: StaticString = __FILE__, function: StaticString = __FUNCTION__, line: UInt = __LINE__, tag: AnyObject? = nil, @autoclosure(escaping) string: () -> String) {
    if level.rawValue & flg.rawValue != 0 {
        // Tell the DDLogMessage constructor to copy the C strings that get passed to it.
        // Using string interpolation to prevent integer overflow warning when using StaticString.stringValue
        let logMessage = DDLogMessage(message: string(), flag: flg, context: context, tag: tag)
        DDLog.asynchronouslyLogMessage(logMessage)
    }
}

public func DDLogVerbose(@autoclosure(escaping) logText: () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, tag: AnyObject? = nil) {
    SwiftLogMacroAsync(level, flag: .Verbose, tag: tag, string: logText)
}

public func DDLogDebug(@autoclosure(escaping) logText: () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, tag: AnyObject? = nil) {
    SwiftLogMacroAsync(level, flag: .Debug, tag: tag, string: logText)
}

public func DDLogInfo(@autoclosure(escaping) logText: () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, tag: AnyObject? = nil) {
    SwiftLogMacroAsync(level, flag: .Info, tag: tag, string: logText)
}

public func DDLogWarn(@autoclosure(escaping) logText: () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, tag: AnyObject? = nil) {
    SwiftLogMacroAsync(level, flag: .Warning, tag: tag, string: logText)
}

public func DDLogError(@autoclosure(escaping) logText: () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, tag: AnyObject? = nil) {
    SwiftLogMacroSync(level, flag: .Error, tag: tag, string: logText)
}

public func DDLogCritical(@autoclosure(escaping) logText: () -> String, level: DDLogLevel = defaultDebugLevel, context: Int = 0, tag: AnyObject? = nil) {
    SwiftLogMacroSync(level, flag: .Critical, tag: tag, string: logText)
}
