//
//  Chef.swift
//  Chefs
//
//  Created by Daniel Watson on 09.12.23.
//

import Foundation
import Combine
import Firebase
final class ChefManager {
    private var firestoreManager = FirestoreManager()
    private var rootCollection = "chefs"
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    func initialiseChef(chef: Chef, completion: @escaping (Result<Chef, Error>) -> Void) {
        checkIfDocExists(documentID: chef.id) { [weak self] exists in
            guard let self = self else {
                completion(.failure(MiseboxError.selfIsNil)) // Use an appropriate error
                return
            }
            if exists {
                self.attachListenerAndUpdateChef(chefId: chef.id, chef: chef, completion: completion)
            } else {
                completion(.failure(MiseboxError.documentDoesNotExist)) // Define this error case
            }
        }
    }
    func checkIfDocExists(documentID: String, completion: @escaping (Bool) -> Void) {
        firestoreManager.checkDocumentExists(collection: rootCollection, documentID: documentID, completion: completion)
    }
    private func attachListenerAndUpdateChef(chefId: String, chef: Chef, completion: @escaping (Result<Chef, Error>) -> Void) {
        self.listener = self.firestoreManager.listenToDocument(collection: rootCollection, documentID: chefId) { (result: Result<Chef, FirestoreManager.FirestoreError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedChef):
                    chef.update(with: updatedChef)
                    completion(.success(chef))
                case .failure(let error):
                    print("Error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    final class Chef: ObservableObject, Identifiable, FirestoreEntity {
        var manager = ChefManager()
        
        @Published var id = ""
        @Published var name = ""
                
        
        @Published var user: User? = nil

        
        init() {}
        
        func update(with newChef: Chef) {
            DispatchQueue.main.async {
                self.id = newChef.id
                self.name = newChef.name
                self.user = newChef.user

            }
        }
        
        
        init?(fromDocumentSnapshot: DocumentSnapshot) {
            guard let data = fromDocumentSnapshot.data() else { return nil }
            
            self.id = fromDocumentSnapshot.documentID
            self.name = data["name"] as? String ?? ""
            self.user = (data["user"] as? [String: Any]).map { User(fromDictionary: $0) } ?? User()

            
        }
        
        
        func toFirestore() -> [String: Any] {
            return [
                "name": name,
                "user": user?.toFirestore() ?? [:],
            ]
        }
    }
    struct User: Identifiable, Dependant, FirestoreEntity {
        var id: String
        var name: String
        
        init(id: String = "", name: String = "") {
            self.id = id
            self.name = name
        }
        
        init?(fromDictionary fire: [String: Any]) {
            guard let id = fire["id"] as? String,
                  let name = fire["name"] as? String else { return nil }
            self.id = id
            self.name = name
        }
        
        init?(fromDocumentSnapshot documentSnapshot: DocumentSnapshot) {
            guard let data = documentSnapshot.data() else { return nil }
            self.init(fromDictionary: data)
        }
        
        func toFirestore() -> [String: Any] {
            return ["id": id, "name": name]
        }
    }
}
