import Foundation

struct ScoreRecord: Codable {
    let score: Int
    let date: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

class ScoreManager {
    static let shared = ScoreManager()
    private let maxRecords = 10 // 保存前10个最高分
    private let userDefaultsKey = "highScores"
    
    private init() {}
    
    func getHighScores() -> [ScoreRecord] {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let records = try? JSONDecoder().decode([ScoreRecord].self, from: data) {
            return records
        }
        return []
    }
    
    func addScore(_ score: Int) {
        var records = getHighScores()
        let newRecord = ScoreRecord(score: score, date: Date())
        records.append(newRecord)
        records.sort { $0.score > $1.score } // 按分数降序排序
        records = Array(records.prefix(maxRecords)) // 只保留前5个最高分
        
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
} 
