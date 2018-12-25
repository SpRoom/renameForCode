//
//  FileInfo.swift
//  renameForCode
//
//  Created by ios-spec on 2018/12/25.
//  Copyright © 2018 zsh. All rights reserved.
//

import Foundation
import FileKit

struct FileInfo {
    var name: String
    var dir: String
    var fileName: String
    var pathExtension: String
    var path: Path
    var newName: String
    var newFileName: String
}
