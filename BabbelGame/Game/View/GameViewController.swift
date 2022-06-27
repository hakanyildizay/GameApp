//
//  ViewController.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
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

    // When ViewModel is giving a question this is the place that is invoked.
    func shouldDisplayNext(word: Word) {
        self.currentQuestion = word
        self.lblQuestion.text = word.text_spa
        self.lblAnswer.text = word.text_eng
        self.lblAnswer.layoutIfNeeded()
        self.lblQuestion.layoutIfNeeded()
        self.btnWrong.isEnabled = true
        self.btnCorrect.isEnabled = true
        self.startAnimation()
    }

    // This method is involed when ViewModel tells if the answer is right or wrong.
    func answerResult(isCorrect: QuestionResult) {

        guard let counter = self.viewModel?.attemptCount else { return }
        self.updateScoreBoard(with: counter)
        self.viewModel?.askForNextQuestion()

    }

    // This method is involed when the game state is changed.
    func gameState(changedTo newState: GameState) {

        switch newState {
        case .initial:
            guard let counter = self.viewModel?.attemptCount else { return }
            self.updateScoreBoard(with: counter)
            self.resetUI {
                self.viewModel?.askForNextQuestion()
            }

        case .playing:
            // Do nothing
            break
        case .finished:
            self.finishTheGame()
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
        self.lblCorrectAttemptCount.text = "Correct Attemps: \(correctCount)"
        self.lblWrongAttemptCount.text = "Wrong Attempts: \(wrongCount)"

    }

    private func finishTheGame() {

        let alertController = UIAlertController(title: "Game Ended",
                                                message: "Thank you for playing",
                                                preferredStyle: .alert)

        let closeAction = UIAlertAction(title: "Close",
                                   style: .default) { _ in
            exit(-1)
        }

        let restartAction = UIAlertAction(title: "Restart",
                                   style: .default) { [weak self] _ in

            guard let weakSelf = self else { return }
            weakSelf.viewModel?.restartGame()
        }

        alertController.addAction(closeAction)
        alertController.addAction(restartAction)

        self.present(alertController, animated: true, completion: nil)

    }
}
