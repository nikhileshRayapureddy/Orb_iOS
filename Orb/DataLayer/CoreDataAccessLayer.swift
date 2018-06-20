//
//  CoreDataAccessLayer.swift
//  CapillaryFramework
//
//  Created by Medico Desk on 05/05/17.
//  Copyright © 2017 Capillary Technologies. All rights reserved.
//

import UIKit
import CoreData

class CoreDataAccessLayer: NSObject {
    
   static let sharedInstance = CoreDataAccessLayer()
    
    func getListOfObjectsForEntityForName(strClass :String,strFetcher:String) -> [NSManagedObject]?
    {
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: strClass)
        if strFetcher.count > 0
        {
            let resultPredicate = NSPredicate(format: strFetcher as String)
            request.predicate = resultPredicate
        }
        
        do {
            let searchResults  = try managedObjectContext.fetch(request)
            return searchResults as? [NSManagedObject]
        } catch {
            print("Error with request: \(error)")
        }
        return nil
        
    }
    
    func getListDataForEntity(strclass:String, strFormat:String) -> [NSManagedObject]?
    {
        
        let arrMutable = self.getListOfObjectsForEntityForName(strClass: strclass,strFetcher: strFormat)
        if arrMutable == nil
        {
            return nil
        }
        else
        {
            return arrMutable!
        }
        
    }
    
    
    //Content
    public func getContentDataWith(strFetcher:String) -> [NSManagedObject]?
    {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Content",
                                                           in: managedObjectContext)
        
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        request.entity = entityDescription
        
        if strFetcher.count > 0
        {
            let resultPredicate = NSPredicate(format: strFetcher as String)
            request.predicate = resultPredicate
        }
        
        do
        {
            let results = try  managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            
            return results as? [NSManagedObject]
        }
        catch _
        {
            
        }
        return[]
        
    }
    func getAllContentFromLocalDB() -> [ContentBO]
    {
        let arrContent = self.getListDataForEntity(strclass: "Content",strFormat:"")
        if arrContent == nil || arrContent?.count == 0
        {
            return [ContentBO]()
        }
        
        if arrContent!.count > 0
        {
            return self.convertContentEntityArrayToContentBOArray(arr: arrContent as! [Content])
        }
        else
        {
            return [ContentBO]()
        }
        
    }
    public func getBannerDataWith(strFetcher:String) -> [NSManagedObject]?
    {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Banner",
                                                           in: managedObjectContext)
        
        let request: NSFetchRequest<Banner> = Banner.fetchRequest()
        request.entity = entityDescription
        
        if strFetcher.count > 0
        {
            let resultPredicate = NSPredicate(format: strFetcher as String)
            request.predicate = resultPredicate
        }
        
        do
        {
            let results = try  managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            
            return results as? [NSManagedObject]
        }
        catch _
        {
            
        }
        return[]
        
    }

    func getContentFromLocalDBWithFileKey(strFileKey : String) -> ContentBO
    {
        let arrContent = self.getListDataForEntity(strclass: "Content",strFormat:"fileKey == '" +  strFileKey + "'")
        if arrContent == nil || arrContent?.count == 0
        {
            return ContentBO()
        }
        
        if arrContent!.count > 0
        {
            return self.convertContentEntityArrayToContentBOArray(arr: arrContent as! [Content])[0]
        }
        else
        {
            return ContentBO()
        }
        
    }
    func getContentFromLocalDBWith(strChannel : String,strLanguage : String) -> [ContentBO]
    {
        let arrContent = self.getListDataForEntity(strclass: "Content",strFormat:"channel == '" +  strChannel + "' AND language=='" +  strLanguage + "'")
        if arrContent == nil || arrContent?.count == 0
        {
            return [ContentBO]()
        }
        
        if arrContent!.count > 0
        {
            return self.convertContentEntityArrayToContentBOArray(arr: arrContent as! [Content])
        }
        else
        {
            return [ContentBO]()
        }
        
    }

    func getAllLanguages()-> [String]
    {
        var arrLangs = [String]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["language"]
        fetchRequest.returnsDistinctResults = true
        let result = try! managedObjectContext.fetch(fetchRequest)
        for content in result
        {
            let lang = content as! [String:AnyObject]
            arrLangs.append(lang["language"] as! String)
        }
        return arrLangs

    }
    func getAllChannelsWith(strLang:String)-> [String]
    {
        var arrChannel = [String]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.predicate = NSPredicate(format: "language = %@", strLang)
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["channel"]
        fetchRequest.returnsDistinctResults = true
        let result = try! managedObjectContext.fetch(fetchRequest)
        for content in result
        {
            let channel = content as! [String:AnyObject]
            arrChannel.append(channel["channel"] as! String)
        }
        return arrChannel
        
    }

    func saveItemIntoContentTableInLocalDB( tmpItem : ContentBO)
    {
        let arrContent  =  self.checkAvaibleVersionIs10() ? self.getContentDataWith(strFetcher:"fileKey == '" +  tmpItem.FileKey + "'")  : self.getListDataForEntity(strclass: "Content",strFormat:"fileKey == '" +  tmpItem.FileKey + "'")
        if arrContent!.count == 0
        {
            let entity =  NSEntityDescription.entity(forEntityName: "Content",in:managedObjectContext)
            
            let contentItem = NSManagedObject(entity: entity!,insertInto: managedObjectContext) as! Content
            contentItem.channel = tmpItem.Channel
            contentItem.fileKey = tmpItem.FileKey
            contentItem.fileUrl = tmpItem.FileUrl
            contentItem.duration = Double(tmpItem.Duration)!
            contentItem.language = tmpItem.Language
            contentItem.provided_by = tmpItem.Provided_by
            contentItem.latitude = Double(tmpItem.Latitude)!
            contentItem.longitude = Double(tmpItem.Longitude)!
            contentItem.thumbnail = tmpItem.Thumbnail
            contentItem.title = tmpItem.Title
            contentItem.uploaded_by = tmpItem.Uploaded_by
            do {
                try managedObjectContext.save()
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        else
        {
            self.updateContentItemWith(tmpItem: tmpItem)
        }
        
    }
    func getAllrendingContent() -> [ContentBO]
    {
        let arrContent = self.getListDataForEntity(strclass: "Content",strFormat:"isTrending == '1'")
        if arrContent == nil || arrContent?.count == 0
        {
            return [ContentBO]()
        }
        
        if arrContent!.count > 0
        {
            return self.convertContentEntityArrayToContentBOArray(arr: arrContent as! [Content])
        }
        else
        {
            return [ContentBO]()
        }
        
    }

    func updateTrendingContentItemsWith(arrTmpItem: [ContentBO])
    {
        for tmpItem in arrTmpItem
        {
            let arrContent  =  self.checkAvaibleVersionIs10() ? self.getContentDataWith(strFetcher:"fileKey == '" +  tmpItem.FileKey + "'")  : self.getListDataForEntity(strclass: "Content",strFormat:"fileKey == '" +  tmpItem.FileKey + "'")
            if arrContent!.count > 0
            {
                let contentItem = arrContent![0] as! Content
                contentItem.isTrending = true
                do {
                    try managedObjectContext.save()
                    
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
        }
        
    }

    func updateContentItemWith(tmpItem: ContentBO)
    {
        
        let arrContent  =  self.checkAvaibleVersionIs10() ? self.getContentDataWith(strFetcher:"fileKey == '" +  tmpItem.FileKey + "'")  : self.getListDataForEntity(strclass: "Content",strFormat:"fileKey == '" +  tmpItem.FileKey + "'")
        if arrContent!.count > 0
        {
            
            let contentItem = arrContent![0] as! Content
            contentItem.channel = tmpItem.Channel
            contentItem.fileKey = tmpItem.FileKey
            contentItem.fileUrl = tmpItem.FileUrl
            contentItem.duration = Double(tmpItem.Duration)!
            contentItem.language = tmpItem.Language
            contentItem.provided_by = tmpItem.Provided_by
            contentItem.latitude = Double(tmpItem.Latitude)!
            contentItem.longitude = Double(tmpItem.Longitude)!
            contentItem.thumbnail = tmpItem.Thumbnail
            contentItem.title = tmpItem.Title
            contentItem.uploaded_by = tmpItem.Uploaded_by
            do {
                try managedObjectContext.save()
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        else
        {
            self.saveItemIntoContentTableInLocalDB(tmpItem: tmpItem)
            print("No Publish item found")
        }
        
    }
    func deleteItemsFromLocalDBWith(arrFileKey : [[String:String]])
    {
        for file in arrFileKey
        {
            if file["Type"] == "content"
            {
                self.deleteItemFromLocalDBWith(fileKey: file["FileKey"]!)
            }
        }
    }
    func deleteAllContentItemsFromLocalDB()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        if #available(iOS 9.0, *) {
            let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.execute(delete)
            } catch let error as NSError {
                print("Error occured while deleting: \(error)")
            }
        } else {
            // Fallback on earlier versions
            let arrContent = self.getListDataForEntity(strclass: "Content",strFormat:"")
            for content in arrContent! {
                let con = content as! Content
                self.deleteItemFromLocalDBWith(fileKey:con.fileKey!)
            }
        }

    }
    func deleteItemFromLocalDBWith(fileKey : String)
    {
        
        var results : [Content]!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        let predicate = NSPredicate(format: "fileKey == %@", fileKey)
        request.predicate = predicate
        do{
            
            
            results = try managedObjectContext.fetch(request) as! [Content]
            if (results.count > 0) {
                managedObjectContext.delete( results[0])
                
            } else {
                
            }
        } catch let error as NSError {
            
            print("Fetch failed: \(error.localizedDescription)")
        }
        do {
            try managedObjectContext.save()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    //MARK:- Banner Methods
    
    func getAllBannersFromLocalDB() -> [BannerBO]
    {
        let arrBanner = self.getListDataForEntity(strclass: "Banner",strFormat:"")
        if arrBanner == nil || arrBanner?.count == 0
        {
            return [BannerBO]()
        }
        
        if arrBanner!.count > 0
        {
            return self.convertBannerEntityArrayToContentBOArray(arr: arrBanner as! [Banner])
        }
        else
        {
            return [BannerBO]()
        }
    }
    func getBannersFromLocalDBWith(fileKey : String) -> BannerBO
    {
        let arrBanner  =  self.checkAvaibleVersionIs10() ? self.getBannerDataWith(strFetcher:"fileKey == '" +  fileKey + "'")  : self.getListDataForEntity(strclass: "Banner",strFormat:"fileKey == '" +  fileKey + "'")
        if arrBanner == nil || arrBanner?.count == 0
        {
            return BannerBO()
        }
        
        if arrBanner!.count > 0
        {
            return self.convertBannerEntityArrayToContentBOArray(arr: arrBanner as! [Banner])[0]
        }
        else
        {
            return BannerBO()
        }
    }

    func saveItemIntoBannerTableInLocalDB( tmpItem : BannerBO)
    {
        let arrBanner  =  self.checkAvaibleVersionIs10() ? self.getBannerDataWith(strFetcher:"fileKey == '" +  tmpItem.FileKey + "'")  : self.getListDataForEntity(strclass: "Banner",strFormat:"fileKey == '" +  tmpItem.FileKey + "'")
        if arrBanner!.count == 0
        {
            let entity =  NSEntityDescription.entity(forEntityName: "Banner",in:managedObjectContext)
            
            let bannerItem = NSManagedObject(entity: entity!,insertInto: managedObjectContext) as! Banner
            bannerItem.fileUrl = tmpItem.FileUrl
            bannerItem.bannerimage = tmpItem.Bannerimage
            bannerItem.brandType = tmpItem.BrandType
            bannerItem.button_text = tmpItem.button_text
            bannerItem.adFileType = tmpItem.AdFileType
            bannerItem.latitude = Float(tmpItem.Latitude)
            bannerItem.longitude = Float(tmpItem.Longitude)
            bannerItem.zipcodes = tmpItem.zipcodes
            bannerItem.fileKey = tmpItem.FileKey
            bannerItem.uploaded_by = tmpItem.Uploaded_by
            bannerItem.shareLink = tmpItem.ShareLink
            bannerItem.count = Int16(tmpItem.count)
            do {
                try managedObjectContext.save()
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        else
        {
            self.updateBannerItemWith(tmpItem: tmpItem)
        }
        
    }
    func updateBannerItemWith(tmpItem: BannerBO)
    {
        
        let arrBanner  =  self.checkAvaibleVersionIs10() ? self.getBannerDataWith(strFetcher:"fileKey == '" +  tmpItem.FileKey + "'")  : self.getListDataForEntity(strclass: "Banner",strFormat:"fileKey == '" +  tmpItem.FileKey + "'")
        if arrBanner!.count > 0
        {
            
            let bannerItem = arrBanner![0] as! Banner
            bannerItem.fileUrl = tmpItem.FileUrl
            bannerItem.bannerimage = tmpItem.Bannerimage
            bannerItem.brandType = tmpItem.BrandType
            bannerItem.button_text = tmpItem.button_text
            bannerItem.adFileType = tmpItem.AdFileType
            bannerItem.latitude = Float(tmpItem.Latitude)
            bannerItem.longitude = Float(tmpItem.Longitude)
            bannerItem.zipcodes = tmpItem.zipcodes
            bannerItem.fileKey = tmpItem.FileKey
            bannerItem.uploaded_by = tmpItem.Uploaded_by
            bannerItem.shareLink = tmpItem.ShareLink
            bannerItem.count = Int16(tmpItem.count)
            bannerItem.showCount = Int16(tmpItem.showCount)
            do {
                try managedObjectContext.save()
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        else
        {
            self.saveItemIntoBannerTableInLocalDB(tmpItem: tmpItem)
            print("No Publish item found")
        }
        
    }
    func deleteAllBannerItemsFromLocalDB()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Banner")
        if #available(iOS 9.0, *) {
            let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.execute(delete)
            } catch let error as NSError {
                print("Error occured while deleting: \(error)")
            }
        } else {
            // Fallback on earlier versions
            let arrBanner = self.getListDataForEntity(strclass: "Banner",strFormat:"")
            for Banner in arrBanner! {
                let ban = Banner as! Banner
                self.deleteBannerFromLocalDBWith(fileKey:ban.fileKey!)
            }
        }
        
    }
    func deleteBannerFromLocalDBWith(fileKey : String)
    {
        
        var results : [Banner]!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Banner")
        let predicate = NSPredicate(format: "fileKey == %@", fileKey)
        request.predicate = predicate
        do{
            
            
            results = try managedObjectContext.fetch(request) as! [Banner]
            if (results.count > 0) {
                managedObjectContext.delete( results[0])
                
            } else {
                
            }
        } catch let error as NSError {
            
            print("Fetch failed: \(error.localizedDescription)")
        }
        do {
            try managedObjectContext.save()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }


    //MARK:- Utility Methods
    func convertContentEntityArrayToContentBOArray (arr : [Content]) -> [ContentBO]
    {
        var arrContentItems = [ContentBO]()
        for tmpItem in arr
        {
            let contentBO = ContentBO()
            contentBO.Channel = tmpItem.channel!
            contentBO.FileKey = tmpItem.fileKey!
            contentBO.FileUrl = tmpItem.fileUrl!
            contentBO.Duration = String(Double(tmpItem.duration))
            contentBO.Language = tmpItem.language!
            contentBO.Latitude = String(Double(tmpItem.latitude))
            contentBO.Longitude = String(Double(tmpItem.longitude))
            contentBO.Provided_by = tmpItem.provided_by!
            contentBO.Thumbnail = tmpItem.thumbnail!
            contentBO.Title = tmpItem.title!
            contentBO.Uploaded_by = tmpItem.uploaded_by!
            arrContentItems.append(contentBO)
        }
        return arrContentItems
        
    }
    func convertBannerEntityArrayToContentBOArray (arr : [Banner]) -> [BannerBO]
    {
        var arrBannerItems = [BannerBO]()
        for tmpItem in arr
        {
            let bannerBO = BannerBO()
            bannerBO.FileUrl = tmpItem.fileUrl!
            bannerBO.Bannerimage = tmpItem.bannerimage!
            bannerBO.BrandType = tmpItem.brandType!
            bannerBO.button_text = tmpItem.button_text!
            bannerBO.AdFileType = tmpItem.adFileType!
            bannerBO.Latitude = CGFloat(tmpItem.latitude)
            bannerBO.Longitude = CGFloat(tmpItem.longitude)
            bannerBO.zipcodes = tmpItem.zipcodes!
            bannerBO.FileKey = tmpItem.fileKey!
            bannerBO.Uploaded_by = tmpItem.uploaded_by!
            bannerBO.ShareLink = tmpItem.shareLink!
            bannerBO.count = Int(tmpItem.count)
            bannerBO.showCount = Int(tmpItem.showCount)
            arrBannerItems.append(bannerBO)
        }
        return arrBannerItems
        
    }

    
    func checkAvaibleVersionIs10()->Bool{
        if #available(iOS 10.0, *)
        {
            return true
        }
        return false
    }

    // MARK: - Core Data stack
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let carKitBundle = Bundle(identifier: "com.taksykraft.orb")
        let modelURL = carKitBundle?.url(forResource: "Orb", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var failureReason = "There was an error creating or loading the application's saved data."
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: mOptions)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as AnyObject?
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()
  
    private let modelName = "Orb"
    var storeURL : URL {
        let storePaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let storePath = storePaths[0] as NSString
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(
                atPath: storePath as String,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            print("Error creating storePath \(storePath): \(error)")
        }
        
        let sqliteFilePath = storePath
            .appendingPathComponent(modelName + ".sqlite")
        print("sqliteFilePath : \(sqliteFilePath)")

        return URL(fileURLWithPath: sqliteFilePath)
    }
    @available(iOS 10.0, *)
    var savingContext: NSManagedObjectContext {
        return storeContainer.newBackgroundContext()
    }

    @available(iOS 10.0, *)
    lazy var storeDescription: NSPersistentStoreDescription = {
        let description = NSPersistentStoreDescription(url: self.storeURL)
        return description
    }()
    
    @available(iOS 10.0, *)
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.persistentStoreDescriptions = [self.storeDescription]
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()
    
    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = storeContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            do {
                try managedObjectContext.save()
                
            } catch let error  {
                print("Could not save \(error), \(error.localizedDescription)")
            }
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                    
                } catch let error  {
                    print("Could not save \(error), \(error.localizedDescription)")
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
            
        }
        
    }

    
}

