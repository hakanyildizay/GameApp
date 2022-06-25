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

    func testIfDataSourceReturnsMoreThanZeroItemsIfJsonIsValid() throws {
        
        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords",
                                        bundle: testBundle)
        let words = datasource.getWords()
        XCTAssertEqual(words.count, 2, "There should 2 elements in testwords.json file")
        
    }
    
    func testIfDatasoruceFailsIfJsonIsNotValid() throws{
        
        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwordsfailed",
                                        bundle: testBundle)
        let words = datasource.getWords()
        XCTAssertEqual(words.count, 0, "There should 0 elements in testwordsfailed.json file. Since field names are totally different")
        
    }

    
    func testIfNextQuestionIsReturningNextQuestion() throws{
        
        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords",
                                        bundle: testBundle)
        let gameView = MockGameViewController()
        let viewModel = GameViewModel(with: gameView,
                                      datasource: datasource)
        gameView.viewModel = viewModel
        
        viewModel.askForNextQuestion()
        
        _ = try XCTUnwrap(gameView.nextQuestion, "Next Question should be ready when askForNextQuestion() method is called")

        //Reset last question from view
        gameView.nextQuestion = nil
        
        viewModel.askForNextQuestion()
        
        _ = try XCTUnwrap(gameView.nextQuestion, "Second Question should be ready when askForNextQuestion() method is called")
        
    }
    
    func testIfSelectResultIsWrongWhenAnswerIsWrong() throws{
        
        let testBundle = Bundle(for: type(of: self))
        let datasource = WordDataSource(with: "testwords",
                                        bundle: testBundle)
        let gameView = MockGameViewController()
        let viewModel = GameViewModel(with: gameView,
                                      datasource: datasource)
        gameView.viewModel = viewModel
        
        //Wrong Answer
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
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
