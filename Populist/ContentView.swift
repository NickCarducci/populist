//
//  ContentView.swift
//  Populist
//
//  Created by Nicholas Carducci on 9/14/25.
//
import SwiftUI
import MapKit

// MARK: - Models
struct Bill: Identifiable {
    let id = UUID()
    let number: String
    let chamber: String
    let title: String
    let latestActionText: String
    let actionDate: Date
    let topic: String
    let topicColor: Color
    let supportPercentage: Int
    let representatives: [Representative]
    var isBookmarked: Bool = false
    var userVote: String? = nil
    let votesCount: Int = Int.random(in: 100...5000)
    let commentsCount: Int = Int.random(in: 10...500)
}

struct Representative: Identifiable {
    let id = UUID()
    let initials: String
    let name: String
    let party: String
    let state: String
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let billNumber: String
    let action: String
    let date: Date
}

struct EventPin: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let startDate: Date
    let endDate: Date
    let description: String?
    
    var daysUntilEvent: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: startDate).day ?? 0
    }
    
    var markerColor: Color {
        let days = daysUntilEvent
        switch days {
        case ...0: return .red // Past or today
        case 1...7: return .orange // This week
        case 8...30: return .yellow // This month
        case 31...90: return .green // Next 3 months
        default: return .blue // Far future
        }
    }
}

struct Organization: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let headquarters: String?
    let coordinate: CLLocationCoordinate2D?
    let memberCount: Int
    let category: String
    let isFollowing: Bool
    let recentActivity: Date
    let messages: [ChatMessage]
    
    var categoryColor: Color {
        switch category {
        case "Environmental": return .green
        case "Healthcare": return .blue
        case "Education": return .purple
        case "Economic": return .orange
        case "Civil Rights": return .red
        case "Technology": return .cyan
        default: return .gray
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let senderName: String
    let content: String
    let timestamp: Date
    let isCurrentUser: Bool
}

struct ForumPost: Identifiable {
    let id = UUID()
    let authorName: String
    let authorType: String // "Organization" or "Personal"
    let content: String
    let timestamp: Date
    let likes: Int
    let comments: Int
    let shares: Int
    let isLiked: Bool
    let organizationCategory: String?
}

// MARK: - User Authentication State
class UserAuthState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var showRegistration: Bool = false
}
// RegistrationView
// PhoneAuthView


// MARK: - Main App with Page Navigation
struct ContentView: View {
    @State private var currentPage: PageType = .feed
    @State private var dragOffset: CGFloat = 0
    @StateObject private var authState = UserAuthState()
    
    enum PageType {
        case messenger, feed, map
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Messenger Page (Left)
                    MessengerView()
                        .frame(width: geometry.size.width)
                        .environmentObject(authState)
                    
                    // Feed Page (Center)
                    FeedView()
                        .frame(width: geometry.size.width)
                        .environmentObject(authState)
                    
                    // Map Page (Right)
                    MapView()
                        .frame(width: geometry.size.width)
                        .environmentObject(authState)
                }
                .offset(x: -CGFloat(currentPage.rawValue) * geometry.size.width + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Only allow swiping from messenger to feed, and feed to messenger
                            // Map page requires footer navigation to return
                            if currentPage != .map {
                                dragOffset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            withAnimation(.spring()) {
                                if currentPage == .messenger && value.translation.width < -threshold {
                                    currentPage = .feed
                                } else if currentPage == .feed {
                                    if value.translation.width > threshold {
                                        currentPage = .messenger
                                    } else if value.translation.width < -threshold {
                                        currentPage = .map
                                    }
                                }
                                dragOffset = 0
                            }
                        }
                )
                .animation(.spring(), value: currentPage)
            }
            
            // Footer Navigation
            VStack {
                Spacer()
                FooterNavigation(currentPage: $currentPage)
            }
        }
        .sheet(isPresented: $authState.showRegistration) {
            RegistrationView()
        }
    }
}

