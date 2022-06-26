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
    
    var viewModel: GameViewModelProtocol?
    
    var currentQuestion: Word?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.resetUI {
            self.viewModel?.askForNextQuestion()
        }
    
    }
    
    @IBAction func correctDidTapped(_ sender: UIButton) {
        guard let question = self.currentQuestion else { return }
        self.resetAnimation {
            self.viewModel?.select(answer: .correct, for: question)
        }
        
    }
    
    @IBAction func wrongDidTapped(_ sender: UIButton) {
        guard let question = self.currentQuestion else { return }
        self.resetAnimation {
            self.viewModel?.select(answer: .wrong, for: question)
        }
        
    }
    
    func shouldDisplayNext(word: Word) {
        self.currentQuestion = word
        self.lblQuestion.text = word.text_spa
        self.lblAnswer.text = word.text_eng
        self.lblAnswer.layoutIfNeeded()
        self.lblQuestion.layoutIfNeeded()
        self.startAnimation()
    }
    
    func answerResult(isCorrect: QuestionResult) {
        
        guard let counter = self.viewModel?.attemptCount else { return }
        self.updateScoreBoard(with: counter)
        self.viewModel?.askForNextQuestion()
        
    }
    
    func gameState(changedTo newState: GameState) {
        
        switch newState {
        case .initial:
            guard let counter = self.viewModel?.attemptCount else { return }
            self.updateScoreBoard(with: counter)
            self.resetUI {
                self.viewModel?.askForNextQuestion()
            }
            
        case .playing:
            //Do nothing
            break
        case .finished:
            self.shouldEndTheGame()
        }
        
    }
    
    private func startAnimation(){
        
        guard let superView = self.lblQuestion.superview else { return }
        var offsetY = superView.frame.height
        offsetY -= offsetY * 0.3
        self.centerYConstaint.constant = offsetY
        
        UIView.animate(withDuration: TimeInterval(Constants.round),
                       delay: 0.0,
                       options: .curveLinear) {
            superView.layoutIfNeeded()
        } completion: { (isCompleted) in
            self.resetUI()
        }

    }
    
    private func resetAnimation(completion: @escaping ()->() = {}){
        DispatchQueue.main.async {
            guard let superView = self.lblQuestion.superview else { return }
            superView.layer.removeAllAnimations()
            self.lblQuestion.layer.removeAllAnimations()
            self.lblAnswer.layer.removeAllAnimations()
            self.resetUI(completion: completion)
        }
    }
    
    private func resetUI(completion: @escaping ()->() = {}){
        
        guard let superView = self.lblQuestion.superview else { return }
        var offsetY = superView.frame.height
        offsetY -= offsetY * 0.3
        self.centerYConstaint.constant = -offsetY

        //Fadeout animation
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .beginFromCurrentState) {
            self.lblQuestion.alpha = 0.0
            self.lblAnswer.alpha = 0.0
        } completion: { _ in
            
            //Change position animation
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           animations: {
            
                superView.layoutIfNeeded()
            
            }, completion: { completed in
                if completed{
                    self.lblAnswer.alpha = 1.0
                    self.lblQuestion.alpha = 1.0
                    completion()
                }
            })
            
        }

        
        
        
        
    }
    
    private func updateScoreBoard(with info: [QuestionResult: Int]){
        
        let correctCount = info[.correct, default: 0]
        let wrongCount = info[.wrong, default: 0]
        self.lblCorrectAttemptCount.text = "Correct Attemps: \(correctCount)"
        self.lblWrongAttemptCount.text = "Wrong Attempts: \(wrongCount)"
        
    }
    
    
    private func shouldEndTheGame() {
     
        let alertController = UIAlertController(title: "Game Ended",
                                                message: "Thank you for playing",
                                                preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close",
                                   style: .default) { action in
            exit(-1)
        }
        
        let restartAction = UIAlertAction(title: "Restart",
                                   style: .default) { [weak self] action in
            
            guard let weakSelf = self else { return }
            weakSelf.viewModel?.restartGame()
        }
        
        alertController.addAction(closeAction)
        alertController.addAction(restartAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
    }
}

