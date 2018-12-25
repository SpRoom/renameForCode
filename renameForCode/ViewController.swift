//
//  ViewController.swift
//  renameForCode
//
//  Created by zyt on 2018/12/24.
//  Copyright © 2018 zsh. All rights reserved.
//

import Cocoa
import FileKit

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        projectPathField.stringValue = "/Users/zyt/Desktop/123/412/test/AHSample1.swift"
        modifyPrefixField.stringValue = "AH"
        newPrefixField.stringValue = "LB"
        extensionArrayField.stringValue = "txt"
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    @IBOutlet weak var projectPathField: NSTextField!

    @IBOutlet weak var modifyPrefixField: NSTextField!

    @IBOutlet weak var extensionArrayField: NSTextField!

    @IBOutlet weak var newPrefixField: NSTextField!


    @IBAction func startChange(_ sender: Any) {
/*
        let manager = FileController.shared

        let desktop = "/Users/zyt/Desktop/"

        let dirPath = desktop+"123/412/test/"

        let fileName = "sample.txt"
        let fileName1 = "sample1.txt"

        let filePath = dirPath+"pp.txt"
        let filePath1 = dirPath+"sample.txt"

//        manager.createFile(path: filePath)
//        manager.deleFile(path: filePath)

//        manager.textFile(path: filePath1)
//        manager.changeFileName(dir: dirPath, fileName: fileName, newName: fileName1)
//        manager.replaceTextFile(dir: dirPath, file: fileName1, oldValue: "replace", newValue: "")
*/
        let projectPathStr = projectPathField.stringValue
        let prefixStr = modifyPrefixField.stringValue
        let pathExtensionsStr = extensionArrayField.stringValue
        let newPrefixStr = newPrefixField.stringValue

        guard !projectPathStr.isEmpty else {
            print("path is empty")
            return
        }
        guard !prefixStr.isEmpty else {
            print("prefix is empty")
            return
        }
        guard !pathExtensionsStr.isEmpty else {
            print("pathExtensin is empty")
            return
        }
        guard !newPrefixStr.isEmpty else {
            print("new prefix is empty")
            return
        }

        start(projectPathStr: projectPathStr, prefixStr: prefixStr, newPrefixStr: newPrefixStr, pathExtensionsStr: pathExtensionsStr)


    }
    
}

extension ViewController {

    func start(projectPathStr: String, prefixStr: String, newPrefixStr: String, pathExtensionsStr: String) {

        let pathExtensions = pathExtensionsStr.components(separatedBy: ",")
        let dirPath = Path(projectPathStr)^

       let paths = dirPath.find { (path) -> Bool in
            pathExtensions.contains(path.pathExtension)
        }

        for path in paths {
            print(path)
           let str = path.fileName.replacingOccurrences(of: prefixStr, with: newPrefixStr)
            print(str)

        }

        let infos = paths.map { (path)  -> FileInfo in
            let newName = path.replaceFileNamePrefix(of: prefixStr, with: newPrefixStr, containExtension: false)
            let newFileName = path.replaceFileNamePrefix(of: prefixStr, with: newPrefixStr, containExtension: true)
            return FileInfo(name: path.name, dir: path^.rawValue, fileName: path.fileName, pathExtension: path.pathExtension, path: path, newName: newName, newFileName: newFileName)
        }

        let manager = FileController.shared


        for path in paths {
            for info in infos {
                manager.replaceTextFile(dir: path^.rawValue, file: path.fileName, oldValue: info.name, newValue: info.newName)
            }
        }

        for info in infos {

            manager.changeTextFileName(dir: info.dir, fileName: info.fileName, newName: info.newFileName)
        }

        fixXocdeConfig(infos: infos, rootDir: dirPath)
    }


    func fixXocdeConfig(infos: [FileInfo], rootDir: Path) {

        let configPaths = rootDir.find { (path) -> Bool in
            path.pathExtension == "pbxproj" && path.name == "project"
        }

        guard !configPaths.isEmpty else {
            return
        }
        let configPath = configPaths[0]
        print(configPath)


        for info in infos {

            FileController.shared.replaceTextFile(dir: configPath^.rawValue, file: configPath.fileName, oldValue: info.name, newValue: info.newName)

        }

    }
    
}





