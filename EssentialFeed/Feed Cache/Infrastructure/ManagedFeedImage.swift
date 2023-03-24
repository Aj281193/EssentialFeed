//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 13/01/23.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var data: Data?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
        
    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
extension ManagedFeedImage {
    static func images(feed: [LocalFeedImage],in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: feed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            return managed
        })
    }
}
