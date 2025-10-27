//
//  CodeEntryView.swift
//  Populist
//
//  Created by Nicholas Carducci on 10/24/25.
//
import SwiftUI


// MARK: - Code Entry View
struct CodeEntryView: View {
    let phoneNumber: String
    @State private var verificationCode = ""
    @State private var codeBoxes: [String] = Array(repeating: "", count: 6)
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focusedIndex: Int?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Icon
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            // Title
            Text("Enter Verification Code")
                .font(.title)
                .fontWeight(.bold)
            
            // Instructions
            Text("We sent a 6-digit code to")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(phoneNumber)
                .font(.headline)
            
            // Code Entry Boxes
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $codeBoxes[index])
                        .frame(width: 45, height: 55)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(focusedIndex == index ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                        .focused($focusedIndex, equals: index)
                        .onChange(of: codeBoxes[index]) { _, newValue in
                            // Limit to 1 character
                            if newValue.count > 1 {
                                codeBoxes[index] = String(newValue.prefix(1))
                            }
                            // Auto-advance to next field
                            if newValue.count == 1 && index < 5 {
                                focusedIndex = index + 1
                            }
                            // Update the full code
                            verificationCode = codeBoxes.joined()
                        }
                        .onTapGesture {
                            focusedIndex = index
                        }
                }
            }
            .padding()
            
            // Timer/Resend Info
            Text("Didn't receive a code?")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
            
            Spacer()
            
            // Verify Button
            Button(action: {
                // Firebase code verification would happen here
                // For now, just close everything
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    if let rootView = window.rootViewController?.presentedViewController {
                        rootView.dismiss(animated: true)
                    }
                }
            }) {
                Text("Verify")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(verificationCode.count == 6 ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(verificationCode.count != 6)
            .padding(.horizontal)
            
            // Request New Code Button
            Button(action: {
                // Go back to phone entry
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Request a new code or cancel")
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
        }
        .navigationBarHidden(true)
        .onAppear {
            // Auto-focus first box
            focusedIndex = 0
        }
    }
}
