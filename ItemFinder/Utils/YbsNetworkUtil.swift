//
//  YbsNetworkUtil.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/8.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias AFSNetSuccessBlock = (JSON) -> Void;
typealias AFSNetFaliedBlock = (AFSErrorInfo) -> Void;
typealias AFSProgressBlock = (Double) -> Void;

class YbsNetworkUtil: NSObject {
    static let share = YbsNetworkUtil()
    
    // 这是变量的初始化，不是get方法，所以获取的manager是一样的
    private var manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        let defaultHeaders = SessionManager.defaultHTTPHeaders
        configuration.httpAdditionalHeaders = defaultHeaders
        configuration.timeoutIntervalForRequest = 10
        let manager = SessionManager(configuration: configuration)
        
        return manager
    }()
    
    // GET请求
    func get(url:String, parameters: Parameters?, successBlock:@escaping AFSNetSuccessBlock, faliedBlock:@escaping AFSNetFaliedBlock){
        let headers: HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        self.manager.request(url, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                self.handleResponse(response: response, successBlock: successBlock, faliedBlock: faliedBlock)
        });
        
    }
    
    // POST请求
    func post(url: String, parameters: Parameters?, successBlock: @escaping AFSNetSuccessBlock,faliedBlock: @escaping AFSNetFaliedBlock){
        let headers : HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        
        /*
         1. 这里参数encoding的值为JSONEncoding.default，
            相当于AFNetworking里的manager.requestSerializer = [AFJSONRequestSerializer serializer];
         2. responseJSON 相当于AFNetworking里的manager.responseSerializer = [AFJSONResponseSerializer serializer];
         
         都可以根据具体需求设置，比如encoding可以设置为URLEncoding.httpBody或PropertyListEncoding.xml等
         */
        self.manager.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
            self.handleResponse(response: response, successBlock: successBlock, faliedBlock: faliedBlock)

        })
        
        
    }
    
    // PUT请求
    func put(url: String, parameters: Parameters?, successBlock: @escaping AFSNetSuccessBlock,faliedBlock: @escaping AFSNetFaliedBlock){
        let headers : HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        manager.request(url, method: HTTPMethod.put, parameters: parameters, encoding: URLEncoding.queryString, headers: headers).validate().responseJSON(completionHandler: { (response) in
            self.handleResponse(response: response, successBlock: successBlock, faliedBlock: faliedBlock)
            
        })
        
        
    }
    
    

    // 上传图片
    func postImage(image: UIImage, url: String, param: Parameters?, progressBlock: @escaping AFSProgressBlock, successBlock: @escaping AFSNetSuccessBlock, faliedBlock: @escaping AFSNetFaliedBlock){
        let imageData = image.jpegData(compressionQuality: 0.5)
        let headers = ["content-type":"multipart/form-data"]
        // 默认60s超时
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            /** 采用post表单上传,参数解释：
             *  withName:和后台服务器的name要一致;
             *  fileName:可以充分利用写成用户的id，但是格式要写对;
             *  mimeType：规定的，要上传其他格式可以自行百度查一下
             */
            let data = imageData != nil ? imageData! : Data()
            multipartFormData.append(data, withName: "file", fileName: "img.png", mimeType: "image/png")
            //如果需要上传多个文件,就多添加几个
            //multipartFormData.append(imageData, withName: "file", fileName: "123456.jpg", mimeType: "image/jpeg")
            
        },to: url,headers: headers,encodingCompletion: { encodingResult in
            switch encodingResult {
                case .success(let upload, _, _):
                    //获取上传进度
                    upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                             progressBlock(progress.fractionCompleted)
                            
                        }
                    //连接服务器成功后，对json的处理
                    upload.responseJSON { response in
                        self.handleResponse(response: response, successBlock: successBlock, faliedBlock: faliedBlock)
                    }
                    
                case .failure(let encodingError):
                    self.handleRequestError(error: encodingError as NSError, faliedBlock: faliedBlock)
                    }
                
        })
        
    }
    
    // 处理服务器响应数据
    private func handleResponse(response: DataResponse<Any>, successBlock: AFSNetSuccessBlock, faliedBlock: AFSNetFaliedBlock){
        
        switch response.result {
        case .success(let value):
            let json = JSON(value)
            print(json)
            // 一般返回的数据为字典形式，特殊情况可另行处理
            switch json.type {
            case .dictionary:
                self.handleRequestSuccess(json: json, successBlock: successBlock, faliedBlock: faliedBlock)
            case .number,.string,.bool,.array,.null,.unknown:
                self.handleRequestSuccessWithFaliedBlock(faliedBlock: faliedBlock)
            }
            
        case .failure(let error):
            print(error)
            self.handleRequestError(error: error as NSError, faliedBlock: faliedBlock)
        }
        
    }
    
    // 处理请求成功数据
    private func handleRequestSuccess(json: JSON, successBlock: AFSNetSuccessBlock, faliedBlock: AFSNetFaliedBlock){
        //这里临时去掉了服务端返回的code校验，只要返回字典即认为请求成功
//        let code = json[kCodeKey].stringValue
//        if code == kSuccessCode {
            successBlock(json)
//        }else{
//            var errorInfo = AFSErrorInfo()
//            errorInfo.code = code
//            if let msg = json[kMessageKey].string{
//                errorInfo.message = msg
//            }else{
//                errorInfo.message = "服务器未返回错误信息"
//            }
//            faliedBlock(errorInfo)
//        }
    
    }

    // 处理请求失败数据
    private func handleRequestError(error: NSError,faliedBlock: AFSNetFaliedBlock){
        var errorInfo = AFSErrorInfo()
        errorInfo.code = String(error.code)
        errorInfo.error = error
        
        switch error.code {
        case -1:
            errorInfo.message = "未知错误"
        case -999:
            errorInfo.message = "请求被取消"
        case -1000:
            errorInfo.message = "错误的请求"
        case -1001:
            errorInfo.message = "请求超时"
        case -1002:
            errorInfo.message = "不支持的URL地址"
        case -1003:
            errorInfo.message = "找不到主机"
        case -1004:
            errorInfo.message = "无法连接到主机"
        case -1005:
            errorInfo.message = "网络连接中断"
        case -1006:
            errorInfo.message = "DNS查找失败"
        case -1007:
            errorInfo.message = "重定向次数超过限制"
        case -1008:
            errorInfo.message = "无法获取所请求的资源"
        case -1009:
            errorInfo.message = "无网络连接"
        case -1010:
            errorInfo.message = "重定向到一个不存在的位置"
        case -1011:
            errorInfo.message = "服务器返回数据有误"
        case -1012:
            errorInfo.message = "身份验证请求被用户取消"
        case -1013:
            errorInfo.message = "访问资源需要身份验证"
        case -1014:
            errorInfo.message = "服务器返回数据为空"
        case -1015:
            errorInfo.message = "无法解码原始数据"
        case -1016:
            errorInfo.message = "无法解码内容数据"
        case -1017:
            errorInfo.message = "无法解析响应"
        case -1022:
            errorInfo.message = "ATS要求安全连接"
        case -1100:
            errorInfo.message = "文件不存在"
        case -1101:
            errorInfo.message = "请求文件是一个文件夹"
        case -1102:
            errorInfo.message = "没有文件读权限"
        case -1103:
            errorInfo.message = "数据大小超过最大限制"
        case -1104:
            errorInfo.message = "数据超出安全范围"
        case -1200:
            errorInfo.message = "安全连接失败"
        case -1201:
            errorInfo.message = "服务器证书失效"
        case -1202:
            errorInfo.message = "不被信任的服务器证书"
        case -1203:
            errorInfo.message = "未知的服务器根证书"
        case -1204:
            errorInfo.message = "服务器证书还未生效"
        case -1205:
            errorInfo.message = "服务器证书被拒绝"
        case -1206:
            errorInfo.message = "需要客户端证书来验证SSL连接"
        case -2000:
            errorInfo.message = "请求只能加载缓存中的数据，无法加载网络数据"
        case -3000:
            errorInfo.message = "无法创建文件"
        case -3001:
            errorInfo.message = "无法打开文件"
        case -3002:
            errorInfo.message = "无法关闭文件"
        case -3003:
            errorInfo.message = "无法写入文件"
        case -3004:
            errorInfo.message = "无法删除文件"
        case -3005:
            errorInfo.message = "无法移动文件"
        case -3006:
            errorInfo.message = "下载过程中解码失败"
        case -3007:
            errorInfo.message = "下载完成时解码失败"
        case -1018:
            errorInfo.message = "国际漫游关闭"
        case -1019:
            errorInfo.message = "正在通话"
        case -1020:
            errorInfo.message = "数据不被允许"
        case -1021:
            errorInfo.message = "请求的body流被耗尽"
        case -995:
            errorInfo.message = "后台会话需要共享容器"
        case -996:
            errorInfo.message = "后台会话被其他进程使用"
        case -997:
            errorInfo.message = "后台会话未连接"
        default:
            errorInfo.message = "请求失败";
        }
        
        
        faliedBlock(errorInfo);
    
    }
    
    // 服务器返回数据解析出错
    private func handleRequestSuccessWithFaliedBlock(faliedBlock:AFSNetFaliedBlock){
        var errorInfo = AFSErrorInfo()
        errorInfo.code = "-2"
        errorInfo.message = "返回的数据不是字典"
    }

}

// 访问出错具体原因
struct AFSErrorInfo {
    var code    = ""
    var message = ""
    var error   = NSError()
}


