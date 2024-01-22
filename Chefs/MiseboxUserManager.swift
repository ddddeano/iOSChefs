//
//  MiseboxUserManager.swift
//  Chefs
//
//  Created by Daniel Watson on 09.12.23.
//

import Foundation
import Firebase


final class MiseboxUserManager {
    
    private var firestoreManager = FirestoreManager()
    private var rootCollection = "misebox-users"
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func initialiseMiseboxUser(user: MiseboxUser, completion: @escaping (Result<MiseboxUser, Error>) -> Void) {

        checkIfDocExists(documentID: user.id) { [weak self] exists in

            guard let self = self else {
                completion(.failure(MiseboxError.selfIsNil))
                return
            }

            if exists {
                self.attachListenerAndUpdateUser(userId: user.id, user: user, completion: completion)
            } else {
                self.setNewMiseboxUser(userId: user.id, user: user) { result in
                    switch result {
                    case .success:
                        self.attachListenerAndUpdateUser(userId: user.id, user: user, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    private func attachListenerAndUpdateUser(userId: String, user: MiseboxUser, completion: @escaping (Result<MiseboxUser, Error>) -> Void) {
           self.listener = self.firestoreManager.listenToDocument(collection: self.rootCollection, documentID: userId) { (result: Result<MiseboxUser, FirestoreManager.FirestoreError>) in
               DispatchQueue.main.async {
                   switch result {
                   case .success(let updatedUser):
                       user.update(with: updatedUser)
                       completion(.success(user))
                   case .failure(let error):
                       completion(.failure(error))
                   }
               }
           }
       }
    func checkIfDocExists(documentID: String, completion: @escaping (Bool) -> Void) {
        firestoreManager.checkDocumentExists(collection: rootCollection, documentID: documentID, completion: completion)
    }

    func setNewMiseboxUser(userId: String ,user: MiseboxUser, completion: @escaping (Result<Void, Error>) -> Void) {
        
         firestoreManager.setDoc(collection: rootCollection, entity: user) { result in
             switch result {
             case .success:
                 print("MiseboxUserManager: setNewMiseboxUser - User set successfully.")
                 completion(.success(()))
             case .failure(let error):
                 print("Error: \(error)")
                 completion(.failure(error))
             }
         }
     }

    struct Chef: Identifiable, Dependant, FirestoreEntity {
        var id: String
        var name: String
        
        init(id: String = "", name: String = "", inMode: Bool = true) {
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

    func addChefToUser(chef: Chef, miseboxUserId: String) {
        let updateData: [String: Any] = ["chef": chef.toFirestore()]
        firestoreManager.updateDocument(collection: rootCollection, documentID: miseboxUserId, updateData: updateData)
    }
    struct Kitchen: Identifiable, Dependant, FirestoreEntity {
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

    func addKitchenToUser(kitchen: Kitchen, miseboxUserId: String) {
        let updateData: [String: Any] = ["kitchen": kitchen.toFirestore()]
        firestoreManager.updateDocument(collection: rootCollection, documentID: miseboxUserId, updateData: updateData)
    }
    
    func toggleMode() {
        
    }
}
