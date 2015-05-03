//
//  SettingsController.swift
//  StackTray
//
//  Created by Remco on 03/05/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Foundation
import Cocoa

public class Settings: NSObject, NSCoding {
  /** Meta Data */
  public var terminal: String = "Default terminal"
 
  public override init(){
    super.init()
  }

  required public init(coder aDecoder: NSCoder) {
    if let terminal = aDecoder.decodeObjectForKey("terminal") as? String {
      self.terminal = terminal
    }
  
    super.init()
  }
  
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(terminal, forKey: "terminal")
  }
}

public class SettingsController: NSObject {
  private var settingsFile: String

  let fileManager = NSFileManager.defaultManager()

  public init(rootURL: String){
    self.settingsFile = rootURL.stringByAppendingPathComponent("settings.bin")
    
    super.init()
    
    var isDir : ObjCBool = false
    if !fileManager.fileExistsAtPath(rootURL, isDirectory: &isDir) {
      fileManager.createDirectoryAtPath(rootURL, withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    
    load()
  }
  
  public private(set) var settings : Settings = Settings() {
    didSet{
    }
  }
  
  public func save() {
    if !NSKeyedArchiver.archiveRootObject(settings, toFile: settingsFile){
      println("Unable to archive to \(settingsFile)")
    }
  }
  
  public func load() {
    if fileManager.fileExistsAtPath(self.settingsFile){
      if let settings = NSKeyedUnarchiver.unarchiveObjectWithFile(settingsFile) as? Settings {
        self.settings = settings
      }
    }
  }
}