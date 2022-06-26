//
//  BabbelGameTests.swift
//  BabbelGameTests
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import XCTest
@testable import BabbelGame

class BabbelGameTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        let viewModel = GameViewModel(with: gameView,
                                      datasource: datasource)
        gameView.viewModel = viewModel

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
        let viewModel = GameViewModel(with: gameView,
                                      datasource: datasource)
        gameView.viewModel = viewModel

        // Wrong Answer
        let newQuestion = Word(text_eng: "primary school",
                               text_spa: "profesor / profesora")
        viewModel.select(answer: .correct, for: newQuestion)

        let result = try XCTUnwrap(gameView.result, "result should be wrong")
        XCTAssertEqual(result, .wrong, "\"primary school\" is \"escuela primaria\"")

    }

    func testWrongNumberOfAttemptIsCorrectWhenAnswerIsWrong() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords",
                                        bundle: testBundle)
        let gameView = MockGameViewController()
        let viewModel = GameViewModel(with: gameView,
                                      datasource: datasource)
        gameView.viewModel = viewModel

        let newQuestion = Word(text_eng: "primary school",
                               text_spa: "profesor / profesora")
        viewModel.select(answer: .correct, for: newQuestion)
        let wrongAttempt = viewModel.attemptCount[.wrong, default: 0]

        XCTAssertEqual(wrongAttempt, 1, "Wrong Attemp Should be 1")
    }

    func testCorrectNumberOfAttemptIsCorrectWhenAnswerIsCorrect() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords",
                                        bundle: testBundle)
        let gameView = MockGameViewController()
        let viewModel = GameViewModel(with: gameView,
                                      datasource: datasource)
        gameView.viewModel = viewModel

        let newQuestion = Word(text_eng: "primary school",
                               text_spa: "escuela primaria")
        viewModel.select(answer: .correct, for: newQuestion)
        let correctAttempt = viewModel.attemptCount[.correct, default: 0]

        XCTAssertEqual(correctAttempt, 1, "Wrong Attemp Should be 1")
    }

    func testIfGameEndsInThreeRoundsWhenThereIsNoAnswerSelection() throws {

        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords2",
                                        bundle: testBundle)
        let gameView = MockGameViewController()
        gameView.isAutoPlayer = true
        let viewModel = GameViewModel(with: gameView,
                                      datasource: datasource)
        gameView.viewModel = viewModel

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
        let gameView = MockGameViewController()
        let viewModel = GameViewModel(with: gameView,
                                      datasource: datasource)
        gameView.viewModel = viewModel

        let question1 = Word(text_eng: "hippopotamus", text_spa: "jirafa")
        let question2 = Word(text_eng: "hunter", text_spa: "corzo")
        let question3 = Word(text_eng: "tame", text_spa: "cereal")

        viewModel.select(answer: .correct, for: question1)

        let firstQuestionResult = try XCTUnwrap(gameView.result)
        XCTAssertEqual(firstQuestionResult, .wrong, "First question answer should be Wrong")

        viewModel.select(answer: .correct, for: question2)

        let secondQuestionResult = try XCTUnwrap(gameView.result)
        XCTAssertEqual(secondQuestionResult, .wrong, "Second question answer should be Wrong")

        viewModel.select(answer: .correct, for: question3)

        let thirdQuestionResult = try XCTUnwrap(gameView.result)
        XCTAssertEqual(thirdQuestionResult, .wrong, "Third question answer should be Wrong")

        XCTAssertEqual(gameView.isGameEnded, true, "Game should end in 15 sec when there is no interaction")

    }

}
