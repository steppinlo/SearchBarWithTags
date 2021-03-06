import UIKit

@objc public protocol SearchBarDelegate {
    @objc optional func searchTapped()
    @objc optional func backTapped()
    @objc optional func tagRemovedTapped(title: String)
    @objc optional func searchFieldDidChange(textField: UITextField)
    @objc optional func searchFieldFinishedEditing(textField: UITextField)
    @objc optional func searchFieldDidBeginEditing(textField: UITextField)
}

public class SearchBarWithTags: UIView, SearchBarCollectionViewDelegate {
    private var searchBar: SearchBarCollectionView!
    private var showingButtons: Bool {
        return !cancelButton.hidden && !searchButton.hidden
    }
    private var cancelButton = UIButton(frame: CGRect.zero)
    private var searchButton = UIButton(frame: CGRect.zero)
    private var buttonPadding: CGFloat = 14
    
    public var searchButtonColor: UIColor = .blueColor()
    public var tagColor: UIColor = .blackColor()
    public var tagTextColor: UIColor = .whiteColor()
    public var searchTitleColor: UIColor = .whiteColor()
    public var cancelTitleColor: UIColor = .blackColor()
    public var buttonFont: UIFont = UIFont.systemFontOfSize(14)
    public var delegate: SearchBarDelegate? = nil
    public var placeholder: String = "SEARCH"
    public var optionsFont: UIFont = UIFont.systemFontOfSize(14)
    public var searchBarFont: UIFont = UIFont.systemFontOfSize(14)
    
    public var cancelButtonTitle: String = "Back" {
        didSet {
            self.configureCancelButton()
        }
    }
    public var cancelButtonImage: UIImage? {
        didSet {
            self.configureCancelButton()
        }
    }
    public var searchButtonTitle: String = "SEARCH" {
        didSet {
            self.configureSearchButton()
        }
    }
    
    public var searchBarText: String? {
        get {
            return searchBar.cachedTitle
        }
        set {
            searchBar.setTitle(newValue)
        }
    }
    
    public var options: [String] {
        get {
            return searchBar.options
        }
        set {
            searchBar.options = newValue
            searchBar.reloadData()
        }
    }
    
    override public init(frame: CGRect) {
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
            searchBar: self
        )
        searchBar.searchDelegate = self
        addSubview(searchBar)
        addSubview(cancelButton)
        addSubview(searchButton)
        toggleButtons()
    }
    
    override public func layoutSubviews() {
        configureCancelButton()
        configureSearchButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func searchFieldActive(textField: UITextField) {
        if cancelButton.hidden {
            searchBar.performBatchUpdates({
                self.searchBar.frame = CGRect(
                    x: self.searchBar.frame.minX + self.cancelButton.frame.size.width,
                    y: self.searchBar.frame.minY,
                    width: self.searchBar.frame.width - self.cancelButton.frame.size.width - self.searchButton.frame.size.width,
                    height: self.searchBar.frame.height
                )
                }, completion: nil)
            toggleButtons()
        } else if !cancelButton.hidden && searchButton.hidden{
            searchBar.performBatchUpdates({
                self.searchBar.frame = CGRect(
                    x: self.searchBar.frame.minX,
                    y: self.searchBar.frame.minY,
                    width: self.searchBar.frame.width - self.searchButton.frame.size.width,
                    height: self.searchBar.frame.height
                )
                }, completion: nil)
            searchButton.hidden = false
        }
        delegate?.searchFieldDidBeginEditing?(textField)
    }
    
    public func closeActiveSearchState() {
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
        delegate?.backTapped?()
    }

    @objc private func searchTapped(sender: UIButton) {
        resetViewWithBackButton()
        endEditing(true)
        delegate?.searchTapped?()
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

    public func resetViewWithBackButton() {
        searchBar.performBatchUpdates({ [weak self] _ in
            guard let `self` = self else { return }
            self.searchBar.frame = CGRect(
                x: self.searchBar.frame.minX + (self.cancelButton.hidden ? self.cancelButton.frame.size.width : 0),
                y: self.searchBar.frame.minY,
                width: self.searchBar.frame.width + (self.searchButton.hidden ? 0 : self.searchButton.frame.size.width),
                height: self.searchBar.frame.height
            )
            }, completion: nil
        )
        searchButton.hidden = true
        cancelButton.hidden = false
    }

    public func addOption(title: String) {
        options.append(title)
    }

    public func removeOption(title: String) {
        for (index, option) in options.enumerate() {
            if option == title {
                options.removeAtIndex(index)
            }
        }
    }

    public func tagRemovedTapped(title: String) {
        delegate?.tagRemovedTapped?(title)
    }

    public func resetSearchBar() {
        searchBar.options.removeAll()
        searchBarText = nil
        searchBar.cachedTitle = nil
    }
}
