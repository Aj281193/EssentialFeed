//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 11/01/23.
//

import CoreData

public final class CoreDataFeedStore {
    
    private let container: NSPersistentContainer
    
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        
        let bundle = Bundle(for: CoreDataFeedStore.self)
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let cordinator = self.container.persistentStoreCoordinator
            try? cordinator.persistentStores.forEach(cordinator.remove)
        }
    }
}

