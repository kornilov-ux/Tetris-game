//
//  ViewController.swift
//  Tetris-game
//
//  Created by Alex  on 19.12.2023.
//

import UIKit

class ViewController: UIViewController {
	
	var gameView = GameView()
	var fallingTimer: Timer?
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		
		gameViewGrid()
		addViews()
	}
	
	func gameViewGrid() {
		gameView = GameView(frame: .zero) // экземпляр GameView
		gameView.viewController = self
		gameView.backgroundColor = .systemTeal
	}
	
	func addViews() {
		view.addSubview(gameView)
		view.addSubview(rotateButton)
		view.addSubview(playButton)
		view.addSubview(leftButton)
		view.addSubview(rightButton) 
		view.addSubview(downButton)
		// Center the game view
		gameView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			gameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			gameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			gameView.widthAnchor.constraint(equalToConstant: 350),
			gameView.heightAnchor.constraint(equalToConstant: 600),
		])
	}
	
	lazy var rotateButton: UIButton = {
		let rotateButton = UIButton(type: .system)
		rotateButton.setImage(UIImage(systemName: "rotate.left.fill"), for: .normal)
		rotateButton.tintColor = .purple
		rotateButton.frame = CGRect(x: 10, y: 740, width: 60, height: 40)
		rotateButton.addTarget(self, action: #selector(rotate), for: .touchUpInside)
		return rotateButton
	}()
	
	lazy var playButton: UIButton = {
		let playButton = UIButton(type: .system)
		playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		playButton.tintColor = .systemGreen
		playButton.frame = CGRect(x: 320, y: 740, width: 60, height: 40)
		playButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
		return playButton
	}()
	
	lazy var leftButton: UIButton = {
		let leftButton = UIButton(type: .system)
		leftButton.setImage(UIImage(systemName: "arrowshape.left.fill"), for: .normal)
		leftButton.tintColor = .blue
		leftButton.frame = CGRect(x: 100, y: 740, width: 60, height: 40)
		leftButton.addTarget(self, action: #selector(moveLeft), for: .touchUpInside)
		return leftButton
	}()
	
	lazy var rightButton: UIButton = {
		let rightButton = UIButton(type: .system)
		rightButton.setImage(UIImage(systemName: "arrowshape.right.fill"), for: .normal)
		rightButton.tintColor = .blue
		rightButton.frame = CGRect(x: 140, y: 740, width: 60, height: 40)
		rightButton.addTarget(self, action: #selector(moveRight), for: .touchUpInside)
		return rightButton
	}()
	
	lazy var downButton: UIButton = {
		let downButton = UIButton(type: .system)
		downButton.setImage(UIImage(systemName: "arrowshape.down.fill"), for: .normal)
		downButton.tintColor = .cyan
		downButton.frame = CGRect(x: 220, y: 740, width: 60, height: 40)
		downButton.addTarget(self, action: #selector(moveDownFast), for: .touchUpInside)
		return downButton
	}()
	
	
	@objc func rotate() {
		// Обработка вращения
		gameView.rotateTetromino()
	}
	
	@objc func startGame() {
		let randomTetromino = generateRandomTetromino()
		gameView.setCurrentTetromino(randomTetromino)
		startFalling()
	}
	
	@objc func moveLeft() {
		guard let tetromino = gameView.currentTetromino else { return }
		let newCoordinates = tetromino.coordinates.map { ($0.0 - 1, $0.1) }

		// Проверка на выход фигуры за границы поля при движении влево
		if !CollisionHelper.checkCollision(newCoordinates, columns: gameView.columns) {
			gameView.currentTetromino?.coordinates = newCoordinates
			gameView.setNeedsDisplay()
		} 
	}
	
	@objc func moveRight() {
		guard let tetromino = gameView.currentTetromino else { return }
		let newCoordinates = tetromino.coordinates.map { ($0.0 + 1, $0.1) }
		
		// Проверка на выход фигуры за границы поля при движении вправо
		if !CollisionHelper.checkCollision(newCoordinates, columns: gameView.columns) {
			gameView.currentTetromino?.coordinates = newCoordinates
			gameView.setNeedsDisplay()
		} 
	}
	
	@objc func moveDownFast() {
		gameView.moveDown()
	}

	func generateRandomTetromino() -> TetrominoModel {
		let allTetrominos: [TetrominoModel] = [
				TetrominoModel(type: .line, coordinates: [(1, 0), (2, 0), (3, 0), (4, 0)]),
				TetrominoModel(type: .square, coordinates: [(0, 0), (1, 0), (0, 1), (1, 1)]),
			]
		return allTetrominos.randomElement()!
	}
	
	func startFalling() {
		fallingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
			self.gameView.moveDown()
		}
	}

	func stopFalling() {
		fallingTimer?.invalidate()
		fallingTimer = nil
	}

}