// MARK: - Footer Navigation
struct FooterNavigation: View {
    @Binding var currentPage: ContentView.PageType
    @State private var waveformScale: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background Gradient
            if currentPage == .feed {
                // Corner gradients for feed view
                HStack {
                    // Left corner gradient (diagonal from bottom-left)
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0)],
                        startPoint: .bottomLeading,
                        endPoint: UnitPoint(x: 0.7, y: 0.3)
                    )
                    .frame(width: 120, height: 120)
                    .allowsHitTesting(false)
                    
                    Spacer()
                    
                    // Right corner gradient (diagonal from bottom-right)
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0)],
                        startPoint: .bottomTrailing,
                        endPoint: UnitPoint(x: 0.3, y: 0.3)
                    )
                    .frame(width: 120, height: 120)
                    .allowsHitTesting(false)
                }
            } else {
                // Radial gradient when buttons are centered
                RadialGradient(
                    colors: [Color.white, Color.white.opacity(0)],
                    center: .bottom,
                    startRadius: 30,
                    endRadius: 150
                )
                .frame(height: 150)
                .offset(y: 50)
                .allowsHitTesting(false)
            }
            
            // Buttons
            HStack(spacing: currentPage == .feed ? UIScreen.main.bounds.width - 140 : 40) {
                // Messenger Button
                Button(action: {
                    withAnimation(.spring()) {
                        currentPage = .messenger
                    }
                }) {
                    Image(systemName: "person.3.sequence.fill")
                        .font(.title2)
                        .foregroundColor(currentPage == .messenger ? .blue : .gray)
                        .frame(width: 44, height: 44)
                }
                
                // Feed Button (only visible when not on feed)
                if currentPage != .feed {
                    Button(action: {
                        withAnimation(.spring()) {
                            currentPage = .feed
                            waveformScale = 0
                        }
                    }) {
                        Image(systemName: "waveform")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .scaleEffect(waveformScale)
                            .frame(width: 50, height: 50)
                    }
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            waveformScale = 1
                        }
                    }
                }
                
                // Map Button
                Button(action: {
                    withAnimation(.spring()) {
                        currentPage = .map
                    }
                }) {
                    Image(systemName: "network")
                        .font(.title2)
                        .foregroundColor(currentPage == .map ? .blue : .gray)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, currentPage == .feed ? 30 : 0)
            .padding(.bottom, 20)
        }
        .animation(.spring(), value: currentPage)
    }
}

// Extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Messenger View (Left Page)
struct MessengerView: View {
    @EnvironmentObject var authState: UserAuthState
    @State private var organizations: [Organization] = [
        Organization(
            name: "Climate Action Network",
            description: "Grassroots organization fighting for environmental justice and sustainable policy",
            headquarters: "Portland, OR",
            coordinate: CLLocationCoordinate2D(latitude: 45.5152, longitude: -122.6784),
            memberCount: 1234,
            category: "Environmental",
            isFollowing: false,
            recentActivity: Date().addingTimeInterval(-3600),
            messages: [
                ChatMessage(senderName: "Alex Chen", content: "The new climate bill just passed committee!", timestamp: Date().addingTimeInterval(-7200), isCurrentUser: false),
                ChatMessage(senderName: "Sarah Johnson", content: "We should organize a rally to support it", timestamp: Date().addingTimeInterval(-3600), isCurrentUser: false)
            ]
        ),
        Organization(
            name: "Healthcare for All",
            description: "Advocating for universal healthcare access and affordable medication",
            headquarters: "Boston, MA",
            coordinate: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
            memberCount: 892,
            category: "Healthcare",
            isFollowing: true,
            recentActivity: Date().addingTimeInterval(-1800),
            messages: [
                ChatMessage(senderName: "Dr. Martinez", content: "New research on healthcare costs just published", timestamp: Date().addingTimeInterval(-1800), isCurrentUser: false),
                ChatMessage(senderName: "You", content: "This is really important data!", timestamp: Date().addingTimeInterval(-900), isCurrentUser: true)
            ]
        ),
        Organization(
            name: "Education Reform Alliance",
            description: "Working towards equitable education for all students",
            headquarters: "Chicago, IL",
            coordinate: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298),
            memberCount: 567,
            category: "Education",
            isFollowing: true,
            recentActivity: Date().addingTimeInterval(-86400),
            messages: [
                ChatMessage(senderName: "Principal Williams", content: "Teacher support bill needs our attention", timestamp: Date().addingTimeInterval(-86400), isCurrentUser: false)
            ]
        )
    ]
    
    @State private var showingCreateOrg = false
    @State private var showingGlobalForum = false
    @State private var selectedOrg: Organization? = nil
    @State private var showFollowingOnly = false
    @State private var searchText = ""
    
    var filteredOrganizations: [Organization] {
        var filtered = organizations
        
        if showFollowingOnly {
            filtered = filtered.filter { $0.isFollowing }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.recentActivity > $1.recentActivity }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        showingGlobalForum = true
                    }) {
                        Image(systemName: "globe.americas.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                    
                    Text("Organizations")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        if authState.isLoggedIn {
                            showingCreateOrg = true
                        } else {
                            authState.showRegistration = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // Filter Toggle
                Picker("Filter", selection: $showFollowingOnly) {
                    Text("For You").tag(false)
                    Text("Following").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search organizations...", text: $searchText)
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                // Organizations List or Login Prompt
                if showFollowingOnly && !authState.isLoggedIn {
                    // Show login prompt when "Following" is selected and user is not logged in
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Login required")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Sign in to view organizations you're following")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            authState.showRegistration = true
                        }) {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredOrganizations) { org in
                                OrganizationCard(
                                    organization: org,
                                    organizations: $organizations,
                                    onTap: { selectedOrg = org }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    if filteredOrganizations.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "person.3.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text(showFollowingOnly ? "No organizations followed yet" : "No organizations found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateOrg) {
                CreateOrganizationView(organizations: $organizations)
            }
            .sheet(isPresented: $showingGlobalForum) {
                GlobalForumView()
            }
            .sheet(item: $selectedOrg) { org in
                OrganizationChatView(organization: org, organizations: $organizations)
            }
        }
    }
}

