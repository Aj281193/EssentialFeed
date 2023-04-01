//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 11/01/23.
//

import CoreData

public final class CoreDataFeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case ModelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.ModelNotFound
        }
        do {
             container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
            
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
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

