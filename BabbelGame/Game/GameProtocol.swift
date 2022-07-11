//
//  GameViewModelProtocol.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation
import RxSwift

protocol GameViewProtocol: AnyObject {
    var viewModel: GameViewModelProtocol? { get set }
}

protocol GameViewModelProtocol: AnyObject {

    var state: BehaviorSubject<GameState> { get }
    var answerResult: PublishSubject<QuestionResult> { get }
    var nextQuestion: PublishSubject<Word> { get }
    var scores: BehaviorSubject<[QuestionResult: Int]> { get }
    func askForNextQuestion()           // Whenever view is ready to get a new question, it will ask from viewModel to get next
    func select(answer: QuestionResult, for question: Word) // Answering questions if it Wrong or Correct.
    func restartGame()
    func getScoreBoardTitle(for score: Int, type: QuestionResult) -> String
}
