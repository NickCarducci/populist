//
//  BillCardView.swift
//  Populist
//
//  Created by Nicholas Carducci on 10/24/25.
//
import SwiftUI

// MARK: - Bill Card
struct BillCardView: View {
    let bill: Bill
    @Binding var bills: [Bill]
    @EnvironmentObject var authState: UserAuthState
    @State private var showVoting = false
    @State private var showAISummary = false
    @State private var selectedExpertise: String? = nil
    @State private var selectedExperienceLevel = "Employment"
    @State private var showBillDetail = false
    
    let expertiseOptions = ["All", "Healthcare", "Education", "Technology", "Finance"]
    let experienceLevels = ["Employment", "Education", "Hobby"]
    
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
                Button(action: { showAISummary.toggle() }) {
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
                .sheet(isPresented: $showAISummary) {
                    AISummaryView(bill: bill)
                }
                
                Button(action: {
                    if authState.isLoggedIn {
                        withAnimation { showVoting.toggle() }
                    } else {
                        authState.showRegistration = true
                    }
                }) {
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
                            if authState.isLoggedIn {
                                if let index = bills.firstIndex(where: { $0.id == bill.id }) {
                                    bills[index].isBookmarked.toggle()
                                }
                            } else {
                                authState.showRegistration = true
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
            ShareLink(item: URL(string: "https://congress.gov/bill/\(bill.number)")!) {
                Label("Share Bill", systemImage: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $showBillDetail) {
            BillDetailView(bill: bill)
        }
    }
}
