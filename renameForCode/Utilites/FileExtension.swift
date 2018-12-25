//
//  FileExtension.swift
//  renameForCode
//
//  Created by ios-spec on 2018/12/25.
//  Copyright © 2018 zsh. All rights reserved.
//

import Foundation
import FileKit

extension Path {

    var name: String {

        let name = fileName.components(separatedBy: ".")

        return name[0]
    }

    /// replace file name , default filename not contain pathExtension
    func replaceFileNamePrefix(of: String, with: String, containExtension contain: Bool = false) -> String {

        if contain {
            return fileName.replacingOccurrences(of: of, with: with)
        } else {
            return name.replacingOccurrences(of: of, with: with)
        }
    }


}
