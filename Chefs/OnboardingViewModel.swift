//
//  OnboardingViewModel.swift
//  Chefs
//
//  Created by Daniel Watson on 09.12.23.
//

import Foundation
import Combine
import Firebase

class AuthenticationManager: ObservableObject {
    
    struct FirebaseUser {
        var uid: String
    }
    
    func signUpWithEmailAndPassword(email: String, password: String) async {
        print("*OB 1*, Signing up with email: \(email) and password: [Redacted for security] [signUpWithEmailAndPassword] AuthenticationManager")
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            print("*OB 2A*, Sign up successful with UID: \(authResult.user.uid) [signUpWithEmailAndPassword] AuthenticationManager")
        } catch {
            print("*OB 2A*, Failed to sign up with Email and Password: \(error) [signUpWithEmailAndPassword] AuthenticationManager")
        }
    }

    func authenticate(completion: @escaping (FirebaseUser?) -> Void) {
        print("*OB 1*, Authenticating [authenticate] AuthenticationManager...")
        Auth.auth().addStateDidChangeListener { (auth, firebaseUser) in
            DispatchQueue.main.async {
                if let firebaseUser = firebaseUser {
                    print("*OB 2B*, User already signed in [authenticate] AuthenticationManager")
                    print("*OB 3*, Authenticated successfully with UID: \(firebaseUser.uid) [authenticate] AuthenticationManager")
                    completion(FirebaseUser(uid: firebaseUser.uid))
                } else {
                    print("*OB 2B*, Not Authenticated [authenticate] AuthenticationManager")
                    completion(nil)
                }
            }
        }
    }


    func signInWithEmailAndPassword(email: String, password: String) async {
        print("*OB 1*, Signing in with email: \(email) and password: [Redacted for security] [signInWithEmailAndPassword] AuthenticationManager")
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            print("*OB 2*, Sign in successful. [signInWithEmailAndPassword] AuthenticationManager")
        } catch {
            print("*OB 2*, Failed to sign in with Email and Password: \(error) [signInWithEmailAndPassword] AuthenticationManager")
        }
    }

    func signOut() {
        print("*OB 1*, Signing out... [signOut] AuthenticationManager")
        do {
            try Auth.auth().signOut()
            print("*OB 2*, Signed out successfully. [signOut] AuthenticationManager")
        } catch {
            print("*OB 2*, Error signing out: \(error.localizedDescription) [signOut] AuthenticationManager")
        }
    }
}


final class OnboardingViewModel: ObservableObject {
    
    var authenticationManager = AuthenticationManager()
    private var firestoreManager = FirestoreManager()
    
    private var miseboxUserManager = MiseboxUserManager()
    @Published var miseboxUser: MiseboxUserManager.MiseboxUser
    
    private var chefManager = ChefManager()
    @Published var chef: ChefManager.Chef
    
    @Published var onboardingStep = OnboardingStep.appLoading_1
        
    init(miseboxUser: MiseboxUserManager.MiseboxUser, chef: ChefManager.Chef) {
        self.miseboxUser = miseboxUser
        self.chef = chef
        authenticateUser()
    }
    
    private func authenticateUser() {
        authenticationManager.authenticate { [weak self] firebaseUser in
            DispatchQueue.main.async {
                if let uid = firebaseUser?.uid {
                    self?.miseboxUser.id = uid
                    self?.initializeMiseboxUser()
                } else {
                    self?.onboardingStep = .signup_2
                }
            }
        }
    }
    
    private func initializeMiseboxUser() {
        miseboxUserManager.initialiseMiseboxUser(user: miseboxUser) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.miseboxUser = user
                    
                    if let miseboxChef = user.chef {
                        self?.chef.id = miseboxChef.id
                        self?.initializeChef()
                        self?.onboardingStep = .contentView_4
                    } else {
                        print("User has no Chef profile")
                        self?.onboardingStep = .createChef_3
                    }
                case .failure:
                    self?.onboardingStep = .signup_2
                }
            }
        }
    }
    
    func createChef() {
        firestoreManager.setDoc(collection: "chefs", entity: self.chef) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Chef created successfully.")
                    // now must add the chef to the user
                case .failure(let error):
                    print("Failed to create chef: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func initializeChef() {
        print("Initializing Chef with ID: \(chef.id)")
        chefManager.initialiseChef(chef: chef) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedChef):
                    self?.onboardingStep = .contentView_4
                    print("Chef initialized successfully: \(updatedChef)")
                    
                case .failure(let error):
                    print("Failure: Chef initialization failed with error: \(error)")
                    self?.onboardingStep = .createChef_3
                }
            }
        }
    }



    enum OnboardingStep {
        case appLoading_1
        case signup_2
        case createChef_3
        case contentView_4
    }
    
    func signOut() {
        authenticationManager.signOut()
        miseboxUser = MiseboxUserManager.MiseboxUser()
        chef = ChefManager.Chef()
        onboardingStep = .appLoading_1
    }
}

