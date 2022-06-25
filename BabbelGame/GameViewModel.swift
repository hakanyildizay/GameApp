//
//  GameViewModel.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation

class GameViewModel: GameViewModelProtocol{
    
    internal weak var view: GameViewProtocol?
    
    init(with view: GameViewProtocol) {
        self.view = view
    }
    
    func select(answer: Bool) {
        
    }
    
    func askForNextQuestion() {
        let some = Word(text_eng: "", text_spa: "")
        self.view?.shouldDisplayNext(word: some)
    }
    
}
