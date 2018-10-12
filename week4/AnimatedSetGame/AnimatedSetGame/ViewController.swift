//
//  ViewController.swift
//  SetGame
//
//  Created by Cong Doan on 8/16/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var deck = Deck()
    
    private let numberOfCardsToStart = 12
    private lazy var cards = deck.deal(numberOfCards: numberOfCardsToStart)

    @IBOutlet weak var cardsContainerView: CardContainerView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealMorecards))
            swipe.direction = [.right, .down, .left, .up]
            cardsContainerView.addGestureRecognizer(swipe)
            
            let rotatation = UIRotationGestureRecognizer(target: self, action: #selector(onRotationGesture(_:)))
            cardsContainerView.addGestureRecognizer(rotatation)
        }
    }
    
    private var cardViews: [CardView] { return cardsContainerView.subviews as! [CardView] }
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var selectedCardIndices = [Int]()
    private var areSelectedCardsASet = false
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "table_surface"))
        
        populateCardsContainerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let deckFrameInCardsContainerView = dealButton.superview!.convert(dealButton.frame, to: cardsContainerView)
        cardsContainerView.dealButtonFrame = deckFrameInCardsContainerView
        
        cardsContainerView.positionCardViews(numberOfTransparentCardViewsInTheEnd: numberOfCardsToStart)
    }
    
    private func populateCardsContainerView() {
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
        
        for idx in cards.indices {
            let cardView = CardView()
            cardView.backgroundColor = .clear
            cardView.contentMode = .redraw
            cardView.alpha = 0
            cardsContainerView.addSubview(cardView)
            cardView.tag = idx
            // Cannot assign a single gesture recognizer object to more than one view objects
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCardViewTap(recognizedBy:)))
            cardView.gestureRecognizers = [tapRecognizer]
            populateCardView(cardView, with: cards[idx])
        }
    }

    @objc func onCardViewTap(recognizedBy tapRecognizer: UITapGestureRecognizer) {
        let cardView = tapRecognizer.view as! CardView
        let cardIdx = cardView.tag

        if selectedCardIndices.count == Deck.SET_SIZE {
            onTapWhen3CardsSelected(cardIdx)
            return
        }

        cardView.isSelected = !cardView.isSelected
        if cardView.isSelected {
            selectedCardIndices.append(cardIdx)
            if selectedCardIndices.count == Deck.SET_SIZE {
                let selectedCards = selectedCardIndices.map{cards[$0]}
                areSelectedCardsASet = Deck.isSet(selectedCards)
                score += areSelectedCardsASet ? Constant.Score.match : Constant.Score.mismatch
            }
        } else {
            selectedCardIndices.remove(at: selectedCardIndices.index(of: cardIdx)!)
            score += Constant.Score.deselect
        }
    }
    
    @IBOutlet weak var dealButton: UIButton!
    
    @IBAction func onDealButtonTap(_ sender: Any) {
        dealMorecards()
    }
    
    @objc private func dealMorecards() {
        if deck.isEmpty { return }
        if selectedCardIndices.count == Deck.SET_SIZE && areSelectedCardsASet {
            replaceWith(deck.deal())
            selectedCardIndices = []
        } else {
            addWith(deck.deal())
        }
        updateEnabledStatusOfDealButton()
    }
    
    @IBAction func onNewGameButtonTap(_ sender: Any) {
        deck = Deck()
        cards = deck.deal(numberOfCards: numberOfCardsToStart)
        populateCardsContainerView()
        cardsContainerView.positionCardViews(numberOfTransparentCardViewsInTheEnd: numberOfCardsToStart)
        selectedCardIndices = []
        score = 0
        dealButton.isEnabled = true
        dealButton.setTitleColor(.white, for: .normal)
    }
    
    private func updateEnabledStatusOfDealButton() {
        if deck.isEmpty {
            dealButton.isEnabled = false
            dealButton.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    private func onTapWhen3CardsSelected(_ tappedCardIndex: Int) {
        if areSelectedCardsASet {
            if deck.isEmpty {
                removeMatchedCards(tappedCardIndex)
            } else {
                replaceWith(deck.deal(), completion: updateEnabledStatusOfDealButton)
                selectedCardIndices = selectedCardIndices.contains(tappedCardIndex) ? [] : [tappedCardIndex]
            }
            for selectedIdx in selectedCardIndices {
                cardViews[selectedIdx].isSelected = true
            }
        } else {
            for selectedIdx in selectedCardIndices {
                cardViews[selectedIdx].isSelected = false
            }
            cardViews[tappedCardIndex].isSelected = true
            selectedCardIndices = [tappedCardIndex]
        }
    }
    
    private func removeMatchedCardViews(_ tappedCardIndex: Int) {
        selectedCardIndices.sort()
        
        cards.remove(positions: selectedCardIndices, true)
        
        for reversedIdx in self.selectedCardIndices.indices.reversed() {
            let selectedCardIdxLargeToSmall = self.selectedCardIndices[reversedIdx]
            self.cardViews[selectedCardIdxLargeToSmall].removeFromSuperview()
        }
        cardsContainerView.positionCardViews(numberOfTransparentCardViewsInTheEnd: 0)
        
        let minSelectedCardIdx = selectedCardIndices.first!
        for idx in minSelectedCardIdx..<cardViews.count {
            cardViews[idx].tag = idx
        }
        
        var numSelectedIndicesLessThanTappedOne = 0
        for selectedCardIndex in selectedCardIndices {
            if selectedCardIndex < tappedCardIndex {
                numSelectedIndicesLessThanTappedOne += 1
            } else if selectedCardIndex == tappedCardIndex {
                selectedCardIndices = []
                break
            }
        }
        if selectedCardIndices.count == Deck.SET_SIZE {
            selectedCardIndices = [tappedCardIndex - numSelectedIndicesLessThanTappedOne]
        }
    }
    
    private func removeMatchedCards(_ tappedCardIndex: Int) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 2,
            delay: 0,
            options: [.curveLinear],
            animations: {
                for reversedIdx in self.selectedCardIndices.indices.reversed() {
                    let selectedCardIdxLargeToSmall = self.selectedCardIndices[reversedIdx]
                    self.cardViews[selectedCardIdxLargeToSmall].alpha = 0
                }
            },
            completion: { finalPosition in
                self.removeMatchedCardViews(tappedCardIndex)
            })
    }
    
    private func replaceWith(_ newlyDealtCards: [Card], completion: (() -> Void)? = nil) {
        let selectedCardIndices = self.selectedCardIndices
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 2,
            delay: 0,
            options: [.curveLinear],
            animations: {
                for selectedCardIndex in selectedCardIndices {
                    self.cardViews[selectedCardIndex].alpha = 0
                }
            },
            completion: { finalPosition in
                var selectedCardIndex2CardViewFrame = [Int: CGRect]()
                for arrayIndex in newlyDealtCards.indices {
                    let selectedCardIndex = selectedCardIndices[arrayIndex]
                    let newCard = newlyDealtCards[arrayIndex]
                    self.cards[selectedCardIndex] = newCard
                    populateCardView(self.cardViews[selectedCardIndex], with: newCard)
                    self.cardViews[selectedCardIndex].isSelected = false
                    selectedCardIndex2CardViewFrame[selectedCardIndex] = self.cardViews[selectedCardIndex].frame
                    self.cardViews[selectedCardIndex].frame = self.cardsContainerView.dealButtonFrame
                    self.cardViews[selectedCardIndex].alpha = 1
                }
                
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 2,
                    delay: 0,
                    options: [.curveLinear],
                    animations: {
                        for selectedCardIndex in selectedCardIndices {
                            self.cardViews[selectedCardIndex].frame = selectedCardIndex2CardViewFrame[selectedCardIndex]!
                        }
                    },
                    completion: nil)
                completion?()
            })
    }
    
    private func addWith(_ newlyDealtCards: [Card]) {
        for newCard in newlyDealtCards {
            cards.append(newCard)
            let newCardView = CardView()
            newCardView.backgroundColor = .clear
            newCardView.contentMode = .redraw
            newCardView.tag = cardViews.count
            newCardView.alpha = 0
            cardsContainerView.addSubview(newCardView)
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCardViewTap(recognizedBy:)))
            newCardView.gestureRecognizers = [tapRecognizer]
            populateCardView(newCardView, with: newCard)
        }
        
        cardsContainerView.positionCardViews(numberOfTransparentCardViewsInTheEnd: newlyDealtCards.count)
    }
    
    @objc private func onRotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .ended {
            let selectedCards = selectedCardIndices.map { cards[$0] }
            cards.shuffle()
            for shuffledIdx in cards.indices {
                populateCardView(cardViews[shuffledIdx], with: cards[shuffledIdx])
            }
            for selectedCardIdx in selectedCardIndices {
                cardViews[selectedCardIdx].isSelected = false
            }
            selectedCardIndices = selectedCards.map { selectedCard in
                cards.index(where: { shuffledCard in shuffledCard == selectedCard })!
            }
            for selectedCardIdx in selectedCardIndices {
                cardViews[selectedCardIdx].isSelected = true
            }
        }
    }
    
}

private func populateCardView(_ cardView: CardView, with card: Card) {
    cardView.number = card.number.rawValue
    
    cardView.color = card.color.uiColor
    
    switch card.shading {
    case .outlined: cardView.fillingKind = .none
    case .solid: cardView.fillingKind = .solid
    case .striped: cardView.fillingKind = .striped
    }
    
    switch card.shape {
    case .oval: cardView.shape = .oval
    case .diamond: cardView.shape = .diamond
    case .squiggle: cardView.shape = .squiggle
    }
}
