//
//  GameState.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation

enum GameState {
    case initial    // When game has not started yet. Just between playing and finished state
    case playing    // As soon as the question is asked, then the game is in plating state
    case finished   // Game has ended.
}
