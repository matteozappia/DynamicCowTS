//
//  DynamicBackup.swift
//  DynamicCowTS
//
//  Created by zeph on 02/12/23.
//

import SwiftUI

struct DynamicBackup {
    static func performDynamicBackup() {
        do {
            let dynamicPath = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
            let resPath = "/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist"
            let backupFolder = "/var/mobile/Documents/.DynamicCowBackups/"
            
            try createBackup(for: dynamicPath, in: backupFolder)
            try createBackup(for: resPath, in: backupFolder)
        } catch {
            print("Error: \(error)")
        }
    }

    private static func createBackup(for filePath: String, in backupFolder: String) throws {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: filePath) else {
            print("File not found at path: \(filePath)")
            return
        }
        
        if !fileManager.fileExists(atPath: backupFolder) {
            try fileManager.createDirectory(atPath: backupFolder, withIntermediateDirectories: true, attributes: nil)
        }
        
        let fileName = (filePath as NSString).lastPathComponent
        let backupFilePath = (backupFolder as NSString).appendingPathComponent(fileName)
        
        try fileManager.copyItem(atPath: filePath, toPath: backupFilePath)
        
        print("Backup created for \(fileName) at \(backupFilePath)")
    }
}
