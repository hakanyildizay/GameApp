//
//  MockGameViewController.swift
//  BabbelGameTests
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation
import RxSwift

@testable import BabbelGame

class MockGameViewController: GameViewProtocol {

    var viewModel: GameViewModelProtocol?
    var nextQuestion: Word?
    var result: QuestionResult?
    var isGameEnded: Bool = false
    var isAutoPlayer: Bool = false
    var disposeBag = DisposeBag()

    func startListening() {

        viewModel?.answerResult.subscribe(onNext: { [weak self] (resultEvent) in
            guard let weakSelf = self else { return }
            weakSelf.result = resultEvent

            if weakSelf.isAutoPlayer {
                weakSelf.viewModel?.askForNextQuestion()
            }

        }).disposed(by: disposeBag)

        viewModel?.nextQuestion.subscribe(onNext: { [weak self] (word) in
            guard let weakSelf = self else { return }
            weakSelf.nextQuestion = word
        }).disposed(by: disposeBag)

        viewModel?.state.subscribe(onNext: { [weak self] (state) in
            guard let weakSelf = self else { return }
            switch state {
            case .playing, .initial:
                weakSelf.isGameEnded = false
            case .finished:
                weakSelf.isGameEnded = true
            }
        }).disposed(by: disposeBag)

    }

}
