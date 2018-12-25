//
//  ShareUtilityMethods.swift
//  renameForCode
//
//  Created by spectator Mr.Z on 2018/12/25.
//  Copyright © 2018 zsh. All rights reserved.
//

import Foundation
import Cocoa

func runOnBackground(_ task: @escaping () -> Void)
{
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
        task();
    }
}

func runOnUiThread(_ task: @escaping () -> Void)
{
    DispatchQueue.main.async(execute: { () -> Void in
        task();
    })
}
