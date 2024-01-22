//
//  FirestoreManager.swift
//  Chefs
//
//  Created by Daniel Watson on 09.12.23.
//


import Foundation
import Firebase

class FirestoreManager {
    private let db = Firestore.firestore()
    
    enum FirestoreError: Error {
        case unknown
        case invalidSnapshot
        case networkError
        case documentNotFound
    }
    
    func checkDocumentExists(collection: String, documentID: String, completion: @escaping (Bool) -> Void) {
        let docRef = db.collection(collection).document(documentID)
        docRef.getDocument { documentSnapshot, error in
            completion(documentSnapshot != nil && documentSnapshot!.exists)
        }
    }
    
    func listenToDocument<T: FirestoreEntity>(collection: String, documentID: String, completion: @escaping (Result<T, FirestoreError>) -> Void) -> ListenerRegistration {
        let docRef = db.collection(collection).document(documentID)
        return docRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("listenToDocument: Network error for documentID: \(documentID), Error: \(error)")
                completion(.failure(.networkError))
                return
            }
            guard let document = documentSnapshot else {
                print("listenToDocument: Invalid snapshot for documentID: \(documentID)")
                completion(.failure(.invalidSnapshot))
                return
            }

            if !document.exists {
                print("listenToDocument: Document does not exist, DocumentID: \(documentID)")
                completion(.failure(.documentNotFound))
                return
            }

            if let entity = T(fromDocumentSnapshot: document) {
                print("listenToDocument: Successfully created entity from document, DocumentID: \(documentID)")
                completion(.success(entity))
            } else {
                print("listenToDocument: Failed to create entity from document, DocumentID: \(documentID)")
                completion(.failure(.unknown))
            }
        }
    }
    func setDoc<T: FirestoreEntity>(collection: String, entity: T, completion: @escaping (Result<Void, FirestoreError>) -> Void) {
        let docRef = db.collection(collection).document(entity.id)
        docRef.setData(entity.toFirestore()) { error in
            if let error = error {
                print(error)
                completion(.failure(.networkError))
            } else {
                completion(.success(()))
            }
        }
    }
    func updateDocument(collection: String, documentID: String, updateData: [String: Any]) {
           let docRef = db.collection(collection).document(documentID)
           docRef.updateData(updateData) { error in
               if let error = error {
                   print("Error updating document: \(error)")
               } else {
                   print("Document successfully updated")
               }
           }
       }
}

protocol FirestoreEntity {
    var id: String { get set }
    init?(fromDocumentSnapshot documentSnapshot: DocumentSnapshot)
    func toFirestore() -> [String: Any]
}

protocol Dependant {
    var id: String { get set }
    init?(fromDictionary dictionary: [String: Any])
    func toFirestore() -> [String: Any]
}


/*func fetchAllDocuments<T: FirestoreEntity>(collection: String, completion: @escaping (Result<[T], FirestoreError>) -> Void) -> ListenerRegistration {
    let collectionRef = db.collection(collection)

    let listener = collectionRef.addSnapshotListener { (querySnapshot, error) in
        if let error = error {
            completion(.failure(.networkError))
            return
        }

        guard let documents = querySnapshot?.documents else {
            completion(.failure(.invalidSnapshot))
            return
        }

        let entities = documents.compactMap { T(fromDocumentSnapshot: $0) }
        completion(.success(entities))
    }

    return listener
}*/


/*func createDoc<T: FirestoreEntity>(collection: String, entity: T, completion: @escaping (Result<String, FirestoreError>) -> Void) {
    var ref: DocumentReference? = nil
    ref = db.collection(collection).addDocument(data: entity.toFirestore()) { err in
        if let err = err {
            print("Error adding document: \(err)")
            completion(.failure(.networkError))
        } else if let documentId = ref?.documentID {
            print("Document added with ID: \(documentId)")
            completion(.success(documentId))
        } else {
            print("Failed to obtain document ID.")
            completion(.failure(.unknown))
        }
    }
}*/

/*func addDependantToEntity<D: Dependant>(collection: String, documentID: String, field: String, item: D) {
    let docRef = db.collection(collection).document(documentID)
    
    docRef.getDocument { (document, error) in
        if let error = error {
            print("Error retrieving document: \(error)")
            return
        }
        
        var fieldData: [[String: Any]] = []
        if let data = document?.data(), let existingData = data[field] as? [[String: Any]] {
            fieldData = existingData
        }
        
        fieldData.append(item.toFirestore())
        
        docRef.setData([field: fieldData], merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Successfully updated document.")
            }
        }
    }
}*/
/*func removeDependantFromEntity(collection: String, documentID: String, field: String, itemIdToRemove: String) {
    let docRef = db.collection(collection).document(documentID)
    
    docRef.getDocument { (document, error) in
        if let error = error {
            print("Error retrieving document: \(error)")
            return
        }
        
        guard var fieldData = document?.data()?["\(field)"] as? [[String: Any]] else {
            print("Field data not found in document.")
            return
        }
        
        // Remove the item with the specified itemIdToRemove
        fieldData.removeAll { $0["id"] as? String == itemIdToRemove }
        
        docRef.setData([field: fieldData], merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Successfully updated document.")
            }
        }
    }
}*/
