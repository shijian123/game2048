//
//  GameViewController.swift
//  game2048
//
//  Created by 达达 on 2024/11/29.
//

import UIKit

class GameViewController: UIViewController {
    
    private let boardSize: CGFloat = UIScreen.main.bounds.width - 40 // 留出边距
    private var gameBoard = GameBoard()
    private var tileViews: [[TileView]] = []
    private let spacing: CGFloat = 10
    
    private lazy var boardView: UIView = {
        let view = UIView(frame: CGRect(x: 20, y: 150, width: boardSize, height: boardSize))
        view.backgroundColor = UIColor(red: 0.72, green: 0.66, blue: 0.63, alpha: 1.0)
        view.layer.cornerRadius = 6
        return view
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .darkGray
        label.text = "Score: 0"
        return label
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("重新开始", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor(red: 0.72, green: 0.66, blue: 0.63, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 添加新属性来控制动画
    private var isAnimating = false
    private let animationDuration: TimeInterval = 0.2
    
    private lazy var rankingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("查看排行", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor(red: 0.72, green: 0.66, blue: 0.63, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(showRanking), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        createTileGrid()
        updateUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.94, blue: 0.92, alpha: 1.0)
        
        // 添加分数标签
        view.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        view.addSubview(boardView)
        
        // 添加重置按钮
        view.addSubview(resetButton)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 30),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 添加排行榜按钮
        view.addSubview(rankingButton)
        rankingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rankingButton.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 20),
            rankingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rankingButton.widthAnchor.constraint(equalToConstant: 120),
            rankingButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupGestures() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
        
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            gesture.direction = direction
            view.addGestureRecognizer(gesture)
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        // 如果正在动画中，忽略新的手势
        guard !isAnimating else { return }
        
        isAnimating = true
        
        // 直接执行移动逻辑
        let moved = self.gameBoard.move(gesture.direction == .up ? .up :
                                      gesture.direction == .down ? .down :
                                      gesture.direction == .left ? .left : .right)
        
        if moved {
            self.generateHapticFeedback()
            // 立即更新分数
            self.scoreLabel.text = "Score: \(self.gameBoard.getScore())"
            self.animateChanges()
        } else {
            self.showShakeAnimation()
            self.isAnimating = false
        }
    }
    
    private func animateChanges() {
        let boardState = gameBoard.getBoardState()
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut) {
            // 更新瓦片位置和值
            for i in 0..<4 {
                for j in 0..<4 {
                    let value = boardState[i][j]
                    let tileView = self.tileViews[i][j]
                    
                    if value != 0 {
                        let oldValue = tileView.tile?.value
                        tileView.tile = Tile(value: value, position: (i, j))
                        
                        // 只有当数值发生变化（合并）时才播放动画
                        if let old = oldValue, old != value {
                            tileView.animateMerge()
                        } else if oldValue == nil {
                            // 新出现的瓦片使用出现动画
                            tileView.animateAppearance()
                        }
                    } else {
                        tileView.tile = nil
                    }
                }
            }
            
            // 确保分数更新是最新的
            self.scoreLabel.text = "Score: \(self.gameBoard.getScore())"
            
        } completion: { _ in
            self.isAnimating = false
            
            // 检查游戏状态
            if self.gameBoard.isGameOver() {
                self.showGameOver()
            } else if self.gameBoard.hasWon() {
                self.showWin()
            }
        }
    }
    
    private func showShakeAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.2
        animation.values = [-3, 3, -2, 2, -1, 1, 0]
        boardView.layer.add(animation, forKey: "shake")
    }
    
    // 添加触觉反馈
    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func showGameOver() {
        // 添加新的分数记录
        ScoreManager.shared.addScore(gameBoard.getScore())
        
        let alert = UIAlertController(title: "游戏结束", 
                                    message: "最终得分: \(gameBoard.getScore())", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "重新开始", style: .default) { [weak self] _ in
            self?.resetGame()
        })
        present(alert, animated: true)
    }
    
    private func showWin() {
        let alert = UIAlertController(title: "恭喜!", message: "你赢了！得分: \(gameBoard.getScore())", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "继续游戏", style: .default))
        alert.addAction(UIAlertAction(title: "重新开始", style: .default) { [weak self] _ in
            self?.resetGame()
        })
        present(alert, animated: true)
    }
    
    @objc private func resetButtonTapped() {
        resetGame()
    }
    
    private func resetGame() {
        // 重置游戏板
        gameBoard = GameBoard()
        
        // 重置所有瓦片视图
        for row in tileViews {
            for tileView in row {
                tileView.tile = nil
            }
        }
        
        // 更新UI显示新的初始状态
        updateUI()
        
        // 添加重置动画效果
        UIView.animate(withDuration: 0.3) {
            self.boardView.alpha = 0.5
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.boardView.alpha = 1.0
            }
        }
        
        // 重置分数
        scoreLabel.text = "Score: 0"
        
        // 添加触觉反馈
        generateHapticFeedback()
    }
    
    private func animateNewTile(_ tileView: TileView) {
        tileView.alpha = 0
        UIView.animate(withDuration: 0.2) {
            tileView.alpha = 1
            tileView.animateAppearance()
        }
    }
    
    private func updateUIWithAnimation() {
        let boardState = gameBoard.getBoardState()
        
        // 记录旧的位置
        let oldPositions = tileViews.map { row in
            row.map { tileView in
                tileView.frame.origin
            }
        }
        
        // 更新新的位置
        UIView.animate(withDuration: 0.2) {
            for i in 0..<4 {
                for j in 0..<4 {
                    let value = boardState[i][j]
                    let tileView = self.tileViews[i][j]
                    
                    if value != 0 {
                        if tileView.tile == nil || tileView.tile?.value != value {
                            // 新的瓦片或合并的瓦片
                            tileView.tile = Tile(value: value, position: (i, j))
                            self.animateNewTile(tileView)
                        }
                    } else {
                        tileView.tile = nil
                    }
                }
            }
        }
    }
    
    @objc private func showRanking() {
        let rankingVC = RankingViewController()
        let nav = UINavigationController(rootViewController: rankingVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    private func createTileGrid() {
        let tileSize = (boardSize - spacing * 5) / 4 // 计算每个瓦片的大小
        
        for i in 0..<4 {
            var row: [TileView] = []
            for j in 0..<4 {
                let x = spacing + CGFloat(j) * (tileSize + spacing)
                let y = spacing + CGFloat(i) * (tileSize + spacing)
                
                let tileView = TileView(frame: CGRect(x: x, y: y, 
                                                     width: tileSize, height: tileSize))
                boardView.addSubview(tileView)
                row.append(tileView)
            }
            tileViews.append(row)
        }
    }
    
    private func updateUI() {
        let boardState = gameBoard.getBoardState()
        
        // 更新每个瓦片的状态
        for i in 0..<4 {
            for j in 0..<4 {
                let value = boardState[i][j]
                if value != 0 {
                    tileViews[i][j].tile = Tile(value: value, position: (i, j))
                } else {
                    tileViews[i][j].tile = nil
                }
            }
        }
        
        // 更新分数
        scoreLabel.text = "Score: \(gameBoard.getScore())"
    }
}
