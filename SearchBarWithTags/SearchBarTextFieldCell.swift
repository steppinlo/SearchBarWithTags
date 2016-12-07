import UIKit

class SearchBarTextFieldCell: UICollectionViewCell {
    let textField = UITextField(frame: CGRect.zero)
    var placeholderText: String? {
        didSet {
            textField.placeholder = placeholderText
        }
    }
    var textFieldFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            textField.font = textFieldFont
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: bounds.height))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        addSubview(textField)
    }
    
    override func layoutSubviews() {
        textField.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
