//
//  DataModel.swift
//  CVI
//
//  Created by ted on 5/3/16.
//  Copyright © 2016 CItyUAppsLab. All rights reserved.
//

import Foundation



enum AdditiveDict: String {
    
    case additive_name = "additive_name"
    case additive_cn_desc = "additive_cn_desc"
    case additive_eng_desc = "additive_eng_desc"
    case additive_desc = "additive_desc"
    case additive_id = "additive_id"
}

typealias Bookmark = (
    bookmarkId: Int64?,
    additiveId: Int64?
)


typealias Industry = (
    type_id: Int64?,
    type_name_cn: String?,
    type_name_eng: String?,
    parent_type_id: Int64?,
    super_type_id: Int64?
)

typealias Additive = (
    additive_id: Int64?,
    additive_name: String?,
    additive_cn_desc: String?,
    additive_eng_desc: String?
)
