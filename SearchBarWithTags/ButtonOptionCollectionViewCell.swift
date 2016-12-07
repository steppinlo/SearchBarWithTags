import UIKit

class ButtonOptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var optionToggleIcon: UIImageView!
    @IBOutlet weak var optionTitle: UILabel!
    
    var color: UIColor = .blackColor() {
        didSet {
            backgroundColor = color
        }
    }
    var optionTitleColor: UIColor = .whiteColor() {
        didSet {
            optionTitle.textColor = optionTitleColor
            optionToggleIcon.tintColor = optionTitleColor
        }
    }
    
    private var icon: UIImage {
        return UIImage(named: "appsprite-x")!.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    static func cellWidth(textWidth: CGFloat) -> CGFloat {
        //check storyboard. 7 = label leading, 3 = between button and img, 15 = img width, 5 = img trailing
        return textWidth + 7 + 7 + 10 + 5
    }
    
    override func awakeFromNib() {
        layer.cornerRadius = 3
        optionToggleIcon.image = icon
    }
}
