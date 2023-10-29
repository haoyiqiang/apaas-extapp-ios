//
//  AgoraWidgetCommonModels.swift
//  AgoraWidgets
//
//  Created by Cavan on 2023/2/10.
//

import Foundation

struct FcrCloudDriveFile: Convertable {
    let resourceUuid: String
    let resourceName: String
    // 资源父级Uuid (当前文件/文件夹的父级目录的resouceUuid，如果当前目录为根目录则为root)
    let parentResourceUuid: String = "root"
    // 文件/文件夹 (如果是文件则为1，如果是文件夹则为0)
    let type: Int = 1
    // 文件大小
    let size: Int64
    // 文件路径
    let url: String
    // 更新时间
    let updateTime: Int64
    // tag列表
    let tags: [String]?
    // 扩展名
    let ext: String
    // 版本3/4（区分v3/v4）
    var version: Int? = 3
    
    // 【需要转换的文件才有】文件转换状态（未转换（0），转换中（1），转换完成（2））
    let convertType: Int?
    // 【需要转换的文件才有】
    let taskUuid: String?
    // 【需要转换的文件才有】
    let taskToken: String?
    // 【需要转换的文件才有】
    let taskProgress: TaskProgress?
    // 【需要转换的文件才有】需要转换的文件才有
    let conversion: Conversion?
}

extension FcrCloudDriveFile {
    struct TaskProgress: Convertable {
        // task 状态，枚举：Waiting, Converting, Finished, Fail （v3/v4）
        // let status: String?
        // 转换文档总页数（v3）
        // let totalPageSize: Int?
        // 已经转换完成的页数（v3）
        // let convertedPageSize: Int?
        // 转换进度百分比（v3/v4）
        let convertedPercentage: Int
        // 当前转换任务步骤，只有 type == dynamic 时才有该字段（v3）
        // let currentStep: String?
        // 转换结果文件地址前缀路径（v3/v4）
        let prefix: String?
        // 文档页数，当文件转换失败时没有该字段（v3/v4）
        // let pageCount: Int?
        // 转换文档详情（key：索引,value：url）（v4）
        // let previews: [String: String]?
        // 文档提取出的备注内容，只包含有备注的页面（v4）
        // let note: String?
        // 错误码，当任务转换失败时会存在（v4）
        let errorCode: String?
        // 错误，当任务转换失败时会存在（v4）
        // let errorMessage: String?

        // 转换结果列表（v3）
        let convertedFileList: [TaskProgressConvertedFile]?
        // 转换结果列表（v4）
        let images: [String: TaskProgressImage]?
    }
    
    struct Conversion: Convertable {
        // 动态dynamic，静态static
        let type: String
        let preview: Bool
        // 图片缩放比例
//        let scale: Float
        let canvasVersion: Bool?
        // 输出图片格式
        let outputFormat: String
    }
}

extension FcrCloudDriveFile.TaskProgress {
    // Converted V3
    struct TaskProgressConvertedFile: Convertable {
        var name: String
        var ppt: TaskProgressConvertedFilePptPage
    }
    
    struct TaskProgressConvertedFilePptPage: Convertable {
        /// 图片的 URL 地址。
        var src: String
        /// 图片的 URL 宽度。单位为像素。
        var width: Float
        /// 图片的 URL 高度。单位为像素。
        var height: Float
        /// 预览图片的 URL 地址
        var preview: String?
    }
    
    // Converted V4
    struct TaskProgressImage: Convertable {
        // 宽度
        let width: Float
        // 高度
        let height: Float
        // 地址
        let url: String
    }
}
