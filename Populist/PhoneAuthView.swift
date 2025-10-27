//
//  PhoneAuthView.swift
//  Populist
//
//  Created by Nicholas Carducci on 10/24/25.
//
import SwiftUI


// MARK: - Phone Authentication View
struct PhoneAuthView: View {
    @State private var phoneNumber = ""
    @State private var showCodeEntry = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            if showCodeEntry {
                CodeEntryView(phoneNumber: phoneNumber)
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Icon
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    // Title
                    Text("Phone Verification")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Instructions
                    Text("Enter your phone number to receive a verification code")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Phone Number Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("+1 (555) 123-4567", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                    }
                    .padding(.horizontal)
                    
                    // Carrier Rates Notice
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("Standard carrier rates will apply")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Send Code Button
                    Button(action: {
                        // Firebase phone auth would be initiated here
                        showCodeEntry = true
                    }) {
                        Text("Send Verification Code")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(phoneNumber.isEmpty ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(phoneNumber.isEmpty)
                    .padding(.horizontal)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom)
                }
                .navigationBarHidden(true)
            }
        }
    }
}