// MARK: - Global Forum View
struct GlobalForumView: View {
    @EnvironmentObject var authState: UserAuthState
    @Environment(\.presentationMode) var presentationMode
    @State private var posts: [ForumPost] = [
        ForumPost(
            authorName: "Climate Action Network",
            authorType: "Organization",
            content: "🌍 URGENT: New climate legislation needs YOUR support! Contact your representatives today to voice your opinion on the Green Future Act. Together, we can make a difference! #ClimateAction #GreenFuture",
            timestamp: Date().addingTimeInterval(-3600),
            likes: 234,
            comments: 45,
            shares: 89,
            isLiked: false,
            organizationCategory: "Environmental"
        ),
        ForumPost(
            authorName: "Sarah Mitchell",
            authorType: "Personal",
            content: "Just attended an amazing town hall about healthcare reform. The passion in that room was incredible! If you care about accessible healthcare, find your local meetings and GET INVOLVED. Democracy works when we show up! 🏥✊",
            timestamp: Date().addingTimeInterval(-7200),
            likes: 156,
            comments: 23,
            shares: 34,
            isLiked: true,
            organizationCategory: nil
        ),
        ForumPost(
            authorName: "Education Reform Alliance",
            authorType: "Organization",
            content: "📚 Breaking: The Education Equity Bill just passed the House! This is a huge step forward for students nationwide. Thank you to everyone who called their representatives. The Senate vote is next - let's keep the momentum going!",
            timestamp: Date().addingTimeInterval(-10800),
            likes: 512,
            comments: 89,
            shares: 201,
            isLiked: true,
            organizationCategory: "Education"
        ),
        ForumPost(
            authorName: "Marcus Johnson",
            authorType: "Personal",
            content: "Reminder: Your vote is your voice! 🗳️ Early voting starts next week for local elections. These races matter just as much as the big ones. Check your registration status and make a plan to vote!",
            timestamp: Date().addingTimeInterval(-14400),
            likes: 89,
            comments: 12,
            shares: 45,
            isLiked: false,
            organizationCategory: nil
        ),
        ForumPost(
            authorName: "Healthcare for All",
            authorType: "Organization",
            content: "New study shows that 45% of Americans delayed medical care due to cost last year. This is why we fight for universal healthcare. Share your story using #HealthcareForAll - your representatives need to hear from you!",
            timestamp: Date().addingTimeInterval(-21600),
            likes: 367,
            comments: 78,
            shares: 156,
            isLiked: false,
            organizationCategory: "Healthcare"
        )
    ]
    
    @State private var newPostText = ""
    @State private var showingNewPost = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Create Post Button
                Button(action: {
                    if authState.isLoggedIn {
                        showingNewPost = true
                    } else {
                        authState.showRegistration = true
                    }
                }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Share your thoughts...")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                }
                
                Divider()
                
                // Posts Feed
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(posts) { post in
                            ForumPostCard(post: post, posts: $posts)
                            Divider()
                        }
                    }
                }
            }
            .navigationTitle("Global Forum")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingNewPost) {
                NewForumPostView(posts: $posts)
            }
        }
    }
}

// MARK: - Forum Post Card
struct ForumPostCard: View {
    let post: ForumPost
    @Binding var posts: [ForumPost]
    @State private var isLiked: Bool = false
    @State private var likeCount: Int = 0
    
