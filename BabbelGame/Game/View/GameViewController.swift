//
//  ViewController.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import UIKit
import RxSwift

class GameViewController: UIViewController, StoryboardInstantiable, GameViewProtocol {

    static var storyboardType: StoryboardType = .main

    @IBOutlet weak var lblCorrectAttemptCount: UILabel!
    @IBOutlet weak var lblWrongAttemptCount: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblAnswer: UILabel!
    @IBOutlet weak var centerYConstaint: NSLayoutConstraint!
    @IBOutlet weak var btnWrong: UIButton!
    @IBOutlet weak var btnCorrect: UIButton!

    var viewModel: GameViewModelProtocol?

    var currentQuestion: Word?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initListeners()
        // Move the question view to the top of the screen.
        self.resetUI {
            // When animation is done then it is right time to ask for the next question to start the game
            self.viewModel?.askForNextQuestion()
        }

    }

    @IBAction func correctDidTapped(_ sender: UIButton) {
        guard let question = self.currentQuestion else { return }
        self.resetAnimation {
            // When the questionView is moved on top of the screen
            // then we can send our answer to the ViewModel
            self.viewModel?.select(answer: .correct, for: question)
        }

    }

    @IBAction func wrongDidTapped(_ sender: UIButton) {
        guard let question = self.currentQuestion else { return }
        self.resetAnimation {
            // When the questionView is moved on top of the screen
            // then we can send our answer to the ViewModel
            self.viewModel?.select(answer: .wrong, for: question)
        }

    }

    // The slide down animation of the question labels (Spanish+English)
    private func startAnimation() {

        guard let superView = self.lblQuestion.superview else { return }
        var offsetY = superView.frame.height
        offsetY -= offsetY * 0.3
        self.centerYConstaint.constant = offsetY

        UIView.animate(withDuration: TimeInterval(Constants.round),
                       delay: 0.0,
                       options: .curveLinear) {
            superView.layoutIfNeeded()
        } completion: { (_) in
            self.resetUI()
        }

    }

    // Removing animations from questions labels.
    private func resetAnimation(completion: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            guard let superView = self.lblQuestion.superview else { return }
            superView.layer.removeAllAnimations()
            self.lblQuestion.layer.removeAllAnimations()
            self.lblAnswer.layer.removeAllAnimations()
            self.btnWrong.isEnabled = false
            self.btnCorrect.isEnabled = false
            self.resetUI(completion: completion)
        }
    }

    // The slide up + fadeout animation of the question labels (Spanihs+English)
    private func resetUI(completion: @escaping () -> Void = {}) {

        guard let superView = self.lblQuestion.superview else { return }
        var offsetY = superView.frame.height
        offsetY -= offsetY * 0.3
        self.centerYConstaint.constant = -offsetY

        // Fadeout animation
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .beginFromCurrentState) {
            self.lblQuestion.alpha = 0.0
            self.lblAnswer.alpha = 0.0
        } completion: { _ in

            // Change position animation
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           animations: {

                superView.layoutIfNeeded()

            }, completion: { completed in
                if completed {
                    self.lblAnswer.alpha = 1.0
                    self.lblQuestion.alpha = 1.0
                    completion()
                }
            })

        }

    }

    private func updateScoreBoard(with info: [QuestionResult: Int]) {

        let correctCount = info[.correct, default: 0]
        let wrongCount = info[.wrong, default: 0]
        self.lblCorrectAttemptCount.text = StringResources.GameView.correctAttempts+" \(correctCount)"
        self.lblWrongAttemptCount.text = StringResources.GameView.wrongAttempts+" \(wrongCount)"

    }

    private func finishTheGame() {

        self.resetAnimation()

        let alertController = UIAlertController(title: StringResources.GameView.gameEnded,
                                                message: StringResources.GameView.thankYou,
                                                preferredStyle: .alert)

        let closeAction = UIAlertAction(title: StringResources.GameView.close,
                                   style: .default) { _ in
            exit(-1)
        }

        let restartAction = UIAlertAction(title: StringResources.GameView.restart,
                                   style: .default) { [weak self] _ in

            guard let weakSelf = self else { return }
            weakSelf.viewModel?.restartGame()
        }

        alertController.addAction(closeAction)
        alertController.addAction(restartAction)

        self.present(alertController, animated: true, completion: nil)

    }
}

extension GameViewController {

    private func initListeners() {

        // Listen for game state changes
        self.viewModel?.state.subscribe({ [weak self] event in

            guard let newState = event.element else { return }
            guard let weakSelf = self else { return }

            switch newState {

            case .initial:
                weakSelf.resetUI {
                    weakSelf.viewModel?.askForNextQuestion()
                }

            case .playing:
                // Do nothing
                break
            case .finished:
                weakSelf.finishTheGame()
            }

        }).disposed(by: disposeBag)

        self.viewModel?.answerResult.subscribe({ [weak self] (_) in

            guard let weakSelf = self else { return }
            weakSelf.viewModel?.askForNextQuestion()

        }).disposed(by: disposeBag)

        self.viewModel?.nextQuestion.subscribe({ [weak self] (event) in

            guard let weakSelf = self else { return }
            guard let nextQuestion = event.element else { return }

            weakSelf.currentQuestion = nextQuestion
            weakSelf.lblQuestion.text = nextQuestion.text_spa
            weakSelf.lblAnswer.text = nextQuestion.text_eng
            weakSelf.lblAnswer.layoutIfNeeded()
            weakSelf.lblQuestion.layoutIfNeeded()
            weakSelf.btnWrong.isEnabled = true
            weakSelf.btnCorrect.isEnabled = true
            weakSelf.startAnimation()

        }).disposed(by: disposeBag)

        self.viewModel?.scores.subscribe({ [weak self] (event) in

            guard let weakSelf = self else { return }
            guard let scoreBoard = event.element else { return }
            let wrongScores = weakSelf.viewModel?.getScoreBoardTitle(for: scoreBoard[.wrong, default: 0], type: .wrong)
            let correctScores = weakSelf.viewModel?.getScoreBoardTitle(for: scoreBoard[.correct, default: 0], type: .correct)
            weakSelf.lblWrongAttemptCount.text = wrongScores
            weakSelf.lblCorrectAttemptCount.text = correctScores

        }).disposed(by: disposeBag)

    }

}
