//
//  NSLog.swift
//  Meme Weather
//
//  Created by Kang-hee cho on 4/17/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import Foundation

public func NSLog(_ format: String, _ args: CVarArg...) {
    let message = String(format: format, arguments:args)
    print(message);
    TFLogv(message, getVaList([]))
}
