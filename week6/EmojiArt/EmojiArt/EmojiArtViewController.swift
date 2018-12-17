//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Cong Doan on 11/30/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController {
    
    // MARK: - Stored props
    
    private lazy var imageFetcher = ImageFetcher() { (url, image) in
        DispatchQueue.main.async {
            self.emojiArtViewBackgroundImage = image
        }
    }
    
    private let emojiArtView = EmojiArtView()
    
    private let emojis = "😀🎁✈️🎱🍎🐶🐝☕️🎼🚲♣️👨‍🎓✏️🌈🤡🎓👻☎️".map { String($0) }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView)
        }
    }
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet {
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var emojiCollectionViewHeight: NSLayoutConstraint!
    
    
    // MARK: - Lifecycle methods
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        emojiCollectionViewHeight.constant = emojis[0].size(inFont: emojiFont).maxDimension + 10.0
        emojiCollectionView.reloadData()
    }
    
    
    // MARK: - Helper computed var and func
    
    private var emojiArtViewBackgroundImage: UIImage? {
        get {
            return emojiArtView.backgroundImage
        }
        set {
            emojiArtView.backgroundImage = newValue
            let size = newValue?.size ?? .zero
            emojiArtView.frame = CGRect(origin: .zero, size: size)
            scrollView.contentSize = size
            if size.width > 0, size.height > 0 {
                scrollView.zoomScale = max(dropZone.bounds.width / size.width, dropZone.bounds.height / size.height)
            }
            
            adjustScrollViewSizeConstraints()
        }
    }
    
    private func adjustScrollViewSizeConstraints() {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
    
}


// MARK: - UIScrollViewDelegate

extension EmojiArtViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustScrollViewSizeConstraints()
    }
    
}


// MARK: - UIDropInteractionDelegate

extension EmojiArtViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // NOTE: imageFetcher couldn't be defined in this method cause it would had left the heap by the time the fetch finished
        
        session.loadObjects(ofClass: NSURL.self) { (nsurls) in
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { (images) in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
    }
    
}


// MARK: - UICollectionViewDataSource

extension EmojiArtViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    private var emojiFont: UIFont {
        let font = UIFont.preferredFont(forTextStyle: .body).withSize(64)
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath)
        if let emojiCell = cell as? EmojiCollectionViewCell {
            let emoji = emojis[indexPath.row]
            let text = NSAttributedString(string: emoji, attributes: [.font: emojiFont])
            emojiCell.label.attributedText = text
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

// NOTE: UICollectionViewDelegateFlowLayout does inherit UICollectionViewDelegate
extension EmojiArtViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return emojis[indexPath.item].size(inFont: emojiFont)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return max(emojiFont.pointSize * 10.0 / 76.0, 10)
    }
    
}


// MARK: - Utility extensions

extension String {
    
    func size(inFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
}


extension CGSize {
    
    var maxDimension: CGFloat {
        return max(self.width, self.height)
    }
    
}
