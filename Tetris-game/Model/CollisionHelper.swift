//
//  CollisionHelper.swift
//  Tetris-game
//
//  Created by Alex  on 21.12.2023.
//

import UIKit

class CollisionHelper {
	static func checkCollision(_ newCoordinates: [(Int, Int)], columns: Int) -> Bool {
		for (x, _) in newCoordinates {
			if x < 0 || x >= columns {
				return true
			}
		}
		return false
	}
}
