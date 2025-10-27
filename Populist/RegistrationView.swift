//
//  RegistrationView.swift
//  Populist
//
//  Created by Nicholas Carducci on 10/24/25.
//
import SwiftUI


// MARK: - Registration View
struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var journeyId: String? = UserDefaults.standard.string(forKey: "journeyId")
    @State private var verificationStatus: String = "Pending Verification"
    @State private var showPhoneAuth = false
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                // Title
                Text("Identity Verification Required")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Instructions
                VStack(spacing: 20) {
                    Text("To ensure authentic civic participation, we require identity verification.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.blue)
                            Text("Prepare your government-issued ID")
                                .font(.body)
                        }
                        
                        HStack {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.blue)
                            Text("Prepare yourself for a selfie")
                                .font(.body)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    if let _ = journeyId {
                        // Show verification status with refresh button
                        HStack {
                            Button(action: {
                                isRefreshing = true
                                // We will get firebase firestore documents here where journeyId is the unique document ID
                                
                                // Simulate async operation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    isRefreshing = false
                                    // If the document with that journeyId UserDefaults object exists in the firestore database, open a page for firebase auth
                                    showPhoneAuth = true
                                }
                            }) {
                                if isRefreshing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(width: 44, height: 44)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .frame(width: 44, height: 44)
                                }
                            }
                            .disabled(isRefreshing)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Verification Status")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(verificationStatus)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: {
                            // Begin verification flow would go here
                            // For now, just create a journey ID
                            let newJourneyId = UUID().uuidString
                            UserDefaults.standard.set(newJourneyId, forKey: "journeyId")
                            journeyId = newJourneyId
                        }) {
                            Text("Begin Verification")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        // Login flow would go here
                    }) {
                        Text("Already verified? Log in")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Not Now")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPhoneAuth) {
                PhoneAuthView()
            }
        }
    }
}
