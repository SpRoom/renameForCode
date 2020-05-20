//
//  FileController.swift
//  renameForCode
//
//  Created by ios-spec on 2018/12/25.
//  Copyright © 2018 zsh. All rights reserved.
//

import Foundation
import FileKit

final class FileController {

    public static let shared = FileController()
    private init() {}


    let manager = FileManager.default


    typealias callBack = (Bool)->()

    var resultNoti: callBack?
}

// public static function
extension FileController {

    /// 修改文件名 以及 类名； 不包括文件夹名
    func start(projectPathStr: String, prefixStr: String, newPrefixStr: String, pathExtensionsStr: String) {

        let pathExtensions = pathExtensionsStr.components(separatedBy: ",")
        let dirPath = Path(projectPathStr)^

        let paths = dirPath.find { (path) -> Bool in
            pathExtensions.contains(path.pathExtension)
        }
        
        guard !paths.isEmpty else {
            resultNoti?(true)
            return
        }
        
        runOnBackground {
            
        

        let infos = paths.map { (path)  -> FileInfo in
            let newName = path.replaceFileNamePrefix(of: prefixStr, with: newPrefixStr, containExtension: false)
            let newFileName = path.replaceFileNamePrefix(of: prefixStr, with: newPrefixStr, containExtension: true)
            return FileInfo(name: path.name, dir: path^.rawValue, fileName: path.fileName, pathExtension: path.pathExtension, path: path, newName: newName, newFileName: newFileName)
        }

        let manager = FileController.shared


        for path in paths {
//            for info in infos {
//                manager.replaceTextFile(dir: path^.rawValue, file: path.fileName, oldValue: info.name, newValue: info.newName)
//            }
            manager.replaceTextFile(dir: path^.rawValue, file: path.fileName, infos: infos)
        }

        for info in infos {

            manager.changeTextFileName(dir: info.dir, fileName: info.fileName, newName: info.newFileName)
        }

            self.fixXocdeConfig(infos: infos, rootDir: dirPath)
            
        }
    }


    private func fixXocdeConfig(infos: [FileInfo], rootDir: Path) {

        let configPaths = rootDir.find { (path) -> Bool in
            path.pathExtension == "pbxproj" && path.name == "project"
        }

        guard !configPaths.isEmpty else {
            return
        }
        let configPath = configPaths[0]
//        print(configPath)


        for info in infos {

            FileController.shared.replaceTextFile(dir: configPath^.rawValue, file: configPath.fileName, oldValue: info.name, newValue: info.newName)

        }

        resultNoti?(true)

    }

}

extension FileController {
    
    func replaceTextFile(dir: String, file name: String, infos: [FileInfo]) {
        
        let dirPath = Path(dir)
        let filePath = dirPath + name
        
        guard filePath.exists else {
            resultNoti?(true)
            return
        }
        
        if filePath.isReadable && filePath.isWritable {
            
            do {
                
                let file = TextFile(path: filePath, encoding: .utf8)
                let content = try file.read()
                var new = content
                
                for info in infos {
//                let splitArray = content.components(separatedBy: info.name)
//                 new = splitArray.joined(separator: info.newName)
                    
                 new = new.replacingOccurrences(of: info.name, with: info.newName)
                }
//                print(content)
//                print(new)
                
                try file.write(new, atomically: true)
                
            } catch let e as FileKitError {
                fileKitErrorHandler(error: e)
            } catch let err {
                print(err)
            }
            
        } else {
            print("this file is can not read or write")
        }
    }

    /// 替换文本 区分大小写 
    func replaceTextFile(dir: String, file name: String, oldValue: String, newValue: String) {

        let dirPath = Path(dir)
        let filePath = dirPath + name

        guard filePath.exists else {
            return
        }

        if filePath.isReadable && filePath.isWritable {

            do {

                let file = TextFile(path: filePath, encoding: .utf8)
                let content = try file.read()

               let splitArray = content.components(separatedBy: oldValue)
            let new = splitArray.joined(separator: newValue)

//                print(content)
//                print(new)

                try file.write(new, atomically: true)

            } catch let e as FileKitError {
                fileKitErrorHandler(error: e)
            } catch let err {
                print(err)
            }

        } else {
            print("this file is can not read or write")
        }
    }

    func changeTextFileName(dir: String, fileName: String, newName: String) {

        let dirPath = Path(dir)

        let filePath = dirPath + fileName
        let newPath = dirPath + newName

        let file = TextFile(path: filePath, encoding: .utf8)

        guard file.exists else {
            return
        }

        guard !newPath.exists else {
            return
        }
//        let file = File(path: filePath)
//        file.move(to: newPath)
        do {
        try filePath.moveFile(to: newPath)
        } catch let e as FileKitError {
            fileKitErrorHandler(error: e)
        } catch let err {
            print(err)
        }
    }

}



