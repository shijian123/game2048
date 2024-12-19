import UIKit

class RankingViewController: UIViewController {
    
    private let tableView = UITableView()
    private var records: [ScoreRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRecords()
    }
    
    private func setupUI() {
        title = "最高分排行"
        view.backgroundColor = UIColor(red: 0.95, green: 0.94, blue: 0.92, alpha: 1.0)
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "返回",
            style: .plain,
            target: self,
            action: #selector(dismissVC)
        )
        
        // 设置TableView
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RankCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        // 添加空状态提示
        let emptyLabel = UILabel()
        emptyLabel.text = "暂无记录"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.font = .systemFont(ofSize: 18)
        tableView.backgroundView = emptyLabel
    }
    
    private func loadRecords() {
        records = ScoreManager.shared.getHighScores()
        tableView.backgroundView?.isHidden = !records.isEmpty
        tableView.reloadData()
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
}

extension RankingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count // 只返回实际的记录数量
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankCell", for: indexPath)
        cell.backgroundColor = .clear
        
        let record = records[indexPath.row]
        let prefix = indexPath.row < 3 ? ["🏆", "🥈", "🥉"][indexPath.row] : "\(indexPath.row + 1)."
        cell.textLabel?.text = "\(prefix) 分数: \(record.score)  时间: \(record.formattedDate)"
        
        // 设置前三名的样式
        if indexPath.row < 3 {
            cell.textLabel?.font = .boldSystemFont(ofSize: 17)
            switch indexPath.row {
            case 0:
                cell.textLabel?.textColor = UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)
            case 1:
                cell.textLabel?.textColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
            case 2:
                cell.textLabel?.textColor = UIColor(red: 0.80, green: 0.50, blue: 0.20, alpha: 1.0)
            default:
                break
            }
        } else {
            cell.textLabel?.font = .systemFont(ofSize: 16)
            cell.textLabel?.textColor = .darkGray
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
} 