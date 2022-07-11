//
//  WordDataSource.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation

protocol DataSourceProtocol {
    func getWords() -> [Word]
}

/**
 This class is for loasing pair of words from json file.
 It has a property for Bundle. Because we are passing test bundle instead of application bundle in Unit Test
 */
class WordDataSource: DataSourceProtocol {

    private let fileName: String
    private let bundle: Bundle
    private var words: [Word]?

    init(with filename: String, bundle: Bundle = Bundle.main) {
        self.fileName = filename
        self.bundle = bundle
        self.words = nil
    }

    private func loadJson() -> Data? {

        if let url = bundle.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {

            }
        }
        return nil
    }

    /**
    It loads word list from json file.
    
    - returns: List of Word
    # Notes: #
    1. This method is caching word list. If it didn't find the cached list then it will loads it from the disk.
    */
    func getWords() -> [Word] {

        if let words = words {
            return words
        } else {
            var loadedWords = [Word]()
            if let jsonData = loadJson() {
                do {
                    let decoder = JSONDecoder()
                    let words = try decoder.decode([Word].self, from: jsonData)
                    loadedWords = words
                } catch {
                    loadedWords = []
                }
            }

            self.words = loadedWords
            return loadedWords
        }

    }

}
