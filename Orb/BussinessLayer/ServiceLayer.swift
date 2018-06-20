//
//  ServiceLayer.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 29/06/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
import CoreData

let EXP_TOKEN_ERR = "Your TaksyKraft Orb App Access Token Is Invalid Or Has Expired"
public enum ParsingConstant : Int
{
    case GetOTP
    case VerifyOTP
    case Login
}
class ServiceLayer: NSObject {
    let SERVER_ERROR = "Server not responding.\nPlease try after some time."
    public func getContent(lat:String,long:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var id = ""
        if let str = Keychain.loadUDID(service: "Orb", account: "OrbAccount")
        {
            id = str
        }
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "http://myryd.com/api/v1/newAdmedia/latitude=\(lat)/longitude=\(long)/deviceid=\(id)"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["content"] as? [[String:AnyObject]]
                        {
                            CoreDataAccessLayer.sharedInstance.deleteAllContentItemsFromLocalDB()
                            var arrContentBO = [ContentBO]()
                            var arrBannerBO = [BannerBO]()
                            for content in data
                            {
                                let bo = ContentBO()
                                if let FileUrl = content["FileUrl"] as? String
                                {
                                    bo.FileUrl = FileUrl
                                }
                                if let Thumbnail = content["Thumbnail"] as? String
                                {
                                    bo.Thumbnail = Thumbnail
                                }
                                if let Title = content["Title"] as? String
                                {
                                    bo.Title = Title
                                }
                                if let Duration = content["Duration"] as? Double
                                {
                                    bo.Duration = String(Duration)
                                }
                                if let Provided_by = content["Provided_by"] as? String
                                {
                                    bo.Provided_by = Provided_by
                                }
                                if let Latitude = content["Latitude"] as? String
                                {
                                    bo.Latitude = Latitude
                                }
                                if let Longitude = content["Longitude"] as? String
                                {
                                    bo.Longitude = Longitude
                                }
                                if let FileKey = content["FileKey"] as? String
                                {
                                    bo.FileKey = FileKey
                                }
                                if let Uploaded_by = content["Uploaded_by"] as? String
                                {
                                    bo.Uploaded_by = Uploaded_by
                                }
                                if let Channel = content["Channel"] as? String
                                {
                                    bo.Channel = Channel
                                }
                                if let Language = content["Language"] as? String
                                {
                                    bo.Language = Language
                                }
                                arrContentBO.append(bo)
                                //Save To DB
                                CoreDataAccessLayer.sharedInstance.saveItemIntoContentTableInLocalDB(tmpItem: bo)
                            }
                            if let images = obj.parsedDataDict["images"] as? [[String:AnyObject]]
                            {
                                CoreDataAccessLayer.sharedInstance.deleteAllBannerItemsFromLocalDB()
                                var index = 0
                                for image in images
                                {
                                    let bo = BannerBO()
                                    if let FileUrl = image["FileUrl"] as? String
                                    {
                                        bo.FileUrl = FileUrl
                                    }
                                    if let Bannerimage = image["Bannerimage"] as? String
                                    {
                                        bo.Bannerimage = Bannerimage
                                    }
                                    if let BrandType = image["BrandType"] as? String
                                    {
                                        bo.BrandType = BrandType
                                    }
                                    if let button_text = image["button_text"] as? String
                                    {
                                        bo.button_text = button_text
                                    }
                                    if let AdFileType = image["AdFileType"] as? String
                                    {
                                        if index%2 == 0
                                        {
                                            bo.AdFileType = BANNERTYPE_U
                                        }
                                        else
                                        {
                                            bo.AdFileType = AdFileType
                                        }
                                        index = index + 1
                                    }
                                    if let Latitude = image["Latitude"] as? NSNumber
                                    {
                                        bo.Latitude = CGFloat(Latitude.floatValue)
                                    }
                                    if let Longitude = image["Longitude"] as? NSNumber
                                    {
                                        bo.Longitude = CGFloat(Longitude.floatValue)
                                    }
                                    if let zipcodes = image["zipcodes"] as? String
                                    {
                                        bo.zipcodes = zipcodes
                                    }
                                    if let FileKey = image["FileKey"] as? String
                                    {
                                        bo.FileKey = FileKey
                                    }
                                    if let Uploaded_by = image["Uploaded_by"] as? String
                                    {
                                        bo.Uploaded_by = Uploaded_by
                                    }
                                    if let ShareLink = image["ShareLink"] as? String
                                    {
                                        bo.ShareLink = ShareLink
                                    }
                                    arrBannerBO.append(bo)
                                    CoreDataAccessLayer.sharedInstance.saveItemIntoBannerTableInLocalDB(tmpItem: bo)
                                }
                            }
                            var dict = [String:AnyObject]()
                            dict["content"] = arrContentBO as AnyObject
                            dict["banner"] = arrBannerBO as AnyObject
                            successMessage(dict)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func getBannerCount(lat : String,long:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var id = ""
        if let str = Keychain.loadUDID(service: "Orb", account: "OrbAccount")
        {
            id = str
        }

        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "http://myryd.com/api/v1/hourlysync/latitude=\(lat)/longitude=\(long)/deviceid=\(id)"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let images = obj.parsedDataDict["images"] as? [[String:AnyObject]]
                        {
                            let arrAdBanners = CoreDataAccessLayer.sharedInstance.getAllBannersFromLocalDB()
                            var arrBanners = [BannerBO]()
                            for image in images
                            {
                                let arrFilter = arrAdBanners.filter({ (banner) -> Bool in
                                    return banner.FileKey == image["FileKey"] as! String
                                })
                                if arrFilter.count > 0
                                {
                                    let bo = arrFilter[0]
                                    bo.count = (image["Show"] as? Int)!
                                    bo.showCount = 0
                                    print("Serv Filekey : \(bo.FileKey)")
                                    print("Serv count : \(bo.count)")
                                    arrBanners.append(bo)
                                    CoreDataAccessLayer.sharedInstance.updateBannerItemWith(tmpItem: bo)
                                }
                            }
                            
                            successMessage(arrBanners)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func getTrendingAndBanners(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var id = ""
        if let str = Keychain.loadUDID(service: "Orb", account: "OrbAccount")
        {
            id = str
        }

        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "http://myryd.com/api/v1/trending/deviceid=\(id)"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        var dict = [String:AnyObject]()
                        if let content = obj.parsedDataDict["trendingContent"] as? [[String:AnyObject]],let banners = obj.parsedDataDict["lastestBanners"] as? [[String:AnyObject]]
                        {
                            var arrTrending = [ContentBO]()
                            for content in content
                            {
                                let bo = ContentBO()
                                if let FileKey = content["filekey"] as? String
                                {
                                    bo.FileKey = FileKey
                                }
                                if let priority = content["priority"] as? NSNumber
                                {
                                    bo.priority = String(priority.intValue)
                                }
                                arrTrending.append(bo)
                            }
                            dict["Trending"] = arrTrending as AnyObject
                            CoreDataAccessLayer.sharedInstance.updateTrendingContentItemsWith(arrTmpItem: arrTrending)

                            var arrBanner = [BannerBO]()
                            for banner in banners
                            {
                                let bo = BannerBO()
                                if let title = banner["title"] as? String
                                {
                                    bo.title = title
                                }
                                if let link = banner["link"] as? String
                                {
                                    bo.link = link
                                }
                                if let endDate = banner["endDate"] as? String
                                {
                                    bo.endDate = endDate
                                }
                                if let language = banner["language"] as? String
                                {
                                    bo.language = language
                                }
                                if let location = banner["location"] as? String
                                {
                                    bo.location = location
                                }
                                arrBanner.append(bo)
                            }
                            dict["Banners"] = arrBanner as AnyObject
                            successMessage(dict)
                        }
                       else if let banners = obj.parsedDataDict["lastestBanners"] as? [[String:AnyObject]]
                        {
                            var arrBanner = [BannerBO]()
                            for banner in banners
                            {
                                let bo = BannerBO()
                                if let title = banner["title"] as? String
                                {
                                    bo.title = title
                                }
                                if let link = banner["link"] as? String
                                {
                                    bo.link = link
                                }
                                if let endDate = banner["endDate"] as? String
                                {
                                    bo.endDate = endDate
                                }
                                if let language = banner["language"] as? String
                                {
                                    bo.language = language
                                }
                                if let location = banner["location"] as? String
                                {
                                    bo.location = location
                                }
                                arrBanner.append(bo)
                            }
                            dict["Trending"] = [ContentBO]() as AnyObject
                            dict["Banners"] = arrBanner as AnyObject
                            successMessage(dict)
                        }
                        else if let content = obj.parsedDataDict["trendingContent"] as? [[String:AnyObject]]
                        {
                            var arrTrending = [ContentBO]()
                            for content in content
                            {
                                let bo = ContentBO()
                                if let FileKey = content["filekey"] as? String
                                {
                                    bo.FileKey = FileKey
                                }
                                if let priority = content["priority"] as? NSNumber
                                {
                                    bo.priority = String(priority.intValue)
                                }
                                arrTrending.append(bo)
                            }
                            dict["Trending"] = arrTrending as AnyObject
                            dict["Banners"] = [BannerBO]() as AnyObject
                            successMessage(dict)
                        }
                        else
                        {
                            failureMessage("No Data Found.")

                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func getRadioContent(lat:String,long:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var id = ""
        if let str = Keychain.loadUDID(service: "Orb", account: "OrbAccount")
        {
            id = str
        }

        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "http://myryd.com/api/v1/radio/latitude=\(lat)/longitude=\(long)/deviceid=\(id)"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["Radio"] as? [[String:AnyObject]]
                        {
                            var arrBO = [RadioBO]()
                            for radio in data
                            {
                                let bo = RadioBO()
                                if let Channel = radio["Channel"] as? String
                                {
                                    bo.Channel = Channel
                                }
                                if let Sno = radio["Sno"] as? String
                                {
                                    bo.Sno = Sno
                                }
                                if let Frequency = radio["Frequency"] as? String
                                {
                                    bo.Frequency = Frequency
                                }
                                if let Thumbnail = radio["Thumbnail"] as? String
                                {
                                    bo.Thumbnail = Thumbnail
                                }
                                if let Link = radio["Link"] as? String
                                {
                                    bo.Link = Link
                                }
                                arrBO.append(bo)
                            }
                            successMessage(arrBO)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func getCastId(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var id = ""
        if let str = Keychain.loadUDID(service: "Orb", account: "OrbAccount")
        {
            id = str
        }
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "http://myryd.com/api/v1/cast/deviceid=\(id)"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let code = obj.parsedDataDict["code"] as? NSNumber
                        {
                            successMessage(code.intValue)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func getCabDetails(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var id = ""
        if let str = Keychain.loadUDID(service: "Orb", account: "OrbAccount")
        {
            id = str
        }
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "http://myryd.com/api/v1/driverinfo/deviceid=\(id)"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let message = obj.parsedDataDict["message"] as? [[String:AnyObject]]
                        {
                            var arrCabDetails = [CabDetailBO]()
                            for cab in message
                            {
                                let bo = CabDetailBO()
                                if let fullName = cab["fullName"] as? String
                                {
                                    bo.fullName = fullName
                                }
                                if let carNo = cab["carNo"] as? String
                                {
                                    bo.carNo = carNo
                                }
                                if let carType = cab["carType"] as? String
                                {
                                    bo.carType = carType
                                }
                                if let languages = cab["languages"] as? String
                                {
                                    bo.languages = languages
                                }
                                if let address = cab["address"] as? String
                                {
                                    bo.address = address
                                }
                                if let image = cab["image"] as? String
                                {
                                    bo.image = image
                                }
                                if let type = cab["type"] as? String
                                {
                                    bo.type = type
                                }
                                arrCabDetails.append(bo)
                            }
                            
                            successMessage(arrCabDetails)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func trackDeviceStatus(lat:String,long:String,UDID:String,BLevel : String,freeSpace : String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "http://myryd.com/api/v1/trackNew/latitude=\(lat)/longitude=\(long)/deviceid=\(UDID)/distance=0.0/blevel=\(BLevel)/freespace=\(freeSpace)/lock_status=1/version=77/charging_type=2"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        successMessage("Success")
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func registerDeviceWith(deviceid:String,city:String,model : String,mobile : String,vendor:String,carNo:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "http://myryd.com/api/v1/storeiosdevice"
        obj.params = ["deviceid":deviceid,
                      "city":city,
                      "model":model,
                      "mobile":mobile,
                      "vendor":vendor,
                      "carno":carNo] as [String : AnyObject]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let uid = obj.parsedDataDict["uid"] as? NSNumber
                        {
                            successMessage(uid)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    //MARK:- Utility Methods
    public func convertDictionaryToString(dict: [String:String]) -> String? {
        var strReturn = ""
        for (key,val) in dict
        {
            strReturn = strReturn.appending("\(key)=\(val)&")
        }
        strReturn = String(strReturn.dropLast())
        
        return strReturn
    }
    
    
    
    public func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    public func encodeSpecialCharactersManually(_ strParam : String)-> String
    {
        
        var strParams = strParam.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)
        strParams = strParams!.replacingOccurrences(of: "&", with:"%26")
        return strParams!
    }
    
    public func convertSpecialCharactersFromStringForAddress(_ strParam : String)-> String
    {
        
        var strParams = strParam.replacingOccurrences(of: "&", with:"&amp;")
        strParams = strParams.replacingOccurrences(of: ">", with: "&gt;")
        strParams = strParams.replacingOccurrences(of: "<", with: "&lt;")
        strParams = strParams.replacingOccurrences(of: "\"", with: "&quot;")
        strParams = strParams.replacingOccurrences(of: "'", with: "&apos;")
        return strParams
    }
    public func convertStringFromSpecialCharacters(strParam : String)-> String
    {
        
        var strParams = strParam.replacingOccurrences(of:"%26", with:"&")
        strParams = strParams.replacingOccurrences(of:"&amp;", with:"&")
        strParams = strParams.replacingOccurrences(of:"%3E", with: ">")
        strParams = strParams.replacingOccurrences(of:"%3C" , with: "<")
        strParams = strParams.replacingOccurrences(of:"&quot;", with: "\"")
        strParams = strParams.replacingOccurrences(of:"&apos;" , with: "'")
        
        return strParams
    }

}
