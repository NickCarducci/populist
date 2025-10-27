//
//  BillDetailView.swift
//  Populist
//
//  Created by Nicholas Carducci on 10/24/25.
//
import SwiftUI

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
                        ShareLink(item: URL(string: "https://congress.gov/bill/\(bill.number)")!) {
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
