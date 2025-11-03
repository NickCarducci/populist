//
//  RegistrationView.swift
//  Populist
//
//  Created by Nicholas Carducci on 10/24/25.
//
import SwiftUI
import AuthenticationServices
import FirebaseAuth
import CryptoKit

// MARK: - Registration View
struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authState: UserAuthState
    @State private var journeyId: String? = UserDefaults.standard.string(forKey: "journeyId")
    @State private var verificationStatus: String = "Pending Verification"
    @State private var isRefreshing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSigningIn = false
    @State private var currentNonce: String?
    
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
                            Text("Sign in with Apple ID")
                                .font(.body)
                        }
                        
                        HStack {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.blue)
                            Text("Prepare your government-issued ID")
                                .font(.body)
                        }
                        
                        HStack {
                            Image(systemName: "3.circle.fill")
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
                                checkVerificationStatus()
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
                        // Sign in with Apple Button
                        SignInWithAppleButton(
                            onRequest: { request in
                                let nonce = randomNonceString()
                                currentNonce = nonce
                                request.requestedScopes = [.fullName, .email]
                                request.nonce = sha256(nonce)
                            },
                            onCompletion: { result in
                                handleAppleSignIn(result: result)
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .disabled(isSigningIn)
                        .overlay(
                            Group {
                                if isSigningIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                        )
                        
                        Text("Start Verification Process")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
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
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Apple Sign In Handler
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        isSigningIn = true
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Verify we have a nonce
                guard let nonce = currentNonce else {
                    errorMessage = "Invalid state: A login callback was received, but no login request was sent."
                    showError = true
                    isSigningIn = false
                    return
                }
                
                // Get the identity token
                guard let idTokenData = appleIDCredential.identityToken,
                      let idTokenString = String(data: idTokenData, encoding: .utf8) else {
                    errorMessage = "Unable to fetch identity token"
                    showError = true
                    isSigningIn = false
                    return
                }
                
                // Create Firebase credential with nonce
                let credential = OAuthProvider.credential(
                    providerID: .apple,
                    idToken: idTokenString,
                    rawNonce: nonce
                )
                
                // Sign in with Firebase
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        errorMessage = "Firebase authentication failed: \(error.localizedDescription)"
                        showError = true
                        isSigningIn = false
                        return
                    }
                    
                    // Successfully signed in with Firebase
                    if let user = authResult?.user {
                        print("Successfully signed in with Firebase. User ID: \(user.uid)")
                        
                        // Update auth state
                        authState.isLoggedIn = true
                        
                        // After successful Firebase auth, initiate IDwise journey
                        initiateIDwiseJourney(userIdentifier: user.uid)
                    }
                }
            }
            
        case .failure(let error):
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
            showError = true
            isSigningIn = false
        }
    }
    
    // MARK: - IDwise Journey
    private func initiateIDwiseJourney(userIdentifier: String) {
        // TODO: Initialize IDwise SDK and start journey
        // 1. Import IDWise SDK: import IDWise
        // 2. Configure IDwise with your client key from IDwise dashboard
        // Example:
        // IDWise.initialize(clientKey: "YOUR_CLIENT_KEY") { error in
        //     if let error = error {
        //         print("IDwise initialization failed: \(error)")
        //         return
        //     }
        // }
        //
        // 3. Start journey with user reference ID (userIdentifier)
        // Example:
        // IDWise.startJourney(
        //     journeyDefinitionId: "YOUR_JOURNEY_DEFINITION_ID",
        //     referenceNumber: userIdentifier,
        //     locale: "en",
        //     applicantDetails: nil
        // ) { journeyId, error in
        //     if let error = error {
        //         print("Failed to start journey: \(error)")
        //         return
        //     }
        //     // Store journeyId
        // }
        //
        // 4. Handle journey completion callbacks
        // Set delegate to handle onJourneyCompleted, onJourneyFailed, etc.
        
        // For now, create a journey ID
        let newJourneyId = UUID().uuidString
        UserDefaults.standard.set(newJourneyId, forKey: "journeyId")
        UserDefaults.standard.set(userIdentifier, forKey: "firebaseUserId")
        journeyId = newJourneyId
        
        // TODO: Store journey mapping in Firebase Firestore
        // Document structure:
        // Collection: "verifications"
        // Document ID: journeyId (or auto-generated)
        // Fields: {
        //     userId: userIdentifier,
        //     journeyId: newJourneyId,
        //     status: "pending",
        //     createdAt: FieldValue.serverTimestamp(),
        //     updatedAt: FieldValue.serverTimestamp()
        // }
        //
        // Example:
        // let db = Firestore.firestore()
        // db.collection("verifications").document(newJourneyId).setData([
        //     "userId": userIdentifier,
        //     "journeyId": newJourneyId,
        //     "status": "pending",
        //     "createdAt": FieldValue.serverTimestamp(),
        //     "updatedAt": FieldValue.serverTimestamp()
        // ]) { error in
        //     if let error = error {
        //         print("Error storing journey: \(error)")
        //     }
        // }
        
        // Update status
        verificationStatus = "IDwise verification initiated"
        isSigningIn = false
        
        print("IDwise journey initiated with ID: \(newJourneyId) for Firebase user: \(userIdentifier)")
    }
    
    // MARK: - Check Verification Status
    private func checkVerificationStatus() {
        // let journeyId = journeyId
        guard journeyId != nil else {
            isRefreshing = false
            return
        }
        
        // TODO: Query Firebase Firestore for verification status
        // 1. Get document from "verifications" collection with journeyId
        // 2. Check status field ("pending", "approved", "rejected")
        // 3. Update UI accordingly
        //
        // Example:
        // let db = Firestore.firestore()
        // db.collection("verifications").document(journeyId).getDocument { document, error in
        //     if let error = error {
        //         print("Error fetching verification status: \(error)")
        //         self.isRefreshing = false
        //         return
        //     }
        //
        //     guard let document = document, document.exists,
        //           let data = document.data(),
        //           let status = data["status"] as? String else {
        //         self.verificationStatus = "Status Unknown"
        //         self.isRefreshing = false
        //         return
        //     }
        //
        //     switch status {
        //     case "approved":
        //         self.verificationStatus = "Verified ✓"
        //         self.authState.isLoggedIn = true
        //         self.presentationMode.wrappedValue.dismiss()
        //     case "rejected":
        //         self.verificationStatus = "Verification Failed"
        //     default:
        //         self.verificationStatus = "Pending Verification"
        //     }
        //
        //     self.isRefreshing = false
        // }
        
        // Simulate async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isRefreshing = false
            
            // TODO: Replace with actual Firestore response
            // For now, simulate pending status
            verificationStatus = "Pending Verification"
            
            // If approved, update auth state
            // authState.isLoggedIn = true
            // presentationMode.wrappedValue.dismiss()
        }
    }
    
    // MARK: - Nonce Generation Helpers
    
    /// Generates a random nonce string for security
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    /// Hashes the nonce using SHA256
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
