import UIKit

class TileView: UIView {
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 30)
        label.textColor = .darkGray
        return label
    }()
    
    var tile: Tile? {
        didSet {
            if let tile = tile {
                label.text = "\(tile.value)"
                backgroundColor = tile.backgroundColor
                label.isHidden = false
                
                if tile.value > 4 {
                    label.textColor = .white
                } else {
                    label.textColor = UIColor(red: 0.47, green: 0.43, blue: 0.40, alpha: 1.0)
                }
            } else {
                label.isHidden = true
                backgroundColor = UIColor(red: 0.80, green: 0.77, blue: 0.73, alpha: 0.35)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 6
        backgroundColor = UIColor(red: 0.80, green: 0.77, blue: 0.73, alpha: 0.35)
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func animateAppearance() {
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        alpha = 0
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                self.transform = .identity
            }
        }
    }
    
    func animateMerge() {
        let scaleUp = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.transform = scaleUp
        } completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                self.transform = .identity
            }
        }
    }
} 