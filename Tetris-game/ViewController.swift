//
//  ViewController.swift
//  Tetris-game
//
//  Created by Alex  on 19.12.2023.
//

import UIKit

class ViewController: UIViewController {
	
	//var gameView: GameView!
	var gameView = GameView()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		
		gameViewGrid()
		addViews()
	}
	
	func gameViewGrid() {
		// Создаем экземпляр GameView
		gameView = GameView(frame: .zero)
		gameView.backgroundColor = .systemTeal
	}
	
	func addViews() {
		view.addSubview(gameView)
		view.addSubview(rotateButton)
		view.addSubview(playButton)
		view.addSubview(leftButton)
		view.addSubview(rightButton)
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
		leftButton.frame = CGRect(x: 60, y: 740, width: 60, height: 40)
		leftButton.addTarget(self, action: #selector(moveLeft), for: .touchUpInside)
		return leftButton
	}()
	
	lazy var rightButton: UIButton = {
		let rightButton = UIButton(type: .system)
		rightButton.setImage(UIImage(systemName: "arrowshape.right.fill"), for: .normal)
		rightButton.tintColor = .blue
		rightButton.frame = CGRect(x: 120, y: 740, width: 60, height: 40)
		rightButton.addTarget(self, action: #selector(moveRight), for: .touchUpInside)
		return rightButton
	}()
	
	
	@objc func rotate() {
		// Обработка вращения
		gameView.rotateTetromino()
	}
	
	@objc func startGame() {
		let randomTetromino = generateRandomTetromino()
		gameView.setCurrentTetromino(randomTetromino)
	}
	
	@objc func moveLeft() {

	}
	
	@objc func moveRight() {

	}

	func generateRandomTetromino() -> TetrominoModel {
		return TetrominoModel(type: .line, coordinates: [(0, 0), (1, 0), (2, 0), (3, 0)])
	}

}



class GameView: UIView {
	
	var currentTetromino: TetrominoModel?
	// Размер клетки
	let cellSize: CGFloat = 50.0
	// Размеры игрового поля
	let columns = 7
	let rows = 15

	override func draw(_ rect: CGRect) {
		drawGrid() // Отрисовываем сетку игрового поля
		drawTetromino() // Отрисовываем текущей фигуры
	}

	func drawGrid() {
		let context = UIGraphicsGetCurrentContext()
		context?.setStrokeColor(UIColor.white.cgColor)
		//context?.setLineWidth(1.0)

		// Рисуем вертикальные линии
		for i in 1..<columns {
			let x = CGFloat(i) * cellSize
			context?.move(to: CGPoint(x: x, y: 0))
			context?.addLine(to: CGPoint(x: x, y: CGFloat(rows) * cellSize))
			context?.setLineWidth(2.0)
		}

		// Рисуем горизонтальные линии
		for i in 1..<rows {
			let y = CGFloat(i) * cellSize
			context?.move(to: CGPoint(x: 0, y: y))
			context?.addLine(to: CGPoint(x: CGFloat(columns) * cellSize, y: y))
			context?.setLineWidth(2.0)
		}

		context?.strokePath()
	}
	
	func drawTetromino() {
		guard let tetromino = currentTetromino else { return }
		
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(UIColor.red.cgColor)
		
		for (x, y) in tetromino.coordinates {
			let rect = CGRect(x: CGFloat(x) * cellSize, y: CGFloat(y) * cellSize, width: cellSize, height: cellSize)
			context?.fill(rect)
		}
	}
	
	func rotateTetromino() {
		guard var tetromino = currentTetromino else { return }
		
		// Логика вращения (просто для примера)
		for i in 0..<tetromino.coordinates.count {
			let (x, y) = tetromino.coordinates[i]
			tetromino.coordinates[i] = (-y, x)
		}
		
		setNeedsDisplay()
	}
	
	func setCurrentTetromino(_ tetromino: TetrominoModel) {
		currentTetromino = tetromino
		setNeedsDisplay()
	}
	
}



enum Tetromino {
	case square
	case line
	// Добавьте другие фигуры по мере необходимости
}

class TetrominoModel {
	var type: Tetromino
	var coordinates: [(Int, Int)]

	init(type: Tetromino, coordinates: [(Int, Int)]) {
		self.type = type
		self.coordinates = coordinates
	}
}

