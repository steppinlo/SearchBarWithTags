import UIKit

protocol SearchBarCollectionViewDelegate {
    func searchFieldActive(textField: UITextField)
    func searchFieldChanged(textField: UITextField)
    func searchFieldFinished(textField: UITextField)
    func tagRemovedTapped(text: String)
}

class SearchBarCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var options = [String]()
    var searchDelegate: SearchBarCollectionViewDelegate!
    var searchBar: SearchBarWithTags!
    var cachedTitle: String?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    convenience init(frame: CGRect, searchBar: SearchBarWithTags) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 3
        flowLayout.minimumInteritemSpacing = 3

        self.init(frame: frame, collectionViewLayout: flowLayout)
        self.searchBar = searchBar
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        layer.cornerRadius = 3
        backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 232/255, alpha: 1.0)
        registerNib(
            UINib(
                nibName: "TagCell",
                bundle: NSBundle(forClass: SearchBarWithTags.self)
            ),
            forCellWithReuseIdentifier: "TagCell"
        )
        registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "query")
        registerClass(SearchBarTextFieldCell.self, forCellWithReuseIdentifier: "SearchBarTextField")
        delegate = self
        dataSource = self
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? options.count : 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section == 0 && options.count > 0 {
            return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        } else {
            return UIEdgeInsetsZero
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 1 {
            let h = collectionView.bounds.height - 5
            return CGSize(width: collectionView.bounds.width, height: h)
        } else {
            let text = options[indexPath.item]
            let attributedText = NSAttributedString(
                string: text,
                attributes: [NSFontAttributeName:  searchBar.optionsFont]
            )
            let width = ButtonOptionCollectionViewCell.cellWidth(attributedText.size().width)
            return CGSize(width: width, height: collectionView.bounds.height - 5)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SearchBarTextField", forIndexPath: indexPath) as! SearchBarTextFieldCell
            cell.textField.delegate = self
            cell.textField.text = cachedTitle
            cell.placeholderText = searchBar.placeholder
            cell.backgroundColor = .clearColor()
            cell.textField.font = searchBar.searchBarFont
            cell.textField.addTarget(
                self,
                action: #selector(SearchBarCollectionView.textFieldDidChange(_:)),
                forControlEvents: .EditingChanged
            )
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCell", forIndexPath: indexPath) as! ButtonOptionCollectionViewCell
            let text = options[indexPath.item]
            let attributes = [NSFontAttributeName:  searchBar.optionsFont]
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            cell.color = searchBar.tagColor
            cell.optionTitleColor = searchBar.tagTextColor
            cell.optionTitle.attributedText = attributedText
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let objToRemove = options[indexPath.item]
            options.removeAtIndex(indexPath.item)
            performBatchUpdates({
                collectionView.deleteItemsAtIndexPaths([indexPath])
                }, completion: { [weak self] _ in
                    guard let `self` = self else { return }
                    self.searchDelegate?.tagRemovedTapped(objToRemove)
                    //seems to prevent the race condition of datasource updating and search not showing up.
                    collectionView.reloadItemsAtIndexPaths((self.indexPathsForVisibleItems()))
                })
        }
    }

    func setTitle(title: String?) {
        cachedTitle = title
        reloadData()
    }
    
    func addOption(option: String) {
        options.append(option)
        let ip = NSIndexPath(forItem: options.count - 1, inSection: 0)
        insertItemsAtIndexPaths([ip])
    }
    
    func textFieldDidChange(sender: UITextField) {
        cachedTitle = sender.text
        searchDelegate?.searchFieldChanged(sender)
    }
}

extension SearchBarCollectionView: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        searchDelegate?.searchFieldActive(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        searchDelegate?.searchFieldFinished(textField)
    }
}
