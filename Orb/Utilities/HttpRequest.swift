//
//  SHttpRequest.swift
//  HumaraShop
//
//  Created by  on 05/11/15.
//  Copyright © 2015 Mery. All rights reserved.
//

import Foundation

@objc protocol HHandlerDelegate
{
    @objc optional func completedWithDictionary (_ dictTemp : NSDictionary)
    @objc optional func errorOccuredWithError(_ strError:NSString, strTag:NSString)
}
class HttpRequest
{
    
    var api_version : String = ""
    var serviceName: String = ""
    var _serviceURL: String = ""
    var MethodNamee: String = ""
    var ServiceBody: String = ""
    
    var tag: NSInteger
    
    var params : [String:AnyObject]!
    var headerDict : [String:AnyObject]!
    var parsedDataDict : [String:AnyObject]!
    
    
    let api_key = "api_key"
    
    
    init()
    {
        tag = 0
    }
    
    func ServiceName(_ serviceURL : String, params:[String:AnyObject])
    {
        var serviceName: String {
            get {
                return self.serviceName
            }
            set {
                self.serviceName = serviceURL
            }
        }
        var params: [String:AnyObject] {
            get {
                return self.params
            }
            set {
                self.params = params
            }
        }
        
    }
    
    func doGetSOAPResponse ( _ completion: @escaping (_ result: Bool) -> Void)
    {
        if app_Delegate.isServerReachable == false
        {
            self.parsedDataDict = ["error" : "true" as AnyObject,"message":"No Internet Connectivity\nPlease try again later." as AnyObject]
            completion(true)
        }

        var requestBody:Data?
        if self.ServiceBody.count > 0
        {
            requestBody = self.ServiceBody.data(using: String.Encoding.utf8)
        }
        else
        {
            requestBody = self.doPrepareSOAPEnvelope().data(using: String.Encoding.utf8.rawValue)
        }
        var strUrl : NSString = _serviceURL as NSString
        if serviceName.count > 0
        {
            strUrl = NSString(format: "%@/%@", strUrl,serviceName)
        }
        var webStringURL : NSString
        webStringURL =    strUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
        
        var request  = URLRequest(url: URL(string:webStringURL as String)!)
        
        request.httpMethod = MethodNamee
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.httpBody = requestBody
        webStringURL = webStringURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
        
        let url : URL = URL(string: webStringURL as String)!
        request.url = url
        
        print("url = \(url)")
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 180.0
        config.timeoutIntervalForResource = 180.0
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, err) in
            if err == nil{
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Response : ",dataString ?? "")
                let data = self.convertStringToDictionary(dataString!)
                if data is [String:AnyObject]
                {
                    self.parsedDataDict = self.convertStringToDictionary(dataString!) as! [String:AnyObject]
                }else
                {
                    var dict =  [String:AnyObject]()
                    dict["data"] = self.convertStringToDictionary(dataString!) as AnyObject?
                    self.parsedDataDict = dict
                }
                
                completion (true)
            }
            else
            {
                var dict =  [String:AnyObject]()
                dict["error"] = true as AnyObject
                dict["message"] = err?.localizedDescription as AnyObject?
                self.parsedDataDict = dict

                completion (false)

            }
        }
        
        task.resume()
        }
        
    
    func convertStringToDictionary(_ text: NSString) -> AnyObject {
        if let data = text.data(using: String.Encoding.utf8.rawValue) {
            do {
                let json1 = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                if json1 is [[String:AnyObject]]
                {
                    print(json1)
                }
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                return json as AnyObject
            } catch {
                print("Something went wrong")
            }
        }
        return "" as AnyObject
    }
    
    func doPrepareSOAPEnvelope() ->NSMutableString
    {
        let soapEnvelope :NSMutableString? = NSMutableString()
        let keys  = self.params.keys
        let allKey : Int = self.params.count
        if allKey > 0
        {
            
            soapEnvelope?.appendFormat("%@=%@", keys.first! , self.params[keys.first!] as! String)
            
            
            for i in 1 ..< allKey {
                
                let object : AnyObject = self.params[Array(keys)[i]]! as AnyObject;
                
                if object is NSString
                {
                    soapEnvelope?.appendFormat("&%@=%@", Array(keys)[i],self.params[Array(keys)[i]] as! String)
                    
                }
                else if object is NSMutableArray
                {
                    do {
                        let jsonData2 : Data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
                        let datastring = NSString(data: jsonData2, encoding: UInt())
                        print("Response in doPrepareSOAPEnvelope : ",datastring ?? "")
                        soapEnvelope?.appendFormat("&%@=%@", Array(keys)[i],datastring!)
                        
                        // use jsonData
                    } catch {
                        // report error
                    }
                    
                    
                }
                
            }
            print(soapEnvelope!);
        }
        
        return soapEnvelope!
    }
    func manuallyUTF8Encoding(_ str : NSString) ->NSString
    {
        
        var strUTF8 :NSString = str
        
        strUTF8 = strUTF8.replacingOccurrences(of: "/", with: "%2F") as NSString
        strUTF8 = strUTF8.replacingOccurrences(of: ":", with: "%3A") as NSString
        strUTF8 = strUTF8.replacingOccurrences(of: "=", with: "%3D") as NSString
        strUTF8 = strUTF8.replacingOccurrences(of: "&", with: "%26") as NSString
        strUTF8 = strUTF8.replacingOccurrences(of: "+", with: "%2B") as NSString
        return strUTF8
        
    }
    
    
}
