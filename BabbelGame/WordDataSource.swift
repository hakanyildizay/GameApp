//
//  WordDataSource.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation

struct WordDataSource{
    
    let fileName: String
    let bundle: Bundle
    
    init(with filename: String, bundle: Bundle = Bundle.main) {
        self.fileName = filename
        self.bundle = bundle
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
        
        if let jsonData = loadJson(){
            do{
                let decoder = JSONDecoder()
                let words = try decoder.decode([Word].self, from: jsonData)
                return words
            }catch{
                return []
            }
        }
        return []
    }
    
}
