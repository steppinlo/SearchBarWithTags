import UIKit

protocol SearchBarCollectionViewDelegate {
    func showActiveSearchState()
    func searchFieldChanged(textField: UITextField)
    func searchFieldFinished(textField: UITextField)
}

class SearchBarCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var options = [String]()
    var searchDelegate: SearchBarCollectionViewDelegate!
    var searchBar: SearchBar!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    convenience init(frame: CGRect, collectionLayout: UICollectionViewFlowLayout? = nil, searchBar: SearchBar) {
        self.init(frame: frame, collectionViewLayout: collectionLayout ?? SearchBarCollectionView.flowLayout())
        self.searchBar = searchBar
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func flowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 5
        return flowLayout
    }
    
    func commonInit() {
        layer.cornerRadius = 3
        backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 232/255, alpha: 1.0)
        register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "query")
        register(SearchBarTextFieldCell.self, forCellWithReuseIdentifier: "SearchBarTextField")
        delegate = self
        dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? options.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 && options.count > 0 {
            return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 {
            let h = collectionView.bounds.height - 5
            return CGSize(width: collectionView.bounds.width, height: h)
        } else {
            let text = options[indexPath.item].lowercased()
            let attributedText = NSAttributedString(
                string: text,
                attributes: [NSFontAttributeName:  searchBar.optionsFont]
            )
            let width = ButtonOptionCollectionViewCell.cellWidth(textWidth: attributedText.size().width)
            return CGSize(width: width, height: collectionView.bounds.height - 5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchBarTextField", for: indexPath) as! SearchBarTextFieldCell
            cell.textField.delegate = self
            cell.placeholderText = searchBar.placeholder
            cell.backgroundColor = .clear
            cell.textField.font = searchBar.searchBarFont
            cell.textField.addTarget(
                self,
                action: #selector(SearchBarCollectionView.textFieldDidChange(sender:)),
                for: .editingChanged
            )
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! ButtonOptionCollectionViewCell
            let text = options[indexPath.item].lowercased()
            let attributes = [NSFontAttributeName:  searchBar.optionsFont]
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            cell.color = searchBar.tagColor
            cell.optionTitleColor = searchBar.tagTextColor
            cell.optionTitle.attributedText = attributedText
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            options.remove(at: indexPath.item)
            performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
                }, completion: { _ in
                    //seems to prevent the race condition of datasource updating and search not showing up.
                    collectionView.reloadItems(at: self.indexPathsForVisibleItems)
            })
        }
    }
    
    func fetchSearchText() -> String? {
        let cell = cellForItem(at: IndexPath(item: 0, section: 1)) as! SearchBarTextFieldCell
        return cell.textField.text
    }
    
    func addOption(option: String) {
        options.append(option)
        let ip = IndexPath(item: options.count - 1, section: 0)
        insertItems(at: [ip])
    }
    
    func textFieldDidChange(sender: UITextField) {
        searchDelegate?.searchFieldChanged(textField: sender)
    }
}

extension SearchBarCollectionView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchDelegate?.showActiveSearchState()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchDelegate?.searchFieldFinished(textField: textField)
    }
}
