//
//  FeedView.swift
//  Populist
//
//  Created by Nicholas Carducci on 10/24/25.
//
import SwiftUI

// MARK: - Feed View (Center Page)
struct FeedView: View {
    @EnvironmentObject var authState: UserAuthState
    @State private var bills = mockBills
    @State private var selectedChamber = "All"
    @State private var selectedTopic: String? = nil
    @State private var sortOption = "Most Recent Action"
    @State private var sortAscending = false
    @State private var showProfile = false
    @State private var showNotifications = false
    @State private var isRefreshing = false
    
    let chambers = ["All", "House", "Senate"]
    let topics = [
        ("Healthcare", Color.blue),
        ("Education", Color.purple),
        ("Environment", Color.green),
        ("Economy", Color.orange),
        ("Defense", Color.red),
        ("Immigration", Color.brown),
        ("Technology", Color.cyan),
        ("Infrastructure", Color.gray)
    ]
    let sortOptions = ["Most Recent Action", "Date Introduced", "Public Support"]
    
    var filteredBills: [Bill] {
        var filtered = bills
        if selectedChamber != "All" {
            filtered = filtered.filter { $0.chamber == selectedChamber }
        }
        if let topic = selectedTopic {
            filtered = filtered.filter { $0.topic == topic }
        }
        return filtered.sorted { sortAscending ? $0.actionDate < $1.actionDate : $0.actionDate > $1.actionDate }
    }
    
    func refreshFeed() async {
        isRefreshing = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // In real app, fetch new bills from API here
        // For now, just reset the data
        await MainActor.run {
            bills = mockBills
            isRefreshing = false
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with Navigation
                    ZStack {
                        LinearGradient(colors: [.blue, .purple, .pink], startPoint: .leading, endPoint: .trailing)
                        
                        HStack {
                            Button(action: {
                                if authState.isLoggedIn {
                                    showProfile = true
                                } else {
                                    authState.showRegistration = true
                                }
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Text("Pop-u-list")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Put the 'u' back in politics")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if authState.isLoggedIn {
                                    showNotifications = true
                                } else {
                                    authState.showRegistration = true
                                }
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.9))
                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 10, height: 10)
                                        .offset(x: 3, y: -3)
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 100)
                    
                    // Chamber and Topic Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(chambers, id: \.self) { chamber in
                                Button(action: { selectedChamber = chamber }) {
                                    Text(chamber)
                                        .font(.subheadline)
                                        .fontWeight(selectedChamber == chamber ? .semibold : .regular)
                                        .foregroundColor(selectedChamber == chamber ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedChamber == chamber ? Color.blue : Color.gray.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                            
                            Divider().frame(height: 20)
                            
                            ForEach(topics, id: \.0) { topic, color in
                                Button(action: {
                                    selectedTopic = selectedTopic == topic ? nil : topic
                                }) {
                                    Text(topic)
                                        .font(.subheadline)
                                        .fontWeight(selectedTopic == topic ? .semibold : .regular)
                                        .foregroundColor(selectedTopic == topic ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedTopic == topic ? color : Color.gray.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    
                    // Sort Controls
                    HStack {
                        Button(action: { sortAscending.toggle() }) {
                            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Menu {
                            ForEach(sortOptions, id: \.self) { option in
                                Button(option) { sortOption = option }
                            }
                        } label: {
                            HStack {
                                Text(sortOption)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    
                    // Bills Feed
                    LazyVStack(spacing: 16) {
                        ForEach(filteredBills) { bill in
                            BillCardView(bill: bill, bills: $bills)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, 60) // Space for footer navigation
                }
            }
            .refreshable {
                await refreshFeed()
            }
            .overlay(alignment: .top) {
                if isRefreshing {
                    ProgressView()
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .offset(y: 110)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
        }
    }
}
