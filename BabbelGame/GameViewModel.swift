//
//  GameViewModel.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation

class GameViewModel: GameViewModelProtocol{
    
    internal weak var view: GameViewProtocol?
    var questions: [Word]
    var currentIndex: Int = 0
    init(with view: GameViewProtocol) {
        self.view = view
        let datasource = WordDataSource(with: "words")
        self.questions = datasource.getWords()
    }
    
    func select(answer: QuestionResult) {
        
    }
    
    func askForNextQuestion() {
        if currentIndex < questions.count{
            let nextQuestion = questions[currentIndex]
            self.view?.shouldDisplayNext(word: nextQuestion)
            self.currentIndex += 1
        }
    }
    
}
