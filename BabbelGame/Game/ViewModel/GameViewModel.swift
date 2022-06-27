//
//  GameViewModel.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation

class GameViewModel: GameViewModelProtocol {

    private var datasource: WordDataSource!                 // Gets word list and caches it
    private var questions = [Word]()                        // This is array of words which contains correct and wrong word pairs
    private var wordDictionary: [String: String] = [:]      // This is our source of truth object where we check answers
    private var currentIndex: Int = 0                       // Keep track of next question index
    private var timer: Timer?                               // Timer for round
    private var counter: Int = Constants.round
    private var gameState: GameState = .playing {
        didSet {
            self.view?.gameState(changedTo: gameState)
        }
    }

    internal weak var view: GameViewProtocol?
    var attemptCount: [QuestionResult: Int] = [:] {         // Score Table ex: [.wrong] = 2, [.correct] = 3
        didSet {
            notifyIfGameHasEnded()
        }
    }

    /**
     GameViewModel needs a GameViewProtocol object to tell the game progress and
     a data source object to load words from it. it needs word list to construct question list.
     When word list is fetch, then new dictionary object is created to compare translated words.
    */
    init(with view: GameViewProtocol, datasource: WordDataSource) {
        self.view = view

        self.datasource = datasource
        let words = datasource.getWords()
        self.questions = self.createQuestions(from: words)
        self.attemptCount[.correct] = 0
        self.attemptCount[.wrong] = 0

        // Construct source of truth for words
        words.forEach({ wordDictionary[$0.text_eng] = $0.text_spa })

    }
    /**
    User answer a question. This is where we tell the user if s/he is wrong or right and update his/her score.
    
    - parameter answer: Correct or Wrong.
    - parameter question: For which question the user is answering to.
  
    */
    func select(answer: QuestionResult, for question: Word) {

        self.stopTimer()
        let translatedWord = wordDictionary[question.text_eng]
        let questionAnswerIsCorrect = translatedWord == question.text_spa
        var result = QuestionResult.wrong
        switch answer {
        case .correct:
            result = questionAnswerIsCorrect ? .correct : .wrong
        case .wrong:
            result = questionAnswerIsCorrect ? .wrong : .correct
        }

        let value = attemptCount[result, default: 0]
        attemptCount[result] = value + 1

        self.view?.answerResult(isCorrect: result)

    }

    /**
    The user asks for next question the game is initiated or when s/he is ready for picking up next question
    */
    func askForNextQuestion() {

        switch self.gameState {

        case .finished:
            self.stopTimer()
        case .playing, .initial:
            if let question = self.getCurrentQuestion() {
                self.gameState = .playing
                self.view?.shouldDisplayNext(word: question)
                self.currentIndex += 1
                self.startTimer()
            }

        }

    }

    /**
     When user wants to restart the game then all the score counts are erased,
     And its properties are set back to initial values.
    */
    func restartGame() {
        self.questions = self.createQuestions(from: datasource.getWords())
        self.attemptCount[.correct] = 0
        self.attemptCount[.wrong] = 0
        self.currentIndex = 0
        self.counter = Constants.round
        self.gameState = .initial
    }

    private func getCurrentQuestion() -> Word? {

        if currentIndex < questions.count {
            return questions[currentIndex]
        } else {
            return nil
        }

    }

    /**
       Based on the word list we have to create an quesion list which contain false information in it
    - parameter words: Source of truth word list.
    - returns: [Word]
    */
    private func createQuestions(from words: [Word]) -> [Word] {

        var questions = [Word]()

        for (index, word) in words.enumerated() {

            if shouldCreateWrongQuestion() {

                let randomWord = self.getRandomWord(from: words,
                                                    exceptIndex: index)

                let newQuestion = Word(text_eng: randomWord.text_eng,
                                       text_spa: word.text_spa)

                questions.append(newQuestion)

            } else {
                questions.append(word)
            }

        }

        questions.shuffle()

        return questions
    }

    /**
        This methods helps us to find a randome word from the list in order to find a valid spanish word.
     When we need to switch a spanish word then we need to find a random word from the word list.
    
    - parameter words: Source of truth words.
    - parameter exceptionIndex: We want to find a random word except from that index. Because we are going to replace exceptionIndex with the new random spanish word.
    - returns: Word:  Randomly selected word from the word list
    */
    private func getRandomWord(from words: [Word], exceptIndex: Int) -> Word {
        let randomIndex = self.getRandomIndex(exceptIndex: exceptIndex,
                                              wordCount: words.count)
        return words[randomIndex]

    }

    /**
     With %75 of probability, we are going to create a questions with wrong answer.
    - returns: Bool: Yes if should generate a wrong questions
    */
    private func shouldCreateWrongQuestion() -> Bool {
        let ratio = Constants.ratio
        let random = arc4random_uniform(100) // Return a number between 0 and 100
        return random > ratio
    }

    /**
    Try to pick a random word from word list except exceptIndex
    - parameter exceptIndex: The index that want to avaoid when picking a random number
    - parameter wordCount: Total count of word list.
    - returns: Random Int Index
    */
    private func getRandomIndex(exceptIndex: Int, wordCount: Int) -> Int {

        var random = Int(arc4random_uniform(UInt32(wordCount)))
        let lastIndex = wordCount - 1
        if random == exceptIndex {
            if exceptIndex == lastIndex {
                random = 0
            } else {
                random = lastIndex
            }
        }
        return random
    }

    /**
     That timer is used for keeping track of round in terms of seconds.
     When the timer ends without a user selection, it will tell the view that the user answered wrong to the question.
    */
    private func startTimer() {

        if timer != nil { return }

        self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                          target: self,
                                          selector: #selector(updateCounter),
                                          userInfo: nil,
                                          repeats: true)
    }

    private func stopTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        self.timer = nil
        self.counter = Constants.round
    }

    @objc private func updateCounter() {

        if counter > 0 {
            counter -= 1
        } else {
            self.stopTimer()
            let value = attemptCount[.wrong, default: 0]
            attemptCount[.wrong] = value + 1
            self.view?.answerResult(isCorrect: .wrong)
        }
    }

    /**
     At each score update ViewModel is checking whether or not the game has ended.
     The game ends if there are 3 number of wrong answers and 15 number of asked questions.
     When the game is finished then the View is notified with method ```gameState(changedTo: .finished)```
    */
    private func notifyIfGameHasEnded() {

        switch gameState {
        case .playing, .initial:

            let sumOfPairs = self.attemptCount.reduce(0) { $0 + $1.value }
            let wrongCount = self.attemptCount[.wrong, default: 0]
            if sumOfPairs == Constants.endingPairCount ||
                wrongCount == Constants.endingIncorrectAttemptCount {
                self.stopTimer()
                self.gameState = .finished
            }

        case .finished:
            // If the game is already finished then there is no need to notify the view
            break
        }

    }

}
