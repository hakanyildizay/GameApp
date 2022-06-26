//
//  MockGameViewController.swift
//  BabbelGameTests
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation
@testable import BabbelGame

class MockGameViewController: GameViewProtocol{
   
    var viewModel: GameViewModelProtocol?
    var nextQuestion: Word? = nil
    var result: QuestionResult? = nil
    var isGameEnded: Bool = false
    var isAutoPlayer: Bool = false
    
    func shouldDisplayNext(word: Word) {
        nextQuestion = word
    }
    
    func answerResult(isCorrect: QuestionResult) {
        result = isCorrect
        
        if isAutoPlayer{
            self.viewModel?.askForNextQuestion()
        }
    }
    
    func shouldEndTheGame() {
        isGameEnded = true
    }
    
    deinit{
        print("MockViewController deinited")
    }
    
}
