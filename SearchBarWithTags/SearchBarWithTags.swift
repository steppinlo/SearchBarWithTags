import UIKit

@objc protocol SearchBarDelegate {
    @objc optional func search()
    @objc optional func searchFieldDidChange(textField: UITextField)
    @objc optional func searchFieldFinishedEditing(textField: UITextField)
    @objc optional func currentOptions() -> [String]?
}

class SearchBarWithTags: UIView, SearchBarCollectionViewDelegate {
    private var searchBar: SearchBarCollectionView!
    private var showingButtons: Bool {
        return !cancelButton.hidden && !searchButton.hidden
    }
    private var cancelButton = UIButton(frame: CGRect.zero)
    private var searchButton = UIButton(frame: CGRect.zero)
    private var buttonPadding: CGFloat = 14
    
    var searchButtonColor: UIColor = .blueColor()
    var tagColor: UIColor = .blackColor()
    var tagTextColor: UIColor = .whiteColor()
    var searchTitleColor: UIColor = .whiteColor()
    var cancelTitleColor: UIColor = .blackColor()
    var buttonFont: UIFont = UIFont.systemFontOfSize(14)
    var delegate: SearchBarDelegate? = nil
    var placeholder: String?
    var optionsFont: UIFont = UIFont.systemFontOfSize(14)
    var searchBarFont: UIFont = UIFont.systemFontOfSize(14)
    
    var cancelButtonTitle: String = "Back" {
        didSet {
            self.configureCancelButton()
        }
    }
    var cancelButtonImage: UIImage? {
        didSet {
            self.configureCancelButton()
        }
    }
    var searchButtonTitle: String = "SEARCH" {
        didSet {
            self.configureSearchButton()
        }
    }
    
    var searchBarText: String? {
        return searchBar.fetchSearchText()
    }
    
    var options: [String] {
        get {
            return searchBar.options
        }
        set {
            searchBar.options = newValue
        }
    }
    
    override init(frame: CGRect) {
        let newFrame = CGRect(
            x: 0,
            y: 0,
            width:
            frame.size.width - 20,
            height: frame.size.height - 15
        )
        super.init(frame: newFrame)
        searchBar = SearchBarCollectionView(
            frame: bounds,
            collectionLayout: SearchBarCollectionView.flowLayout(),
            searchBar: self
        )
        searchBar.searchDelegate = self
        addSubview(searchBar)
        addSubview(cancelButton)
        addSubview(searchButton)
        toggleButtons()
    }
    
    override func layoutSubviews() {
        configureCancelButton()
        configureSearchButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func showActiveSearchState() {
        if !showingButtons {
            searchBar.performBatchUpdates({
                self.searchBar.frame = CGRect(
                    x: self.searchBar.frame.minX + self.cancelButton.frame.size.width,
                    y: self.searchBar.frame.minY,
                    width: self.searchBar.frame.width - self.cancelButton.frame.size.width - self.searchButton.frame.size.width,
                    height: self.searchBar.frame.height
                )
                }, completion: nil)
            toggleButtons()
        }
    }
    
    private func closeActiveSearchState() {
        cancelButton.hidden = true
        searchButton.hidden = true
        searchBar.performBatchUpdates({
            self.searchBar.frame = self.bounds
            }, completion: nil)
    }
    
    private func toggleButtons() {
        cancelButton.hidden = !cancelButton.hidden
        searchButton.hidden = !searchButton.hidden
    }
    
    private func searchButtonAttributes() -> [String: AnyObject] {
        return [
            NSFontAttributeName: buttonFont,
            NSForegroundColorAttributeName: searchTitleColor
        ]
    }
    
    private func cancelButtonAttributes() -> [String: AnyObject] {
        return [
            NSFontAttributeName: buttonFont,
            NSForegroundColorAttributeName: cancelTitleColor
        ]
    }
    
    private func configureCancelButton() {
        var width: CGFloat = 0
        
        if cancelButtonImage != nil {
            cancelButton.setImage(cancelButtonImage, forState: .Normal)
            width = cancelButton.imageView!.image!.size.width
        } else {
            let attributedText = NSAttributedString(string: cancelButtonTitle, attributes: cancelButtonAttributes())
            cancelButton.setAttributedTitle(attributedText, forState: .Normal)
            width = attributedText.size().width
        }
        cancelButton.frame = CGRect(x: -5, y: 0, width: width, height: searchBar.frame.size.height)
        cancelButton.addTarget(self, action: #selector(SearchBarWithTags.cancelTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    private func configureSearchButton() {
        let attributedText = NSAttributedString(
            string: searchButtonTitle,
            attributes: searchButtonAttributes()
        )
        let width = attributedText.size().width + buttonPadding
        searchButton.setAttributedTitle(attributedText, forState: .Normal)
        searchButton.frame = CGRect(
            x: bounds.maxX - width + 5,
            y: 0,
            width: width,
            height: searchBar.frame.size.height
        )
        searchButton.layer.cornerRadius = 3
        searchButton.setTitle(searchButtonTitle, forState: .Normal)
        searchButton.backgroundColor = searchButtonColor
        searchButton.addTarget(self, action: #selector(SearchBarWithTags.searchTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    @objc private func cancelTapped(sender: UIButton) {
        endEditing(true)
        sender.hidden = true
        closeActiveSearchState()
    }
    
    @objc private func searchTapped(sender: UIButton) {
        delegate?.search?()
    }
    
    func addSearchBarOption(option: String) {
        searchBar.addOption(option)
    }
    
    internal func searchFieldChanged(textField: UITextField) {
        delegate?.searchFieldDidChange?(textField)
    }
    
    internal func searchFieldFinished(textField: UITextField) {
        delegate?.searchFieldFinishedEditing?(textField)
    }
}
