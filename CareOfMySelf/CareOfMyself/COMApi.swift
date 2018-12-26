//
//  COMApi.swift
//  CareOfMySelf
//
//  Created by gaof on 2018/12/24.
//  Copyright © 2018 gaof. All rights reserved.
//
import Moya
import Result
import SwiftyJSON
let provider = MoyaProvider<COMApi>(plugins:[Plugin()])

enum COMApi {
    case switchVideo(open:Bool)
    case switchMon(open:Bool)
    case switchWater(open:Bool)
    case devices
}

extension COMApi:TargetType {
    var baseURL: URL {
        return URL(string: "http://192.168.0.21:5000")!
    }
    
    var path: String {
        switch self {
        case .switchVideo(_):
            return "/switch_video"
        case .switchMon(open: _):
            return "/switch_mon"
        case .switchWater(open: _):
            return "/switch_water"
        case .devices:
            return "/get_devices"
        }
    }
    
    var parameters:[String:Any]? {
        switch self {
        case let .switchVideo(open: open):
            return ["data":open]
        case let .switchMon(open: open):
            return ["data":open]
        case let .switchWater(open: open):
            return ["data":open]
        case .devices:
            return nil
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "care of myself.".data(using: .utf8)!
    }

    var task: Task {
        switch self {
        case .switchVideo(_),.switchMon(open: _):
            return .requestParameters(parameters: self.parameters!, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
}

class Plugin:PluginType {
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case let .success(response):
            print(response)
            
            if let json = response.toJson() {
                if json.dictionary?["code"]?.intValue == 11111 {//请求成功
                    return result
                }
                return Result<Response, MoyaError>.init(error: MoyaError.underlying(fatalError(json.dictionaryValue["msg"]!.stringValue) as! Error, response))
            }else{// 解析失败
                return Result<Response, MoyaError>.init(error: MoyaError.jsonMapping(response))
            }
        case .failure(_):
            return result
        }
    }
}

extension Response {
    func toJson() -> JSON? {
        let json = try? JSON(data: self.data)
        return json
    }
}
