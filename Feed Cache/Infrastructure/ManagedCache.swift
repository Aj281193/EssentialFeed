//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 13/01/23.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timeStamp: Date
    @NSManaged var feed: NSOrderedSet
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache  {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
}

