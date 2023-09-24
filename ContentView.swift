//
//  ContentView.swift
//  WordScramble
//
//  Created by David Amedeka on 9/3/23.
//

import SwiftUI

struct ContentView: View {
    
    enum FocusedField {
        case inputField
    }
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var inputWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var wordsCount = 0
    @State private var score = 0
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter word", text: $inputWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .focused($focusedField, equals: .inputField)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                } header: {
                    Text("Used Words")
                        .font(.system(size: 20, weight: .black))
                }
            }
            .navigationTitle(rootWord)
            .toolbar(content: {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {startGame()}, label: {
                        Text("New Game")
                            .padding()
                            .foregroundStyle(.white)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Text("Words Found: \(wordsCount)")
                        .bold()
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Text("Score: \(score)")
                        .bold()
                }
            })
        }
        .onSubmit(addNewWord)
        .onAppear {
            startGame()
            focusedField = .inputField
        }
        .alert(errorTitle, isPresented: $showingError) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        
    }
    
    func addNewWord() {
        let answer = inputWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        inputWord = ""
        focusedField = .inputField
        
        guard isGreaterThanThree(word: answer) else {
            wordError(title: "Entry too short", message: "Entry cannot be less than 3 letters")
            return
        }
        
        guard isNotRoot(word: answer) else {
            wordError(title: "Entry cannot be root word", message: "Your word cannot be the root word, \(rootWord)")
            return
        }
        
        guard isUnique(word: answer) else {
            wordError(title: "Entry Not Unique", message: "Your word is not unique")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Entry not possible", message: "Cannot spell \(answer) with \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Entry not Real", message: "Your word is not a real word")
            return
        }
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            
            score += answer.count
            wordsCount += 1
        }
        
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            
            if let startWords = try? String(contentsOf: startWordsURL) {
                
                let allWords = startWords.components(separatedBy: .newlines)
                
                rootWord = allWords.randomElement() ?? "silkworm"
                inputWord = ""
                score = 0
                wordsCount = 0
                usedWords = []
                return
            }
            
        }
        fatalError("Could not load start.txt from bundle.")
        
        
    }
    
    func isUnique(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        // Copy root word
        // Loop through each word
        // if the letter in the input is in the root, remove from copy
        
        var rootCopy = rootWord
        
        for letter in word {
            if let pos = rootCopy.firstIndex(of: letter) {
                rootCopy.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isNotRoot(word: String) -> Bool {
        return word != rootWord
    }
    
    func isGreaterThanThree(word: String) -> Bool {
        return word.count >= 3
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
