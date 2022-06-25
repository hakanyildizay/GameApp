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
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
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
    
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
