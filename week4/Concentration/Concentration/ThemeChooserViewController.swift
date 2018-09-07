//
//  ThemeChooserViewController.swift
//  Concentration
//
//  Created by Cong Doan on 9/6/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ThemeChooserViewController: UIViewController {
    
    private static let themes = ["Animals"     : "🐝🐶🐸🦅🐠🦓🐒🐘🦔🕷",
                                 "Sports"      : "🎾⚽️🏀🚴‍♀️🏊‍♂️🏓🏋️‍♂️🤺🏹🏑",
                                 "Fruits"      : "🍏🍎🍐🍊🍋🍌🍉🍇🍓🍈",
                                 "Cars"        : "🚗🚕🚙🚌🚎🏎🚓🚑🚒🚐",
                                 "Electronics" : "⌚️📱💻⌨️🖥🖨🖲🕹📽📷",
                                 "Flags"       : "🏁🚩🏳️‍🌈🇦🇫🇦🇽🇦🇱🇩🇿🇦🇸🇦🇩🇦🇴"]
    
    static var randomTheme: String {
        return Array(themes.values).randomElement!
    }
    
    @IBAction func chooseTheme(_ sender: Any) {
        if let cvc = splitViewDetailConcentrationViewController {
            setThemeForConcentrationViewController(sender, cvc)
        } else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
    
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Choose Theme" else { return }
        if let cvc = segue.destination as? ConcentrationViewController {
            setThemeForConcentrationViewController(sender, cvc)
        }
    }
    
    private func setThemeForConcentrationViewController(_ sender: Any?, _ cvc: ConcentrationViewController) {
        if let themeName = (sender as? UIButton)?.currentTitle {
            let theme = ThemeChooserViewController.themes[themeName] ?? ThemeChooserViewController.randomTheme
            cvc.theme = theme
        }
    }
    
}

extension String {
    var shuffledSingleCharacterStrings: [String] {
        var arrayOfSingleCharacterStrings = self.map { String($0) }
        arrayOfSingleCharacterStrings.shuffle()
        return arrayOfSingleCharacterStrings
    }
}
