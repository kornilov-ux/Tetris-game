//
//  TetrominoModel.swift
//  Tetris-game
//
//  Created by Alex  on 21.12.2023.
//


import UIKit

class TetrominoModel {
	var type: Tetromino
	var coordinates: [(Int, Int)]

	init(type: Tetromino, coordinates: [(Int, Int)]) {
		self.type = type
		self.coordinates = coordinates
	}
	
	func moveDown() {
		coordinates = coordinates.map { ($0.0, $0.1 + 1) }
	}
}
