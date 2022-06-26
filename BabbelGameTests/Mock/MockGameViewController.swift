//
//  MockGameViewController.swift
//  BabbelGameTests
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation
@testable import BabbelGame

class MockGameViewController: GameViewProtocol {

    var viewModel: GameViewModelProtocol?
    var nextQuestion: Word?
    var result: QuestionResult?
    var isGameEnded: Bool = false
    var isAutoPlayer: Bool = false

    func shouldDisplayNext(word: Word) {
        nextQuestion = word
    }

    func answerResult(isCorrect: QuestionResult) {
        result = isCorrect

        if isAutoPlayer {
            self.viewModel?.askForNextQuestion()
        }
    }

    func gameState(changedTo newState: GameState) {
        switch newState {
        case .playing, .initial:
            isGameEnded = false
        case .finished:
            isGameEnded = true
        }
    }

}
