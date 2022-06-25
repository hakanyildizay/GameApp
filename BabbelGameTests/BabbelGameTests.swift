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
        
        
        let gameView = MockGameViewController()
        let viewModel = GameViewModel(with: gameView)
        gameView.viewModel = viewModel
        
        viewModel.askForNextQuestion()
        
        let nextQuestion = try XCTUnwrap(gameView.nextQuestion, "Next Question should be ready when askForNextQuestion() method is called")
        XCTAssertEqual(nextQuestion.text_eng, "primary school" ,"Next Question english word should be \"primary school\" ")
        
        viewModel.askForNextQuestion()
        let secondQuestion = try XCTUnwrap(gameView.nextQuestion, "Second Question should be ready when askForNextQuestion() method is called")
        XCTAssertEqual(secondQuestion.text_eng, "teacher" ,"Next Question english word should be \"teacher\" ")
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
