//
//  Special.swift
//  RingCentral
//
//  Created by Tyler Liu on 10/18/16.
//
//

import Alamofire
import ObjectMapper


// We need to map integer IDs to string IDs
struct StringTransform: TransformType {
    func transformFromJSON(_ value: Any?) -> String? {
        if value == nil {
            return ""
        } else {
            return "\(value!)"
        }
    }

    func transformToJSON(_ value: String?) -> Any? {
        return value
    }
}


// MMS
extension ExtensionPath {
    open func mms() -> MmsPath {
        return MmsPath(parent: self)
    }
}
open class MmsPath: PathSegment {
    public override var pathSegment: String {
        get{
            return "sms"
        }
    }
    func post(requestBody: Data, attachments: [Attachment], callback: @escaping (_ t: GetMessageInfoResponse?, _ error: HTTPError?) -> Void) {
        var headers: HTTPHeaders = [:]
        if rc.token != nil {
            headers["Authorization"] = "Bearer \(rc.token!.access_token!)"
        }
        let urlRequest = try! URLRequest(
            url: self.url(withId: false),
            method: .post,
            headers: headers
        )

        Alamofire.Session.default.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(requestBody, withName: "json", fileName: "request.json", mimeType: "application/json")
            for attachment in attachments {
                multipartFormData.append(attachment.data, withName: "attachment", fileName: attachment.fileName, mimeType: attachment.contentType)
            }
        }, with: urlRequest).responseString { response in
            let statusCode = response.response!.statusCode

            switch response.result {
            case let .success(value):
                callback(GetMessageInfoResponse(JSONString: value), nil)
            case let .failure(error):
                callback(nil, HTTPError(statusCode: statusCode, message: error.localizedDescription))
            }
        }
    }

    open func post(parameters: Parameters, attachments: [Attachment], callback: @escaping (_ t: GetMessageInfoResponse?, _ error: HTTPError?) -> Void) {
        let requestBody = try! JSONSerialization.data(withJSONObject: parameters)
        post(requestBody: requestBody, attachments: attachments, callback: callback)
    }

    open func post(parameters: CreateSMSMessage, attachments: [Attachment], callback: @escaping (_ t: GetMessageInfoResponse?, _ error: HTTPError?) -> Void) {
        let parametersBody = parameters.toParameters()["json-string"] as! String
        let requestBody = parametersBody.data(using: String.Encoding.utf8)!
        post(requestBody: requestBody, attachments: attachments, callback: callback)
    }
}



// fax
public struct Attachment {
    var fileName: String
    var contentType: String
    var data: Data
    public init(fileName: String, contentType: String, data: Data) {
        self.fileName = fileName
        self.contentType = contentType
        self.data = data
    }
}

//public struct URLReu URLRequestConvertible

extension FaxPath {
    func post(requestBody: Data, attachments: [Attachment], callback: @escaping (_ t: FaxResponse?, _ error: HTTPError?) -> Void) {
        var headers: HTTPHeaders = [:]
        if rc.token != nil {
            headers["Authorization"] = "Bearer \(rc.token!.access_token!)"
        }
        let urlRequest = try! URLRequest(
            url: self.url(withId: false),
            method: .post,
            headers: headers
        )
        Alamofire.Session.default.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(requestBody, withName: "json", fileName: "request.json", mimeType: "application/json")
            for attachment in attachments {
                multipartFormData.append(attachment.data, withName: "attachment", fileName: attachment.fileName, mimeType: attachment.contentType)
            }
        }, with: urlRequest).responseString { response in
            let statusCode = response.response!.statusCode

            switch response.result {
            case let .success(value):
                callback(FaxResponse(JSONString: value), nil)
            case let .failure(error):
                callback(nil, HTTPError(statusCode: statusCode, message: error.localizedDescription))
            }
        }
    }

    open func post(parameters: Parameters, attachments: [Attachment], callback: @escaping (_ t: FaxResponse?, _ error: HTTPError?) -> Void) {
        let requestBody = try! JSONSerialization.data(withJSONObject: parameters)
        post(requestBody: requestBody, attachments: attachments, callback: callback)
    }
}


// upload profile image
extension ProfileImagePath {
    open func put(imageData: Data, imageFileName: String, callback: @escaping (_ error: HTTPError?) -> Void) {
        var headers: HTTPHeaders = [:]
        if rc.token != nil {
            headers["Authorization"] = "Bearer \(rc.token!.access_token!)"
        }
        let ext = URL(fileURLWithPath: imageFileName).pathExtension

        let urlRequest = try! URLRequest(
            url: self.url(withId: false),
            method: .put,
            headers: headers
        )

        Alamofire.Session.default.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "image", fileName: imageFileName, mimeType: "image/\(ext)")
        }, with: urlRequest).responseData { response in
            let statusCode = response.response!.statusCode

            switch response.result {
            case .success:
                callback(nil)
            case let .failure(error):
                callback(HTTPError(statusCode: statusCode, message: error.localizedDescription))
            }
        }
    }

    open func post(imageData: Data, imageFileName: String, callback: @escaping (_ error: HTTPError?) -> Void) {
        put(imageData: imageData, imageFileName: imageFileName, callback: callback)
    }
}


open class Notification: Mappable {
    open var event: String?
    open var json: String?
    required public init?(map: Map) {
    }

    convenience public init?(json: String) {
        self.init(JSONString: json)
        self.json = json
    }

    open func mapping(map: Map) {
        event <- map["event"]
    }
}
