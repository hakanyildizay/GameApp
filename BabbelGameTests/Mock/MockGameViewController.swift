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
    var result: Bool? = nil
    
    func shouldDisplayNext(word: Word) {
        nextQuestion = word
    }
    
    func answerResult(isCorrect: Bool) {
        result = isCorrect
    }
    
    func numberOfAttempts(for answer: Bool, count: Int) {
        
    }
    
}
