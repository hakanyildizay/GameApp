//
//  WordDataSource.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation

class WordDataSource{
    
    private let fileName: String
    private let bundle: Bundle
    private var words: [Word]?
    
    init(with filename: String, bundle: Bundle = Bundle.main) {
        self.fileName = filename
        self.bundle = bundle
        self.words = nil
    }
    
    private func loadJson()->Data?{
        
        if let url = bundle.url(forResource: fileName, withExtension: "json"){
            do{
                let data = try Data(contentsOf: url)
                return data
            }catch{
                
            }
        }
        return nil
    }
    
    func getWords()->[Word]{
        
        if let words = words {
            return words
        }else{
            var loadedWords = [Word]()
            if let jsonData = loadJson(){
                do{
                    let decoder = JSONDecoder()
                    let words = try decoder.decode([Word].self, from: jsonData)
                    loadedWords = words
                }catch{
                    loadedWords = []
                }
            }
            
            self.words = loadedWords
            return loadedWords
        }
        
        
    }
    
}
