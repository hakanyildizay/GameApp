//
//  MockDataSource.swift
//  BabbelGameTests
//
//  Created by Hakan Yildizay on 11.07.2022.
//

import Foundation
@testable import BabbelGame

class MockDataSource: DataSourceProtocol {

    var words: [Word] = []

    init(with words: [Word]) {
        self.words = words
    }

    func getWords() -> [Word] {
        return words
    }

}
