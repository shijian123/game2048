import Foundation
import UIKit

struct Tile {
    var value: Int
    var position: (row: Int, col: Int)
    var isNew: Bool = true
    var wasMerged: Bool = false
    
    init(value: Int, position: (row: Int, col: Int)) {
        self.value = value
        self.position = position
    }
    
    // 获取瓦片的背景颜色
    var backgroundColor: UIColor {
        switch value {
        case 2: return UIColor(red: 0.93, green: 0.89, blue: 0.85, alpha: 1.0)
        case 4: return UIColor(red: 0.93, green: 0.87, blue: 0.78, alpha: 1.0)
        case 8: return UIColor(red: 0.95, green: 0.69, blue: 0.47, alpha: 1.0)
        case 16: return UIColor(red: 0.96, green: 0.58, blue: 0.39, alpha: 1.0)
        case 32: return UIColor(red: 0.96, green: 0.49, blue: 0.37, alpha: 1.0)
        case 64: return UIColor(red: 0.96, green: 0.37, blue: 0.23, alpha: 1.0)
        case 128: return UIColor(red: 0.93, green: 0.81, blue: 0.45, alpha: 1.0)
        case 256: return UIColor(red: 0.93, green: 0.80, blue: 0.38, alpha: 1.0)
        case 512: return UIColor(red: 0.93, green: 0.78, blue: 0.31, alpha: 1.0)
        case 1024: return UIColor(red: 0.93, green: 0.77, blue: 0.25, alpha: 1.0)
        case 2048: return UIColor(red: 0.93, green: 0.76, blue: 0.18, alpha: 1.0)
        default: return UIColor(red: 0.80, green: 0.77, blue: 0.73, alpha: 1.0)
        }
    }
} 
