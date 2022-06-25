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
    var attemptCount: [QuestionResult:Int] = [:]
    
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
        
        let correctAnswer = wordDictionary[question.text_eng]
        let answerCorrect = correctAnswer == question.text_spa
        var result = QuestionResult.wrong
        switch answer {
        case .correct:
            result = answerCorrect ? .correct : .wrong
        case .wrong:
            result = answerCorrect ? .wrong : .correct
        }
        
        let value = attemptCount[result, default: 0]
        attemptCount[result] = value + 1
        
        self.view?.answerResult(isCorrect: result)
        
    }
    
    func askForNextQuestion() {
        if let question = self.getCurrentQuestion(){
            self.view?.shouldDisplayNext(word: question)
            self.currentIndex += 1
        }
    }
    
    private func getCurrentQuestion()->Word?{
        
        if currentIndex < questions.count{
            return questions[currentIndex]
        }else{
            return nil
        }
        
    }
    
    private func createQuestions(from words: [Word])->[Word]{
        
        let ratio = 0.25
        
        
        
        return words
    }
    
}
