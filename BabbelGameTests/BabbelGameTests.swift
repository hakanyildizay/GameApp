//
//  BabbelGameTests.swift
//  BabbelGameTests
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import XCTest
import RxSwift

@testable import BabbelGame

class BabbelGameTests: XCTestCase {

    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        disposeBag = nil
    }

    func testIfDatasourceReturnsMoreThanZeroItemsWhenJsonIsValid() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords",
                                        bundle: testBundle)
        let words = datasource.getWords()
        XCTAssertEqual(words.count, 2, "There should 2 elements in testwords.json file")

    }

    func testIfDatasoruceFailsWhenJsonIsNotValid() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwordsfailed",
                                        bundle: testBundle)
        let words = datasource.getWords()
        XCTAssertEqual(words.count, 0, "There should 0 elements in testwordsfailed.json file. Since field names are totally different")

    }

    func testIfNextQuestionIsCreatedWhenAskForNextQuestionIsCalled() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords",
                                        bundle: testBundle)
        let gameView = MockGameViewController()
        let viewModel = GameViewModel(datasource: datasource)
        gameView.viewModel = viewModel
        gameView.startListening()

        viewModel.askForNextQuestion()

        _ = try XCTUnwrap(gameView.nextQuestion, "Next Question should be ready when askForNextQuestion() method is called")

        // Reset last question from view
        gameView.nextQuestion = nil

        viewModel.askForNextQuestion()

        _ = try XCTUnwrap(gameView.nextQuestion, "Second Question should be ready when askForNextQuestion() method is called")

    }

    func testIfSelectResultIsWrongWhenAnswerIsWrong() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords",
                                        bundle: testBundle)
        let gameView = MockGameViewController()
        let viewModel = GameViewModel(datasource: datasource)
        gameView.viewModel = viewModel
        gameView.startListening()

        // Wrong Answer
        let newQuestion = Word(text_eng: "primary school",
                               text_spa: "profesor / profesora")
        viewModel.select(answer: .correct, for: newQuestion)

        let result = try XCTUnwrap(gameView.result, "result should be wrong")
        XCTAssertEqual(result, .wrong, "\"primary school\" is \"escuela primaria\"")

    }

    func testIfScoreIsCorrectWhenAnswerIsWrong() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords",
                                        bundle: testBundle)

        let gameView = MockGameViewController()
        gameView.startListening()
        let viewModel = GameViewModel(datasource: datasource)
        gameView.viewModel = viewModel
        gameView.startListening()

        let expectation = XCTestExpectation(description: "Wait response is back")
        var wrongAttemptCount = 0
        viewModel.scores.subscribe { (scores) in
            if let attemptsLeft = scores.element {
                wrongAttemptCount = attemptsLeft[.wrong, default: 0]
            }
            expectation.fulfill()
        }.disposed(by: disposeBag)

        let newQuestion = Word(text_eng: "primary school",
                               text_spa: "profesor / profesora")
        viewModel.select(answer: .correct, for: newQuestion)

        _ = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(wrongAttemptCount, 1, "Wrong Attempt Should be 1")

    }

    func testIfScoreIsCorrectWhenAnswerIsCorrect() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords",
                                        bundle: testBundle)
        let gameView = MockGameViewController()
        gameView.startListening()
        let viewModel = GameViewModel(datasource: datasource)
        gameView.viewModel = viewModel
        gameView.startListening()

        let expectation = XCTestExpectation(description: "Wait response is back")

        var correctAttemptCount = 0
        viewModel.scores.subscribe { (scores) in
            if let attemptsLeft = scores.element {
                correctAttemptCount = attemptsLeft[.correct, default: 0]
            }
            expectation.fulfill()
        }.disposed(by: disposeBag)

        let newQuestion = Word(text_eng: "primary school",
                               text_spa: "escuela primaria")
        viewModel.select(answer: .correct, for: newQuestion)

        _ = XCTWaiter.wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(correctAttemptCount, 1, "Correct Attempt Should be 1")
    }

    func testIfGameEndsInThreeRoundsWhenThereIsNoAnswerSelection() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords2",
                                        bundle: testBundle)
        let gameView = MockGameViewController()
        gameView.isAutoPlayer = true

        let viewModel = GameViewModel(datasource: datasource)
        gameView.viewModel = viewModel
        gameView.startListening()

        let expectation = XCTestExpectation(description: "Wait response is back")
        viewModel.askForNextQuestion()

        // Wait for 19 sec till the end of the game.
        // ((5 sec for each round x 3) + 4 sec buffer)
        _ = XCTWaiter.wait(for: [expectation], timeout: 19.0)

        XCTAssertEqual(gameView.isGameEnded, true, "Game should end in 15 sec when there is no interaction")

    }

    func testIfGameHasEndedWhenThereAreThreeWrongAttempts() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords2",
                                        bundle: testBundle)

        let expGameResult = XCTestExpectation(description: "Wait response is back")

        let viewModel = GameViewModel(datasource: datasource)

        let question1 = Word(text_eng: "hippopotamus", text_spa: "jirafa")
        let question2 = Word(text_eng: "hunter", text_spa: "corzo")
        let question3 = Word(text_eng: "tame", text_spa: "cereal")

        var isGameEnded: Bool = false
        viewModel.state.subscribe(onNext: { (gameState) in

            switch gameState {
            case .finished:
                isGameEnded = true
            default:
                break
            }

            expGameResult.fulfill()

        }).disposed(by: disposeBag)

        var wrongCount = 0
        viewModel.answerResult.subscribe(onNext: { _ in
            wrongCount += 1
        }).disposed(by: disposeBag)

        viewModel.select(answer: .correct, for: question1)
        viewModel.select(answer: .correct, for: question2)
        viewModel.select(answer: .correct, for: question3)

        XCTAssertEqual(wrongCount, 3, "All questions answers should be Wrong")

        _ = XCTWaiter.wait(for: [expGameResult], timeout: 1.0)
        XCTAssertEqual(isGameEnded, true, "Game should end when there is no interaction")

    }

    func testIfGameStartsWhenWordsAreLoadedFromMemory() throws {

        let someWords = [Word(text_eng: "welcome", text_spa: "hola"),
                         Word(text_eng: "english", text_spa: "inglesa"),
                         Word(text_eng: "peach", text_spa: "durazno"),
                         Word(text_eng: "beach", text_spa: "playa"),
                         Word(text_eng: "flag", text_spa: "bandera")]

        let dataSource = MockDataSource(with: someWords)
        let gameViewModel = GameViewModel(datasource: dataSource)
        let gameView = MockGameViewController()
        gameView.viewModel = gameViewModel
        gameView.startListening()

        gameViewModel.askForNextQuestion()

        let firstQuestion = try XCTUnwrap(gameView.nextQuestion)
        print("Question: \(firstQuestion)")

    }

}
