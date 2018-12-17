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
