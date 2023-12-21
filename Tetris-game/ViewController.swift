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


class GameView: UIView {
	
	var lockedCoordinates: [(Int, Int)] = []
	weak var viewController: ViewController?
	var currentTetromino: TetrominoModel?
	let cellSize: CGFloat = 50.0 // Размер клетки
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
		context?.setFillColor(randomColorTetromino().cgColor)
		
		for (x, y) in tetromino.coordinates {
			let rect = CGRect(x: CGFloat(x) * cellSize, y: CGFloat(y) * cellSize, width: cellSize, height: cellSize)
			context?.fill(rect)
		}
		for (x, y) in lockedCoordinates {
			let rect = CGRect(x: CGFloat(x) * cellSize, y: CGFloat(y) * cellSize, width: cellSize, height: cellSize)
			context?.fill(rect)
		}
	}
	
	func randomColorTetromino() -> UIColor! {
		let colorsTetromino: [UIColor] = [.red, .blue, .green, .orange, .cyan, .purple] 
		let randomColor = colorsTetromino.randomElement()
		return randomColor
	}
	
	func rotateTetromino() {
		guard let tetromino = currentTetromino else { return }

		let center = tetromino.coordinates[1]  // Assuming the second square is the center for rotation

		var rotatedCoordinates: [(Int, Int)] = []

		for (x, y) in tetromino.coordinates {
			// Rotate around the center
			let xOffset = x - center.0
			let yOffset = y - center.1
			let rotatedX = center.0 - yOffset
			let rotatedY = center.1 + xOffset
			rotatedCoordinates.append((rotatedX, rotatedY))
		}

		
		if !CollisionHelper.checkCollision(rotatedCoordinates, columns: columns) &&
			!checkLockedCollision(rotatedCoordinates) {
			currentTetromino?.coordinates = rotatedCoordinates
			setNeedsDisplay()
		}
	}

	
	func setCurrentTetromino(_ tetromino: TetrominoModel) {
		currentTetromino = tetromino
		setNeedsDisplay()
	}
	
	func moveDown() {
		guard let tetromino = currentTetromino else { return }
		var newCoordinates = tetromino.coordinates.map { ($0.0, $0.1 + 1) }

		if !reachedBottomBoundary(newCoordinates) && !CollisionHelper.checkCollision(newCoordinates, columns: columns) && !checkLockedCollision(newCoordinates) {
			currentTetromino?.coordinates = newCoordinates
			setNeedsDisplay()
		} else {
			if reachedBottomBoundary(newCoordinates) {
				lockTetromino()
			} else {
				lockTetrominoIfNeeded(newCoordinates)
			}
			viewController?.stopFalling()
			viewController?.startGame()
		}
	}
	
	func checkLockedCollision(_ newCoordinates: [(Int, Int)]) -> Bool {
		return CollisionHelper.checkCollision(newCoordinates + lockedCoordinates, columns: columns)
	}

	func lockTetrominoIfNeeded(_ newCoordinates: [(Int, Int)]) {
		// Check if the new position collides with other locked tetrominos
		if CollisionHelper.checkCollision(newCoordinates, columns: columns) {
			lockTetromino()
		}
	}
	
	func reachedBottomBoundary(_ coordinates: [(Int, Int)]) -> Bool {
		let maxY = coordinates.map { $0.1 }.max() ?? 0
		return maxY >= rows - 1
	}
	
	func lockTetromino() {
		guard let tetromino = currentTetromino else { return }

		// Lock the tetromino by adding its coordinates to the list of locked coordinates
		let maxY = tetromino.coordinates.map { $0.1 }.max() ?? 0
		let minY = tetromino.coordinates.map { $0.1 }.min() ?? 0
		let translationOffset = rows - maxY + 9
		for (x, y) in tetromino.coordinates {
			let lockedCoordinate = (x, y + translationOffset - minY)
			lockedCoordinates.append(lockedCoordinate)
		}

		// Clear the current tetromino
		currentTetromino = nil
		setNeedsDisplay()

		// Remove any full lines
		removeFullLines()
	}
	
	func removeFullLines() {
		var fullLines: [Int] = []

		// Check for filled lines
		for row in 0..<rows {
			let line = lockedCoordinates.filter { $0.1 == row }
			if line.count == columns {
				fullLines.append(row)
			}
		}

		// Remove filled lines
		if !fullLines.isEmpty {
			lockedCoordinates = lockedCoordinates.filter { !fullLines.contains($0.1) }
			setNeedsDisplay()
			
			// Add new empty lines at the top
			for _ in fullLines {
				let newLine: [(Int, Int)] = Array(repeating: (0, 0), count: columns)
				lockedCoordinates = newLine + lockedCoordinates
			}
		}
	}

	
}


enum Tetromino {
	case square
	case line
}

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
