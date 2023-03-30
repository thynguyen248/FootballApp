//
//  CoreDataStack.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import CoreData
import Combine

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FootballApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    private var mainContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private lazy var newBackgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }()
}

extension CoreDataStack {
    func fetch<T: NSManagedObject>(objectType: T.Type,
                                   predicate: NSPredicate? = nil,
                                   sortDescriptor: NSSortDescriptor? = nil,
                                   limit: Int? = nil)
    -> AnyPublisher<[T], AppError> {
        return Future() { [weak self] promise in
            let request = NSFetchRequest<T>(entityName: String(describing: T.self))
            request.predicate = predicate
            if let sortDescriptor = sortDescriptor {
                request.sortDescriptors = [sortDescriptor]
            }
            if let limit = limit {
                request.fetchLimit = limit
            }
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: request) { result in
                let result = result.finalResult ?? []
                promise(.success(result))
            }
            do {
                try self?.mainContext.execute(asynchronousFetchRequest)
            } catch {
                promise(.failure(AppError.dbFetchError(error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func save<T: NSManagedObject>(objectType: T.Type, objects: [T]) -> AnyPublisher<Bool, AppError> {
        return Future() { promise in
            let context = objects.first?.managedObjectContext
            context?.performAndWait {
                if context?.hasChanges == true {
                    do {
                        try context?.save()
                        promise(.success((true)))
                    } catch {
                        promise(.failure(AppError.dbInsertError(error.localizedDescription)))
                    }
                } else {
                    promise(.success((false)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension CoreDataStack: DBHandlerInterface {
    func fetchMatches(with team: String?) -> AnyPublisher<[MatchModel], AppError> {
        var predicate: NSPredicate?
        if let team = team {
            let predicate1 = NSPredicate(format: "home == %@", team)
            let predicate2 = NSPredicate(format: "away == %@", team)
            predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        }
        let sortDescriptor = NSSortDescriptor(key: #keyPath(MatchMO.date), ascending: true)
        return fetch(objectType: MatchMO.self, predicate: predicate, sortDescriptor: sortDescriptor)
            .map { $0.map { $0.matchModel } }
            .eraseToAnyPublisher()
    }
    
    func saveMatches(_ matches: [MatchModel]) -> AnyPublisher<[MatchModel], AppError> {
        let context = newBackgroundContext
        var matchMOs: [MatchMO] = []
        for match in matches {
            let mo = MatchMO(context: context)
            mo.update(with: match)
            matchMOs.append(mo)
        }
        return save(objectType: MatchMO.self, objects: matchMOs)
            .map { result in
                return result ? matches : []
            }
            .eraseToAnyPublisher()
    }
    
    func fetchTeams() -> AnyPublisher<[TeamModel], AppError> {
        return fetch(objectType: TeamMO.self)
            .map { $0.map { $0.teamModel } }
            .eraseToAnyPublisher()
    }
    
    func saveTeams(_ teams: [TeamModel]) -> AnyPublisher<[TeamModel], AppError> {
        let context = newBackgroundContext
        var teamMOs: [TeamMO] = []
        for team in teams {
            let mo = TeamMO(context: context)
            mo.update(with: team)
            teamMOs.append(mo)
        }
        return save(objectType: TeamMO.self, objects: teamMOs)
            .map { result in
                return result ? teams : []
            }
            .eraseToAnyPublisher()
    }
}
