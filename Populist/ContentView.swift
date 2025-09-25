//
//  ContentView.swift
//  Populist
//
//  Created by Nicholas Carducci on 9/14/25.
//
import SwiftUI

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

// MARK: - Main App
struct ContentView: View {
    @State private var bills = mockBills
    @State private var selectedChamber = "All"
    @State private var selectedTopic: String? = nil
    @State private var sortOption = "Most Recent Action"
    @State private var sortAscending = false
    @State private var showProfile = false
    @State private var showNotifications = false
    
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with Navigation
                    ZStack {
                        LinearGradient(colors: [.blue, .purple, .pink], startPoint: .leading, endPoint: .trailing)
                        
                        HStack {
                            Button(action: { showProfile = true }) {
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
                            
                            Button(action: { showNotifications = true }) {
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

// MARK: - Bill Card
struct BillCardView: View {
    let bill: Bill
    @Binding var bills: [Bill]
    @State private var showVoting = false
    @State private var showAISummary = false
    @State private var selectedExpertise: String? = nil
    @State private var selectedExperienceLevel = "Employment"
    @State private var showBillDetail = false
    @State private var showPersonalizedImpact = false
    
    let expertiseOptions = ["All", "Healthcare", "Education", "Technology", "Finance"]
    let experienceLevels = ["Employment", "Education", "Hobby"]
    
    var shareText: String {
        "Check out this bill: \(bill.number) - \(bill.title)\n\nLatest Action: \(bill.latestActionText)\nDate: \(bill.actionDate.formatted(date: .abbreviated, time: .omitted))\n\nShared via Pop-u-list"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Topic Banner
            Rectangle()
                .fill(bill.topicColor)
                .frame(height: 80)
                .overlay(
                    Text(bill.topic)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 12) {
                // Bill Info
                HStack {
                    Text(bill.number)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(bill.chamber)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Text(bill.title)
                    .font(.title3)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bill.latestActionText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(bill.actionDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Action Buttons
                Button(action: { showPersonalizedImpact = true }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("How does this affect me?")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                
                Button(action: { withAnimation { showVoting.toggle() } }) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text("Cast your Vote")
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Voting Module
                if showVoting {
                    HStack(spacing: 30) {
                        Button(action: {
                            if let index = bills.firstIndex(where: { $0.id == bill.id }) {
                                bills[index].userVote = "oppose"
                            }
                            showVoting = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            if let index = bills.firstIndex(where: { $0.id == bill.id }) {
                                bills[index].isBookmarked.toggle()
                            }
                        }) {
                            Image(systemName: bill.isBookmarked ? "heart.fill" : "heart")
                                .font(.system(size: 40))
                                .foregroundColor(.pink)
                        }
                        
                        Button(action: {
                            if let index = bills.firstIndex(where: { $0.id == bill.id }) {
                                bills[index].userVote = "support"
                            }
                            showVoting = false
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                // Public Opinion Poll
                VStack(alignment: .leading, spacing: 8) {
                    Text("Public Opinion Poll")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * CGFloat(bill.supportPercentage) / 100)
                            Rectangle()
                                .fill(Color.red)
                        }
                        .frame(height: 30)
                        .cornerRadius(15)
                        .overlay(
                            HStack {
                                Text("\(bill.supportPercentage)%")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.leading, 8)
                                Spacer()
                                Text("\(100 - bill.supportPercentage)%")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 8)
                            }
                        )
                    }
                    .frame(height: 30)
                    
                    // Expertise Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(expertiseOptions, id: \.self) { expertise in
                                Button(action: {
                                    selectedExpertise = selectedExpertise == expertise ? nil : expertise
                                }) {
                                    Text(expertise)
                                        .font(.subheadline)
                                        .fontWeight(selectedExpertise == expertise ? .semibold : .regular)
                                        .foregroundColor(selectedExpertise == expertise ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedExpertise == expertise ? Color.blue : Color.gray.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    
                    // Experience Level (shown when expertise is selected)
                    if selectedExpertise != nil && selectedExpertise != "All" {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(experienceLevels, id: \.self) { level in
                                    Button(action: { selectedExperienceLevel = level }) {
                                        Text(level)
                                            .font(.caption)
                                            .fontWeight(selectedExperienceLevel == level ? .semibold : .regular)
                                            .foregroundColor(selectedExperienceLevel == level ? .white : .primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedExperienceLevel == level ? Color.purple : Color.gray.opacity(0.1))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                // Representatives in Agreement
                VStack(alignment: .leading, spacing: 8) {
                    Text("Representatives voting with you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(bill.representatives) { rep in
                                HStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 28, height: 28)
                                        Text(rep.initials)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                    }
                                    Text(rep.name)
                                        .font(.caption)
                                        .lineLimit(1)
                                    Text("(\(rep.party)-\(rep.state))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(16)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            showBillDetail = true
        }
        .contextMenu {
            ShareLink(item: shareText) {
                Label("Share Bill", systemImage: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $showBillDetail) {
            BillDetailView(bill: bill)
        }
        .sheet(isPresented: $showPersonalizedImpact) {
            PersonalizedImpactView(bill: bill, selectedExpertise: selectedExpertise, selectedExperienceLevel: selectedExperienceLevel)
        }
    }
}

// MARK: - Bill Detail View
struct BillDetailView: View {
    let bill: Bill
    @Environment(\.presentationMode) var presentationMode
    @State private var commentText = ""
    @State private var comments = [
        ("User123", "This bill would really help small businesses in my area.", Date()),
        ("PolicyWonk", "The environmental provisions need more funding.", Date()),
        ("Citizen2025", "Finally some action on this important issue!", Date())
    ]
    
    let relatedBills = [
        ("H.R. 999", "Supporting Small Business Act", Date(), Color.orange, 234, 45),
        ("S. 321", "Environmental Protection Enhancement", Date(), Color.green, 189, 32),
        ("H.R. 555", "Innovation and Technology Act", Date(), Color.cyan, 156, 28)
    ]
    
    var shareText: String {
        "Check out this bill: \(bill.number) - \(bill.title)\n\nLatest Action: \(bill.latestActionText)\nDate: \(bill.actionDate.formatted(date: .abbreviated, time: .omitted))\n\nShared via Pop-u-list"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Bill Header
                    Rectangle()
                        .fill(bill.topicColor)
                        .frame(height: 120)
                        .overlay(
                            VStack {
                                Text(bill.topic)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(bill.number)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(bill.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Latest Action")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(bill.latestActionText)
                                .font(.subheadline)
                            Text(bill.actionDate, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Share Button
                        ShareLink(item: shareText) {
                            Label("Share this Bill", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        // Forum Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Community Forum")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(comments, id: \.0) { comment in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(.gray)
                                        Text(comment.0)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text(comment.2, style: .relative)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(comment.1)
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                            
                            // Comment Input
                            HStack {
                                TextField("Add your comment...", text: $commentText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button(action: {
                                    if !commentText.isEmpty {
                                        comments.append(("You", commentText, Date()))
                                        commentText = ""
                                    }
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                        
                        // Related Bills
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Related Bills")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(relatedBills, id: \.0) { relBill in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Rectangle()
                                                .fill(relBill.3)
                                                .frame(height: 60)
                                                .overlay(
                                                    Text(bill.topic)
                                                        .font(.subheadline)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                )
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(relBill.0)
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                Text(relBill.1)
                                                    .font(.caption2)
                                                    .lineLimit(2)
                                                Text(relBill.2, style: .date)
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                                HStack {
                                                    Label("\(relBill.4)", systemImage: "hand.raised")
                                                    Label("\(relBill.5)", systemImage: "bubble.left")
                                                }
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.bottom, 8)
                                        }
                                        .frame(width: 180)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Bill Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Personalized Impact View
struct PersonalizedImpactView: View {
    let bill: Bill
    let selectedExpertise: String?
    let selectedExperienceLevel: String
    @Environment(\.presentationMode) var presentationMode
    
    var personalizedImpact: String {
        let expertise = selectedExpertise ?? "General"
        let level = selectedExperienceLevel
        
        switch (bill.topic, expertise, level) {
        case ("Healthcare", "Healthcare", "Employment"):
            return "As a healthcare professional, this bill directly impacts your field. The Affordable Healthcare Expansion Act could create new job opportunities in healthcare administration, expand patient care services, and potentially increase demand for healthcare workers. You might see changes in insurance coverage requirements, new training programs, or expanded roles for healthcare professionals."
            
        case ("Healthcare", "Technology", "Employment"):
            return "In your tech role, this healthcare bill could create opportunities for digital health solutions, electronic health records systems, and telemedicine platforms. The expansion of healthcare services will likely require new software, data management systems, and patient portal technologies."
            
        case ("Environment", "Environment", "Employment"):
            return "Your environmental expertise makes you uniquely qualified to understand this Climate Action bill's implications. This could lead to new green job opportunities, environmental consulting roles, and positions in renewable energy sectors. Your knowledge of environmental regulations and sustainability practices will be highly valuable."
            
        case ("Environment", "Technology", "Employment"):
            return "As a tech professional, this environmental bill presents opportunities in green technology, carbon tracking software, renewable energy management systems, and environmental data analytics. You could be involved in developing solutions for climate monitoring and sustainable technology."
            
        case ("Technology", "Technology", "Employment"):
            return "This Digital Privacy Protection Act directly affects your tech career. You'll likely see new compliance requirements, privacy-focused development practices, and opportunities in cybersecurity and data protection. Your technical skills will be crucial for implementing privacy-preserving technologies."
            
        case ("Education", "Education", "Employment"):
            return "Your education background makes you well-positioned to understand this Education Reform bill's impact. This could affect curriculum standards, teacher training programs, and educational technology integration. Your expertise in pedagogy and educational systems will be valuable for implementation."
            
        case ("Infrastructure", "Technology", "Employment"):
            return "The Infrastructure Modernization Act could create significant opportunities in smart city technologies, IoT systems, and digital infrastructure. Your tech skills could be applied to traffic management systems, energy grid modernization, and digital connectivity solutions."
            
        case (_, "Finance", "Employment"):
            return "Your financial expertise is crucial for understanding the economic implications of this bill. You'll be able to analyze funding mechanisms, budget impacts, and economic benefits. This could create opportunities in financial planning, budget analysis, or economic consulting related to the bill's implementation."
            
        case (_, _, "Education"):
            return "From an educational perspective, this bill represents an important learning opportunity about policy-making and civic engagement. Understanding how this legislation works can enhance your knowledge of government processes and help you make more informed decisions as a citizen."
            
        case (_, _, "Hobby"):
            return "Your hobby interest in this topic gives you a unique perspective on how this bill might affect your personal interests and community. Whether it's environmental conservation, technology innovation, or social issues, this legislation could impact the activities and causes you care about."
            
        default:
            return "This bill affects various aspects of society, and your background provides valuable perspective on its potential impacts. Consider how changes in this area might influence your community, workplace, or personal interests. Your unique viewpoint contributes to a more comprehensive understanding of the bill's effects."
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Rectangle()
                        .fill(bill.topicColor)
                        .frame(height: 120)
                        .overlay(
                            VStack {
                                Text("Personalized Impact")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(bill.number)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        )
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Bill Title
                        Text(bill.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // User Context
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Based on Your Profile")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Expertise:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(selectedExpertise ?? "General")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Text("Experience Level:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(selectedExperienceLevel)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Personalized Impact
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How This Affects You")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text(personalizedImpact)
                                .font(.body)
                                .lineSpacing(4)
                                .padding(.horizontal)
                        }
                        
                        // Action Items
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What You Can Do")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ActionItem(icon: "hand.raised.fill", title: "Cast Your Vote", description: "Share your opinion on this bill")
                                ActionItem(icon: "heart.fill", title: "Bookmark for Updates", description: "Track this bill's progress")
                                ActionItem(icon: "bubble.left.fill", title: "Join Discussion", description: "Share your expertise in comments")
                                ActionItem(icon: "square.and.arrow.up", title: "Share with Others", description: "Help others understand the impact")
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarTitle("Personalized Impact", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ActionItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


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
                trailing: Button("Done") {})
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