    var timeFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            HStack {
                if post.authorType == "Organization" {
                    Circle()
                        .fill(categoryColor(post.organizationCategory ?? "Other").opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(post.authorName.prefix(2).uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(categoryColor(post.organizationCategory ?? "Other"))
                        )
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(post.authorName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if post.authorType == "Organization" {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(post.authorType)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(timeFormatter.localizedString(for: post.timestamp, relativeTo: Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Menu {
                    Button(action: {}) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {}) {
                        Label("Report", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            // Post Content
            Text(post.content)
                .font(.body)
                .lineLimit(nil)
            
            // Interaction Buttons
            HStack(spacing: 20) {
                Button(action: {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(likeCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.gray)
                        Text("\(post.comments)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.2.squarepath")
                            .foregroundColor(.gray)
                        Text("\(post.shares)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .onAppear {
            isLiked = post.isLiked
            likeCount = post.likes
        }
    }
    
    func categoryColor(_ category: String) -> Color {
        switch category {
        case "Environmental": return .green
        case "Healthcare": return .blue
        case "Education": return .purple
        case "Economic": return .orange
        case "Civil Rights": return .red
        case "Technology": return .cyan
        default: return .gray
        }
    }
}

// MARK: - New Forum Post View
struct NewForumPostView: View {
    @Binding var posts: [ForumPost]
    @Environment(\.presentationMode) var presentationMode
    @State private var postContent = ""
    @State private var characterCount = 0
    let maxCharacters = 280
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Author Info
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading) {
                        Text("You")
                            .font(.headline)
                        Text("Personal Account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Text Editor
                VStack(alignment: .trailing, spacing: 8) {
                    TextEditor(text: $postContent)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: postContent) { _, newValue in
                            if newValue.count > maxCharacters {
                                postContent = String(newValue.prefix(maxCharacters))
                            }
                            characterCount = postContent.count
                        }
                    
                    Text("\(characterCount)/\(maxCharacters)")
                        .font(.caption)
                        .foregroundColor(characterCount > maxCharacters - 20 ? .orange : .secondary)
                        .padding(.horizontal)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("New Post")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Post") {
                    if !postContent.isEmpty {
                        let newPost = ForumPost(
                            authorName: "You",
                            authorType: "Personal",
                            content: postContent,
                            timestamp: Date(),
                            likes: 0,
                            comments: 0,
                            shares: 0,
                            isLiked: false,
                            organizationCategory: nil
                        )
                        posts.insert(newPost, at: 0)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(postContent.isEmpty)
            )
        }
    }
}

// MARK: - Organization Card
struct OrganizationCard: View {
    let organization: Organization
    @Binding var organizations: [Organization]
    let onTap: () -> Void
    
    var timeFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Circle()
                        .fill(organization.categoryColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(organization.name.prefix(2).uppercased())
                                .font(.headline)
                                .foregroundColor(organization.categoryColor)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(organization.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if organization.isFollowing {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Text(organization.category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(organization.categoryColor.opacity(0.1))
                            .foregroundColor(organization.categoryColor)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(timeFormatter.localizedString(for: organization.recentActivity, relativeTo: Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.caption2)
                            Text("\(organization.memberCount)")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Text(organization.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if let lastMessage = organization.messages.last {
                    HStack {
                        Image(systemName: "bubble.left.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("\(lastMessage.senderName): \(lastMessage.content)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.top, 4)
                }
                
                if let headquarters = organization.headquarters {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(headquarters)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Organization Chat View
struct OrganizationChatView: View {
    let organization: Organization
    @Binding var organizations: [Organization]
    @EnvironmentObject var authState: UserAuthState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isFollowing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Organization Header
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(organization.categoryColor.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(organization.name.prefix(2).uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(organization.categoryColor)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(organization.name)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            HStack {
                                Text(organization.category)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(organization.categoryColor.opacity(0.1))
                                    .foregroundColor(organization.categoryColor)
                                    .cornerRadius(4)
                                
                                Text("•")
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "person.2.fill")
                                        .font(.caption2)
                                    Text("\(organization.memberCount) members")
                                        .font(.caption)
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    if !isFollowing {
                        Button(action: {
                            if authState.isLoggedIn {
                                withAnimation {
                                    isFollowing = true
                                    if let index = organizations.firstIndex(where: { $0.id == organization.id }) {
                                        var updatedOrg = organizations[index]
                                        updatedOrg = Organization(
                                            name: updatedOrg.name,
                                            description: updatedOrg.description,
                                            headquarters: updatedOrg.headquarters,
                                            coordinate: updatedOrg.coordinate,
                                            memberCount: updatedOrg.memberCount + 1,
                                            category: updatedOrg.category,
                                            isFollowing: true,
                                            recentActivity: updatedOrg.recentActivity,
                                            messages: updatedOrg.messages
                                        )
                                        organizations[index] = updatedOrg
                                    }
                                }
                            } else {
                                authState.showRegistration = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Follow Organization")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(organization.categoryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Text("Follow to join the conversation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                    }
                }
                .background(Color(UIColor.systemBackground))
                
                Divider()
                
                // Messages
                if isFollowing {
                    ScrollView {
                        ScrollViewReader { proxy in
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding()
                            .onAppear {
                                if let last = messages.last {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Message Input
                    HStack {
                        TextField("Type a message...", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            if !messageText.isEmpty {
                                let newMessage = ChatMessage(
                                    senderName: "You",
                                    content: messageText,
                                    timestamp: Date(),
                                    isCurrentUser: true
                                )
                                messages.append(newMessage)
                                messageText = ""
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                } else {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Follow to view and send messages")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Organization Chat", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                messages = organization.messages
                isFollowing = organization.isFollowing
            }
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isCurrentUser { Spacer() }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(message.content)
                    .padding(10)
                    .background(message.isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.isCurrentUser ? .white : .primary)
                    .cornerRadius(12)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isCurrentUser { Spacer() }
        }
    }
}

// MARK: - Create Organization View
struct CreateOrganizationView: View {
    @Binding var organizations: [Organization]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var orgName = ""
    @State private var orgDescription = ""
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: MKMapItem? = nil
    @State private var selectedCategory = "Environmental"
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let categories = ["Environmental", "Healthcare", "Education", "Economic", "Civil Rights", "Technology", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Organization Details")) {
                    TextField("Organization Name (Required)", text: $orgName)
                    
                    TextField("Description (Required)", text: $orgDescription, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Headquarters (Optional)")) {
                    TextField("Search for address...", text: $searchText)
                        .onSubmit {
                            searchLocation()
                        }
                    
                    if !searchResults.isEmpty {
                        ForEach(searchResults, id: \.self) { item in
                            Button(action: {
                                selectedLocation = item
                                searchText = item.name ?? ""
                                searchResults = []
                            }) {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "Unknown")
                                        .foregroundColor(.primary)
                                    if let address = item.placemark.title {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    
                    if let selected = selectedLocation {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(selected.placemark.title ?? selected.name ?? "Selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Create Organization")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Create") {
                    createOrganization()
                }
                .disabled(orgName.isEmpty || orgDescription.isEmpty)
            )
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func searchLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                errorMessage = "Location search failed"
                showingError = true
                return
            }
            searchResults = response.mapItems
        }
    }
    
    func createOrganization() {
        guard !orgName.isEmpty && !orgDescription.isEmpty else {
            errorMessage = "Please fill in all required fields"
            showingError = true
            return
        }
        
        let newOrg = Organization(
            name: orgName,
            description: orgDescription,
            headquarters: selectedLocation?.placemark.title,
            coordinate: selectedLocation?.placemark.coordinate,
            memberCount: 1,
            category: selectedCategory,
            isFollowing: true,
            recentActivity: Date(),
            messages: []
        )
        
        organizations.insert(newOrg, at: 0)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Map View (Right Page)
struct MapView: View {
    @EnvironmentObject var authState: UserAuthState
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369), // Washington DC
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var events: [EventPin] = [
        // Sample events
        EventPin(
            title: "Town Hall Meeting",
            coordinate: CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369),
            address: "123 Main St, Washington DC",
            startDate: Date().addingTimeInterval(86400), // Tomorrow
            endDate: Date().addingTimeInterval(90000),
            description: "Discuss healthcare bill with representatives"
        ),
        EventPin(
            title: "Climate Action Rally",
            coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365),
            address: "White House, Washington DC",
            startDate: Date().addingTimeInterval(604800), // Next week
            endDate: Date().addingTimeInterval(608400),
            description: "Support for environmental legislation"
        ),
        EventPin(
            title: "Education Reform Forum",
            coordinate: CLLocationCoordinate2D(latitude: 38.9096, longitude: -77.0434),
            address: "Convention Center, Washington DC",
            startDate: Date().addingTimeInterval(1209600), // 2 weeks
            endDate: Date().addingTimeInterval(1213200),
            description: "Community discussion on education bills"
        ),
        EventPin(
            title: "Healthcare Policy Debate",
            coordinate: CLLocationCoordinate2D(latitude: 38.8951, longitude: -77.0364),
            address: "Capitol Hill, Washington DC",
            startDate: Date().addingTimeInterval(2592000), // 30 days
            endDate: Date().addingTimeInterval(2595600),
            description: "Public debate on healthcare legislation"
        )
    ]
    @State private var showingAddEvent = false
    @State private var showingEventList = false
    @State private var selectedEvent: EventPin? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                MapViewRepresentable(region: $region, events: events, selectedEvent: $selectedEvent)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        // Event List Button
                        Button(action: { showingEventList = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "list.bullet")
                                Text("\(events.count)")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(20)
                            .shadow(radius: 3)
                        }
                        .padding()
                        
                        Spacer()
                        
                        // Add Event Button
                        Button(action: {
                            if authState.isLoggedIn {
                                showingAddEvent = true
                            } else {
                                authState.showRegistration = true
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 3)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Event Legend
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Event Timeline")
                            .font(.caption)
                            .fontWeight(.semibold)
                        HStack(spacing: 12) {
                            LegendItem(color: .red, text: "Today")
                            LegendItem(color: .orange, text: "This Week")
                            LegendItem(color: .yellow, text: "This Month")
                            LegendItem(color: .green, text: "3 Months")
                            LegendItem(color: .blue, text: "Future")
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding()
                    .padding(.bottom, 40) // Space for footer
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(events: $events, region: $region)
            }
            .sheet(isPresented: $showingEventList) {
                EventListView(events: events, region: $region, isPresented: $showingEventList)
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event)
            }
        }
    }
}

// MARK: - Event List View
struct EventListView: View {
    let events: [EventPin]
    @Binding var region: MKCoordinateRegion
    @Binding var isPresented: Bool
    @State private var searchText = ""
    
    var sortedEvents: [EventPin] {
        events.sorted { $0.startDate < $1.startDate }
    }
    
    var filteredEvents: [EventPin] {
        if searchText.isEmpty {
            return sortedEvents
        } else {
            return sortedEvents.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText) ||
                ($0.description ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search events...", text: $searchText)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Event Cards
                    ForEach(filteredEvents) { event in
                        EventCardView(event: event) {
                            // Center map on selected event
                            withAnimation {
                                region = MKCoordinateRegion(
                                    center: event.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                )
                            }
                            // Close the list
                            isPresented = false
                        }
                        .padding(.horizontal)
                    }
                    
                    if filteredEvents.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No events found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 50)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Upcoming Events")
            .navigationBarItems(
                leading: Text("\(filteredEvents.count) events")
                    .font(.caption)
                    .foregroundColor(.secondary),
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
}

// MARK: - Event Card View
struct EventCardView: View {
    let event: EventPin
    let onTap: () -> Void
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Date Box
                VStack(spacing: 2) {
                    Text(dateFormatter.string(from: event.startDate).split(separator: " ")[0])
                        .font(.caption)
                        .foregroundColor(.white)
                    Text(dateFormatter.string(from: event.startDate).split(separator: " ")[1])
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(width: 60, height: 60)
                .background(event.markerColor)
                .cornerRadius(10)
                
                // Event Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(timeFormatter.string(from: event.startDate)) - \(timeFormatter.string(from: event.endDate))")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption)
                        Text(event.address)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.secondary)
                    
                    if event.daysUntilEvent == 0 {
                        Text("Today")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(event.markerColor)
                    } else if event.daysUntilEvent > 0 {
                        Text("In \(event.daysUntilEvent) days")
                            .font(.caption)
                            .foregroundColor(event.markerColor)
                    } else {
                        Text("Past event")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - MapKit UIViewRepresentable
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let events: [EventPin]
    @Binding var selectedEvent: EventPin?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        // Update annotations
        mapView.removeAnnotations(mapView.annotations)
        for event in events {
            let annotation = MKPointAnnotation()
            annotation.coordinate = event.coordinate
            annotation.title = event.title
            annotation.subtitle = event.address
            mapView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            let identifier = "EventPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
            
            // Find the corresponding event and set color
            if let event = parent.events.first(where: {
                $0.coordinate.latitude == annotation.coordinate.latitude &&
                $0.coordinate.longitude == annotation.coordinate.longitude
            }) {
                annotationView?.markerTintColor = UIColor(event.markerColor)
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation else { return }
            
            if let event = parent.events.first(where: {
                $0.coordinate.latitude == annotation.coordinate.latitude &&
                $0.coordinate.longitude == annotation.coordinate.longitude
            }) {
                parent.selectedEvent = event
            }
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
    }
}

// MARK: - Add Event View
struct AddEventView: View {
    @Binding var events: [EventPin]
    @Binding var region: MKCoordinateRegion
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: MKMapItem? = nil
    @State private var eventTitle = ""
    @State private var eventDescription = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Location Search
                Section(header: Text("Location (Required)")) {
                    TextField("Search for address...", text: $searchText)
                        .onSubmit {
                            searchLocation()
                        }
                    
                    if !searchResults.isEmpty {
                        ForEach(searchResults, id: \.self) { item in
                            Button(action: {
                                selectedLocation = item
                                searchText = item.name ?? ""
                                searchResults = []
                            }) {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "Unknown")
                                        .foregroundColor(.primary)
                                    if let address = item.placemark.title {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    
                    if let selected = selectedLocation {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(selected.placemark.title ?? selected.name ?? "Selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Event Details
                Section(header: Text("Event Details")) {
                    TextField("Event Title (Required)", text: $eventTitle)
                    
                    DatePicker("Start Time", selection: $startDate)
                    DatePicker("End Time", selection: $endDate, in: startDate...)
                    
                    TextField("Description (Optional)", text: $eventDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Event")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveEvent()
                }
                .disabled(selectedLocation == nil || eventTitle.isEmpty)
            )
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func searchLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                errorMessage = "Location search failed"
                showingError = true
                return
            }
            searchResults = response.mapItems
        }
    }
    
    func saveEvent() {
        guard let location = selectedLocation,
              !eventTitle.isEmpty else {
            errorMessage = "Please fill in all required fields"
            showingError = true
            return
        }
        
        let newEvent = EventPin(
            title: eventTitle,
            coordinate: location.placemark.coordinate,
            address: location.placemark.title ?? "",
            startDate: startDate,
            endDate: endDate,
            description: eventDescription.isEmpty ? nil : eventDescription
        )
        
        events.append(newEvent)
        region.center = location.placemark.coordinate
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Event Detail View
struct EventDetailView: View {
    let event: EventPin
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Event Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(event.markerColor)
                            .frame(width: 12, height: 12)
                        Text(event.daysUntilEvent <= 0 ? "Happening Now" : "In \(event.daysUntilEvent) days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Label(event.address, systemImage: "location.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Time Details
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text(event.startDate, style: .date)
                        Text(" at ")
                        Text(event.startDate, style: .time)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.green)
                    }
                    
                    Label {
                        Text("Ends at ")
                        Text(event.endDate, style: .time)
                    } icon: {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
                
                if let description = event.description {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {}) {
                        Label("Add to Calendar", systemImage: "calendar.badge.plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {}) {
                        Label("Share Event", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Event Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// FeedView

//

// MARK: - AI Summary View
struct AISummaryView: View {
    let bill: Bill
    @Environment(\.presentationMode) var presentationMode
    @State private var employmentImpact = "Based on your technology employment background, this bill would affect data protection requirements for tech companies, potentially creating new compliance roles and increasing demand for privacy engineers."
    @State private var educationImpact = "Your political science education gives you insight into the legislative process - this bill represents a significant shift in federal privacy law, similar to GDPR in Europe."
    @State private var hobbyImpact = "As someone interested in environmental conservation, you'll appreciate that this bill includes provisions for reducing paper waste through digital-first privacy notices."
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Bill Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(bill.number)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(bill.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    
                    // AI Analysis Header
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                        Text("Personalized Impact Analysis")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    // Employment Impact
                    ImpactCard(
                        title: "Employment Impact",
                        icon: "briefcase.fill",
                        color: .blue,
                        description: employmentImpact,
                        expertise: "Technology"
                    )
                    
                    // Education Impact
                    ImpactCard(
                        title: "Education Perspective",
                        icon: "graduationcap.fill",
                        color: .purple,
                        description: educationImpact,
                        expertise: "Political Science"
                    )
                    
                    // Hobby Impact
                    ImpactCard(
                        title: "Hobby Connection",
                        icon: "leaf.fill",
                        color: .green,
                        description: hobbyImpact,
                        expertise: "Environmental Conservation"
                    )
                    
                    // Key Points
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Points")
                            .font(.headline)
                        
                        ForEach([
                            "Creates new data protection standards",
                            "Requires user consent for data collection",
                            "Establishes penalties for violations",
                            "Includes small business exemptions"
                        ], id: \.self) { point in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(point)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitle("How This Affects You", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ImpactCard: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    let expertise: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(expertise)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .foregroundColor(color)
                    .cornerRadius(4)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// BillDetailView

// MARK: - Profile View
struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var username = "CitizenUser"
    @State private var bio = "Engaged citizen interested in policy and democracy"
    @State private var employmentExpertise = "Technology"
    @State private var educationExpertise = "Political Science"
    @State private var hobbyExpertise = "Environmental Conservation"
    @State private var showImagePicker = false
    @State private var showBookmarks = false
    
    let expertiseOptions = ["Healthcare", "Education", "Technology", "Finance", "Environment", "Politics", "Arts", "Science"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Picture
                    VStack {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 120, height: 120)
                            
                            Text(username.prefix(2).uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: { showImagePicker = true }) {
                            Text("Change Picture")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Username
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Bio
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $bio)
                            .frame(height: 80)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Expertise Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Expertise")
                            .font(.headline)
                        
                        ExpertiseSelector(title: "Employment", selection: $employmentExpertise, options: expertiseOptions)
                        ExpertiseSelector(title: "Education", selection: $educationExpertise, options: expertiseOptions)
                        ExpertiseSelector(title: "Hobby", selection: $hobbyExpertise, options: expertiseOptions)
                    }
                    .padding(.horizontal)
                    
                    // Bookmarks Button
                    Button(action: { showBookmarks = true }) {
                        HStack {
                            Image(systemName: "bookmark.fill")
                            Text("View Bookmarked Bills")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showBookmarks) {
                BookmarksView()
            }
        }
    }
}

struct ExpertiseSelector: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack {
                    Text(selection)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Bookmarks View
struct BookmarksView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(mockBills.filter { $0.isBookmarked }) { bill in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Rectangle()
                                    .fill(bill.topicColor)
                                    .frame(width: 4)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(bill.number)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text(bill.title)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                    Text(bill.actionDate, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "bookmark.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Bookmarked Bills", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Notifications View
struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    let notifications = [
        NotificationItem(billNumber: "H.R. 1234", action: "Passed committee vote", date: Date()),
        NotificationItem(billNumber: "S. 567", action: "Amendment added", date: Date().addingTimeInterval(-3600)),
        NotificationItem(billNumber: "H.R. 891", action: "Scheduled for floor vote", date: Date().addingTimeInterval(-7200)),
        NotificationItem(billNumber: "S. 234", action: "New co-sponsor added", date: Date().addingTimeInterval(-86400))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(notifications) { notification in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(notification.billNumber)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(notification.date, style: .relative)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(notification.action)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Notifications", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {}) {
                    Text("Mark All Read")
                        .font(.caption)
                        .foregroundColor(.blue)
                },
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

// MARK: - Extensions for PageType
extension ContentView.PageType: RawRepresentable {
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .messenger
        case 1: self = .feed
        case 2: self = .map
        default: return nil
        }
    }
    
    var rawValue: Int {
        switch self {
        case .messenger: return 0
        case .feed: return 1
        case .map: return 2
        }
    }
}

// MARK: - Mock Data
let mockBills = [
    Bill(
        number: "H.R. 1234",
        chamber: "House",
        title: "Affordable Healthcare Expansion Act of 2025",
        latestActionText: "Referred to the Committee on Energy and Commerce",
        actionDate: Date(),
        topic: "Healthcare",
        topicColor: .blue,
        supportPercentage: 67,
        representatives: [
            Representative(initials: "JS", name: "John Smith", party: "D", state: "CA"),
            Representative(initials: "JD", name: "Jane Doe", party: "R", state: "TX"),
            Representative(initials: "BJ", name: "Bob Johnson", party: "I", state: "VT"),
            Representative(initials: "AW", name: "Alice Williams", party: "D", state: "NY"),
            Representative(initials: "MD", name: "Mike Davis", party: "R", state: "FL")
        ],
        isBookmarked: true
    ),
    Bill(
        number: "S. 567",
        chamber: "Senate",
        title: "Climate Action and Green Jobs Initiative",
        latestActionText: "Passed Senate, referred to House",
        actionDate: Date().addingTimeInterval(-86400),
        topic: "Environment",
        topicColor: .green,
        supportPercentage: 52,
        representatives: [
            Representative(initials: "RB", name: "Robert Brown", party: "D", state: "WA"),
            Representative(initials: "SJ", name: "Sarah Jones", party: "D", state: "OR"),
            Representative(initials: "TM", name: "Tom Miller", party: "R", state: "AZ")
        ]
    ),
    Bill(
        number: "H.R. 891",
        chamber: "House",
        title: "Digital Privacy Protection Act",
        latestActionText: "Committee hearing scheduled",
        actionDate: Date().addingTimeInterval(-172800),
        topic: "Technology",
        topicColor: .cyan,
        supportPercentage: 78,
        representatives: [
            Representative(initials: "LW", name: "Lisa Wilson", party: "D", state: "MA"),
            Representative(initials: "JT", name: "James Taylor", party: "R", state: "GA"),
            Representative(initials: "KM", name: "Karen Martinez", party: "D", state: "CO"),
            Representative(initials: "DL", name: "David Lee", party: "I", state: "ME")
        ],
        isBookmarked: true
    ),
    Bill(
        number: "S. 234",
        chamber: "Senate",
        title: "Infrastructure Modernization Act",
        latestActionText: "Under committee review",
        actionDate: Date().addingTimeInterval(-259200),
        topic: "Infrastructure",
        topicColor: .gray,
        supportPercentage: 45,
        representatives: [
            Representative(initials: "PH", name: "Paul Harris", party: "R", state: "OH"),
            Representative(initials: "NW", name: "Nancy White", party: "D", state: "MI")
        ]
    ),
    Bill(
        number: "H.R. 445",
        chamber: "House",
        title: "Education Reform and Teacher Support Act",
        latestActionText: "Amendments proposed in committee",
        actionDate: Date().addingTimeInterval(-345600),
        topic: "Education",
        topicColor: .purple,
        supportPercentage: 71,
        representatives: [
            Representative(initials: "CG", name: "Carol Garcia", party: "D", state: "IL"),
            Representative(initials: "BT", name: "Brian Thompson", party: "R", state: "NC"),
            Representative(initials: "AJ", name: "Amy Jackson", party: "D", state: "PA")
        ]
    )
]

// MARK: - App Preview
/*struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}*/

#Preview {
    ContentView()
}
