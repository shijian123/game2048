import Foundation

enum MoveDirection {
    case up, down, left, right
}

class GameBoard {
    private let size = 4
    private var board: [[Int]]
    private var score: Int = 0
    
    init() {
        board = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        addNewTile()
        addNewTile()
    }
    
    func move(_ direction: MoveDirection) -> Bool {
        var moved = false
        
        switch direction {
        case .up:
            moved = moveUp()
        case .down:
            moved = moveDown()
        case .left:
            moved = moveLeft()
        case .right:
            moved = moveRight()
        }
        
        if moved {
            addNewTile()
        }
        
        return moved
    }
    
    private func addNewTile() {
        var emptyCells = [(Int, Int)]()
        
        for i in 0..<size {
            for j in 0..<size {
                if board[i][j] == 0 {
                    emptyCells.append((i, j))
                }
            }
        }
        
        if let randomCell = emptyCells.randomElement() {
            board[randomCell.0][randomCell.1] = Int.random(in: 1...2) * 2
        }
    }
    
    // 添加辅助方法来转置矩阵
    private func transpose() {
        for i in 0..<size {
            for j in i..<size {
                let temp = board[i][j]
                board[i][j] = board[j][i]
                board[j][i] = temp
            }
        }
    }
    
    // 添加辅助方法来反转行
    private func reverseRows() {
        for i in 0..<size {
            board[i].reverse()
        }
    }
    
    // 更新 moveLeft 方法（保持原有逻辑不变）
    private func moveLeft() -> Bool {
        var moved = false
        for i in 0..<size {
            var row = board[i].filter { $0 != 0 }
            var j = 0
            while j < row.count - 1 {
                if row[j] == row[j + 1] {
                    row[j] *= 2
                    score += row[j]
                    row.remove(at: j + 1)
                    moved = true
                }
                j += 1
            }
            while row.count < size {
                row.append(0)
            }
            if board[i] != row {
                moved = true
                board[i] = row
            }
        }
        return moved
    }
    
    // 实现向右移动
    private func moveRight() -> Bool {
        reverseRows()
        let moved = moveLeft()
        reverseRows()
        return moved
    }
    
    // 实现向上移动
    private func moveUp() -> Bool {
        transpose()
        let moved = moveLeft()
        transpose()
        return moved
    }
    
    // 实现向下移动
    private func moveDown() -> Bool {
        transpose()
        let moved = moveRight()
        transpose()
        return moved
    }
    
    // 添加获取当前棋盘状态的方法
    func getBoardState() -> [[Int]] {
        return board
    }
    
    // 添加获取当前分数的方法
    func getScore() -> Int {
        return score
    }
    
    // 添加判断游戏是否结束的方法
    func isGameOver() -> Bool {
        // 检查是否有空格
        for i in 0..<size {
            for j in 0..<size {
                if board[i][j] == 0 {
                    return false
                }
            }
        }
        
        // 检查是否有相邻的相同数字
        for i in 0..<size {
            for j in 0..<size {
                if j < size - 1 && board[i][j] == board[i][j + 1] {
                    return false
                }
                if i < size - 1 && board[i][j] == board[i + 1][j] {
                    return false
                }
            }
        }
        
        return true
    }
    
    // 添加判断是否获胜的方法（达到2048）
    func hasWon() -> Bool {
        for i in 0..<size {
            for j in 0..<size {
                if board[i][j] == 2048 {
                    return true
                }
            }
        }
        return false
    }
} 