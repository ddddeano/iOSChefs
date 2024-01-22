//
//  ContentView.swift
//  Chefs
//
//  Created by Daniel Watson on 09.12.23.
//

import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {
    private var firestoreManager = FirestoreManager()
    var miseboxUserManager = MiseboxUserManager()
    var chefManager = ChefManager()
    
}
struct ContentView: View {
    @EnvironmentObject var chef: ChefManager.Chef
    @StateObject var vm = ContentViewModel()

    var body: some View {
        NavigationView {
            VStack {
                AppHeaderView().environmentObject(chef)

                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    
                    ExploreView()
                        .tabItem {
                            Label("Explore", systemImage: "magnifyingglass")
                        }
                    
                    ScheduleView()
                        .tabItem {
                            Label("Schedule", systemImage: "calendar")
                        }
                    
                    JobsView()
                        .tabItem {
                            Label("Jobs", systemImage: "briefcase")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                }
                .accentColor(.purple) // Highlight color for selected tab
            }
            .navigationBarHidden(true) // Hides the default navigation bar
        }
    }
}


struct AppHeaderView: View {
    @EnvironmentObject var chef: ChefManager.Chef

    var body: some View {
        NavigationLink(destination: AppSettingsView()) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: .gray, radius: 2, x: 0, y: 5)
                    .frame(height: 60)
                
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .padding(.leading, 15)
                        .foregroundColor(.white)
                    
                    Text("Welcome \(chef.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 10)
    }
}


struct AppSettingsView: View {
    @EnvironmentObject var user: MiseboxUserManager.MiseboxUser
    @EnvironmentObject var chef: ChefManager.Chef

    var body: some View {
        Text("some settings")
        .navigationBarTitle("App Settings", displayMode: .inline)
    }
}

struct HomeView: View {
    var body: some View {
        Text("Home")
    }
}

struct ExploreView: View {
    var body: some View {
        Text("Explore")
    }
}

struct ScheduleView: View {
    var body: some View {
        Text("Schedule")
    }
}

struct JobsView: View {
    var body: some View {
        Text("Jobs")
    }
}

struct ProfileView: View {
    @EnvironmentObject var chef: ChefManager.Chef

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Image
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(.top, 20)

                // Name
                Text(chef.name)
                    .font(.title2)
                    .fontWeight(.bold)

                // Edit Profile Button
                NavigationLink(destination: EditProfileView()) {
                    Text("Edit Profile")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Additional sections can be added here
            }
            .padding(.bottom, 20)
        }
    }
}

// Placeholder for EditProfileView
struct EditProfileView: View {
    var body: some View {
        Text("Edit Profile View")
    }
}

