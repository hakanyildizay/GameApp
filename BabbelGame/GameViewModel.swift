//
//  GameViewModel.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation

class GameViewModel: GameViewModelProtocol{
    
    internal weak var view: GameViewProtocol?
    var questions = [Word]()                        //This is array of words which contains correct and wrong word pairs
    var wordDictionary: [String: String] = [:]      //This is our source of truth object where we check answers
    var currentIndex: Int = 0
    var attemptCount: [QuestionResult:Int] = [:]{
        didSet{
            notifyIfGameHasEnded()
        }
    }
    var timer: Timer? = nil
    var counter: Int = Constants.round
    var gameState: GameState = .playing
    
    init(with view: GameViewProtocol, datasource: WordDataSource) {
        self.view = view
        
        let words = datasource.getWords()
        
        self.questions = self.createQuestions(from: words)
        self.attemptCount[.correct] = 0
        self.attemptCount[.wrong] = 0
        
        //Construct source of truth for words
        words.forEach({ wordDictionary[$0.text_eng] = $0.text_spa })
        
    }
    
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
    
    func askForNextQuestion() {
        
        switch self.gameState{
            
        case .finished:
            self.stopTimer()
            break
        
        case .playing:
            if let question = self.getCurrentQuestion(){
                self.gameState = .playing
                self.view?.shouldDisplayNext(word: question)
                self.currentIndex += 1
                self.startTimer()
            }
            
        }
        
        
    }
    
    func getCurrentQuestion()->Word?{
        
        if currentIndex < questions.count{
            return questions[currentIndex]
        }else{
            return nil
        }
        
    }
    
    private func createQuestions(from words: [Word])->[Word]{
        
        var questions = [Word]()
        
        for (index, word) in words.enumerated(){
            
            if shouldCreateWrongQuestion(){
                
                let randomWord = self.getRandomWord(from: words,
                                                    exceptIndex: index)
                
                let newQuestion = Word(text_eng: randomWord.text_eng,
                                       text_spa: word.text_spa)
                
                questions.append(newQuestion)
                
            }else{
                questions.append(word)
            }
            
        }
        
        return questions
    }
    
    private func getRandomWord(from words: [Word], exceptIndex: Int)->Word{
        let randomIndex = self.getRandomIndex(exceptIndex: exceptIndex,
                                              wordCount: words.count)
        return words[randomIndex]
        
    }
    
    private func shouldCreateWrongQuestion()->Bool{
        let ratio = Constants.ratio
        let random = arc4random_uniform(100) //Return a number between 0 and 100
        return random > ratio
    }
    
    private func getRandomIndex(exceptIndex: Int, wordCount: Int)->Int{
        
        var random = Int(arc4random_uniform(UInt32(wordCount)))
        let lastIndex = wordCount - 1
        if random == exceptIndex {
            if exceptIndex == lastIndex{
                random = 0
            }else{
                random = lastIndex
            }
        }
        return random
    }
    
    private func startTimer(){
        
        if let _ = timer {
            return
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                          target: self,
                                          selector: #selector(updateCounter),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    private func stopTimer(){
        if let timer = timer {
            timer.invalidate()
        }
        self.timer = nil
        self.counter = Constants.round
    }
    
    @objc func updateCounter() {
        
        if counter > 0 {
            counter -= 1
        }else{
            self.stopTimer()
            let value = attemptCount[.wrong, default: 0]
            attemptCount[.wrong] = value + 1
            self.view?.answerResult(isCorrect: .wrong)
        }
    }
    
    func notifyIfGameHasEnded(){
        
        if self.attemptCount.count == Constants.endingPairCount ||
            self.attemptCount[.wrong, default: 0] == Constants.endingIncorrectAttemptCount{
            self.stopTimer()
            self.gameState = .finished
            self.view?.shouldEndTheGame()
        }
        
    }
    
}
