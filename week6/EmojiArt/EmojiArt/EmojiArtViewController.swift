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
    
    private var emojis = "😀🎁✈️🎱🍎🐶🐝☕️🎼🚲♣️👨‍🎓✏️🌈🤡🎓👻☎️".map { String($0) }
    
    
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
            
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
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


// MARK: - UICollectionViewDragDelegate

extension EmojiArtViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForAddingTo session: UIDragSession, at indexPath: IndexPath,
                        point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            // Drag locally; don't need to go through all that item provider stuff: the async getting data (as in drop interaction)
            // Just grab the local object; a way of like short-circuiting all that
            dragItem.localObject = attributedString
            return [dragItem]
        }
        return []
    }
    
}

// MARK: - UICollectionViewDropDelegate

extension EmojiArtViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for dropItem in coordinator.items {
            if let sourceIndexPath = dropItem.sourceIndexPath { // Local drag
                //if let attributedString = dropItem.dragItem.localObject as? NSAttributedString {
                if let _ = dropItem.dragItem.localObject as? NSAttributedString {
                    collectionView.performBatchUpdates({
                        /*
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destinationIndexPath.item)
                        */
                        emojis.moveElement(fromIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
                }
            } else { // Remote drag (i.e. from another app)
                let placeholderContext = coordinator.drop(
                                            dropItem.dragItem,
                                            to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath,
                                                                                reuseIdentifier: "DropPlaceholderCell"))
                dropItem.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (providerData, error) in
                    DispatchQueue.main.async {
                        if let attributedString = providerData as? NSAttributedString {
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                // Note: insertionIndexPath might be different from destinationIndexPath
                                // because the collection view might have changed during the data-load process
                                self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
}


// MARK: - Utility extensions

extension Array {
    
    mutating func moveElement(fromIndex from: Int, toIndex to: Int) {
        guard from != to else { return }
        let value = self[from]
        if from < to {
            for idx in from..<to {
                self[idx] = self[idx + 1]
            }
        } else {
            for idx in (to+1...from).reversed() {
                self[idx] = self[idx - 1]
            }
        }
        self[to] = value
    }
    
}

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
