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
    
    var viewModel: GameViewModelProtocol?
    
    var currentQuestion: Word?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewModel?.askForNextQuestion()
    }

    @IBAction func correctDidTapped(_ sender: UIButton) {
        guard let question = self.currentQuestion else { return }
        self.viewModel?.select(answer: .correct, for: question)
    }
    
    @IBAction func wrongDidTapped(_ sender: UIButton) {
        guard let question = self.currentQuestion else { return }
        self.viewModel?.select(answer: .wrong, for: question)
    }
    
    func shouldDisplayNext(word: Word) {
        self.currentQuestion = word
        self.lblQuestion.text = word.text_spa
        self.lblAnswer.text = word.text_eng
    }
    
    func answerResult(isCorrect: QuestionResult) {
        
        guard let counter = self.viewModel?.attemptCount else { return }
        let correctCount = counter[.correct, default: 0]
        let wrongCount = counter[.wrong, default: 0]
        self.lblCorrectAttemptCount.text = "Correct Attemps: \(correctCount)"
        self.lblWrongAttemptCount.text = "Wrong Attempts: \(wrongCount)"
        
        self.viewModel?.askForNextQuestion()
        
    }
}

