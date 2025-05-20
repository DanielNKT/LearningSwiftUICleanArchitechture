//
//  SettingsView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 14/3/25.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coordinator: AppCoordinator

    @State private var message: String = ""
    @State private var isShowingPopup: Bool = false
    @State private var isShowingSkillsPopup: Bool = false
    @State private var skills: [String] = ["C++", "Objective-C", "Swift", "SwiftUI", "Combine", "RxSwift"]

    var body: some View {
        ZStack {
            List {
                skillsSection
                messageSection
                customUISection
                logoutSection
                concurrentProgrammingSection
            }
            .listStyle(.plain)
            
            // Dimmed background when popup is shown
            if isShowingPopup || isShowingSkillsPopup {
                Color.black.opacity(0.4) // dimmed background
                    .ignoresSafeArea(.all, edges: .all)
                    .transition(.opacity)
                    .zIndex(1)
                    .onTapGesture {
                        // Optional: dismiss popup when tapping outside
                        withAnimation {
                            isShowingPopup = false
                            isShowingSkillsPopup = false
                        }
                    }
            }

            // Show PopupView
            if isShowingPopup {
                PopupView(isShowing: $isShowingPopup) { newMessage in
                    self.message = newMessage
                }
                .transition(.scale.combined(with: .opacity)) // animated transition
                .zIndex(2)
            }

            // Show SkillsPopupView
            if isShowingSkillsPopup {
                SkillsPopupView(isShowing: $isShowingSkillsPopup, tempSkills: $skills) { newSkills in
                    self.skills = newSkills
                }
                .transition(.scale.combined(with: .opacity)) // animated transition
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isShowingPopup || isShowingSkillsPopup)
    }
}

extension SettingsView {
    private var skillsSection: some View {
        Section(header: Text("Skills").font(.headline)) {
            // Row 1: Message and edit message
            if skills.isEmpty {
                Text("No skills yet.")
            } else {
                TagsSelectionView(tags: skills)
            }
            Button("Edit Skills") {
                isShowingSkillsPopup = true
            }
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .listRowSeparator(.hidden)
    }
    
    private var messageSection: some View {
        Section(header: Text("Message").font(.headline)) {
            // Row 1: Message and edit message
            Text("Message: \(message)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Show popup edit message") {
                isShowingPopup = true
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .listRowSeparator(.hidden)
    }
    
    private var logoutSection: some View {
        Section(header: Text("Logout").font(.headline)) {
            // Row 2: Logout button
            Button("Logout") {
                coordinator.resetToLogin()
                appState.isLoggedIn = false
            }
        }
        .listRowSeparator(.hidden)
    }
    
    private var customUISection: some View {
        Section(header: Text("Custom View").font(.headline)) {
            // Row 3: Go to segment control
            Button("Go to segment control view") {
                coordinator.push(.testSegmentControl)
            }
        }
        .listRowSeparator(.hidden)
    }
    
    private var concurrentProgrammingSection: some View {
        Section(header: Text("Concurrent Programming").font(.headline)) {
            // Row 3: Go to segment control
            Button("Go to concurrent programming view") {
                coordinator.push(.concurrentProgramming)
            }
        }
        .listRowSeparator(.hidden)
    }
}

struct SkillsPopupView: View {
    @Binding var isShowing: Bool
    @Binding var tempSkills: [String]
    
    @State private var selectedSkills: [String] = []
    @State private var localSkills: [String] = []
    @State private var tempSkill: String = ""
    var onSave: ([String]) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text("Your Skills")
                .font(.title2)
                .bold()
                .padding(.top)

            // Tags View
            if !localSkills.isEmpty {
                TagsSelectionView(tags: localSkills, selectedAll: true, canCheck: true, didChangeSelection: {
                    selection in
                    print(selection)
                    self.selectedSkills = selection
                })
                .padding(.horizontal)
            }
            

            // Input Area
            VStack(alignment: .leading, spacing: 8) {
                Text("Add a Skill (or tap to remove)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    TextField("e.g. SwiftUI", text: $tempSkill)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)

                    Button(action: {
                        if !tempSkill.isEmpty && !(localSkills.contains { $0.lowercased() == tempSkill.lowercased()}) {
                            selectedSkills.append(tempSkill)
                            localSkills.append(tempSkill)
                            tempSkill = ""
                        }
                    }) {
                        Image(systemName: "plus")
                            .padding(10)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .disabled(tempSkill.isEmpty)
                    .opacity(tempSkill.isEmpty ? 0.5 : 1.0)
                }
            }
            .padding(.horizontal)

            // Action Buttons
            HStack {
                Button("Cancel") {
                    isShowing = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)

                Button("Submit") {
                    onSave(localSkills.filter { selectedSkills.contains($0)})
                    isShowing = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .onAppear {
            selectedSkills = tempSkills
            localSkills = tempSkills
        }
        .frame(width: 320)
        .frame(minHeight: 300)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 12)
        .padding()
    }
}


struct PopupView: View {
    @Binding var isShowing: Bool
    @State private var tempMessage: String = ""
    var onSave: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Text")
                .font(.headline)
            
            TextField("Type something...", text: $tempMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Submit") {
                onSave(tempMessage)
                isShowing = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding()
    }
}

struct ChildView: View {
    @State private var tempMessage: String = ""
    var onSave: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("You have entered: \(tempMessage)")
            
            TextField("Enter message", text: $tempMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save & Dismiss") {
                onSave(tempMessage) // Send data back
                dismiss() // Close the sheet
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
