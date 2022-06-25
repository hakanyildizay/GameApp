//
//  GameViewModelProtocol.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation

protocol GameViewProtocol: AnyObject{
    var viewModel: GameViewModelProtocol? { get set }
    func shouldDisplayNext(word: Word)  //When a new question is ready, it should be shown to the user
    func answerResult(isCorrect: QuestionResult)  //When user select either true/false, then it should get notified if he is correct or wrong
    func numberOfAttempts(for answer: QuestionResult, count: Int) //Number of attemps for Correct / Wrong
}

protocol GameViewModelProtocol: AnyObject {
    
    var view: GameViewProtocol? { get set }
    func askForNextQuestion()           //Whenever view is ready to get a new question, it will ask from viewModel to get next
    func select(answer: QuestionResult) 
}