extension FileController {

    /// 写入结果错误 此处暂时只用于创建
    func textFile(path: String, content: String = "", right: Bool = true) {
        guard !path.isEmpty else {
            return
        }

        let allPath = Path(path)
        let file = TextFile(path: allPath)

        if !file.exists {

        do {
            try file.create()
        } catch let e as FileKitError {
            fileKitErrorHandler(error: e)
        } catch let err {
            print(err)
        }
        }

        // 写入结果错误 此处暂时只用于创建
        guard !content.isEmpty else {
            return
        }

        do {

        if !right {
            try content |> file
        } else {
            try content |>> file
        }

        } catch let e as FileKitError {
            fileKitErrorHandler(error: e)
        } catch let err {
            print(err)
        }
    }

    func dictionaryFile(path: String) {

        guard !path.isEmpty else {
            return
        }

        let allPath = Path(path)
        let plistFile = File<Dictionary<String, Any>>(path: allPath)
        do {
            try plistFile.create()
        } catch let e as FileKitError {
            fileKitErrorHandler(error: e)
        } catch let err {
            print(err)
        }
    }

    func deleFile(path: String? = nil) {

        if let path = path {
            deleteFile(path: path)
        }
    }


    private func deleteFile(path: String? = nil) {
        guard let path = path, !path.isEmpty else {
            return
        }

        let allPath = Path(path)

        if allPath.exists {
            do {
            try allPath.deleteFile()
            } catch let e as FileKitError {
            fileKitErrorHandler(error: e)
            } catch let err {
            print(err)
            }
        }

    }


    func createFile(path: String? = nil) {

        if let path = path {

          newFile(path: path)

        }
    }

    private func newFile(path: String? = nil) {

        guard let path = path, !path.isEmpty else {
            return
        }

        let allPath = Path(path)

        let dirPath = allPath^

        if !dirPath.exists {
            do {
           try dirPath.createDirectory(withIntermediateDirectories: true)
            } catch let e as FileKitError {
                fileKitErrorHandler(error: e)
            } catch let err {
                print(err)
            }
        }


        do {
            try Path(path).createFile()
        } catch let e as FileKitError {
            fileKitErrorHandler(error: e)
        } catch let err {
            print(err)
        }

    }

    func fileKitErrorHandler(error: FileKitError, path: String? = nil) {

        resultNoti?(false)

        switch error {
        case .fileDoesNotExist(path: let path):
            print("file dose not exist, path -- \(path.rawValue)")
        case .fileAlreadyExists(path: let path):
            print("file already exists, path -- \(path.rawValue)")
        case .changeDirectoryFail(from: let from, to: let to, error: let e):
            print("change dir failed, from -- \(from.rawValue) to -- \(to.rawValue), reason is -- \(e.localizedDescription)")
        case .createSymlinkFail(from: let from, to: let to, error: let e):
            print("create syslink failed, from -- \(from.rawValue) to -- \(to.rawValue), reason is -- \(e.localizedDescription)")
        case .createHardlinkFail(from: let from, to: let to, error: let e):
            print("create hardlink failed, from -- \(from.rawValue) to -- \(to.rawValue), reason is -- \(e.localizedDescription)")
        case .createFileFail(path: let path):
            print("create file failed, path -- \(path.rawValue)")
        case .createDirectoryFail(path: let path, error: let e):
            print("create dir failed, path -- \(path.rawValue), reason is -- \(e.localizedDescription)")
        case .deleteFileFail(path: let path, error: let e):
            print("delete file failed, path -- \(path.rawValue), reason is -- \(e.localizedDescription)")
        case .readFromFileFail(path: let path, error: let e):
            print("read file failed, path -- \(path.rawValue), reason is -- \(e.localizedDescription)")
        case .writeToFileFail(path: let path, error: let e):
            print("write file failed, path -- \(path.rawValue), reason is -- \(e.localizedDescription)")
        case .moveFileFail(from: let from, to: let to, error: let e):
            print("move file failed, from -- \(from.rawValue) to -- \(to.rawValue), reason is -- \(e.localizedDescription)")
        case .copyFileFail(from: let from, to: let to, error: let e):
            print("copy file failed, from -- \(from.rawValue) to -- \(to.rawValue), reason is -- \(e.localizedDescription)")
        case .attributesChangeFail(path: let path, error: let e):
            print("change file failed, path -- \(path.rawValue), reason is -- \(e.localizedDescription)")

        }

    }

}
