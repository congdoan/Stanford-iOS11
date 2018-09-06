//
//  ThemeChooserViewController.swift
//  Concentration
//
//  Created by Cong Doan on 9/6/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

class ThemeChooserViewController: UIViewController {
    
    private let themes = ["Animals"     : "🐝🐶🐸🦅🐠🦓🐒🐘🦔🕷",
                          "Sports"      : "🎾⚽️🏀🚴‍♀️🏊‍♂️🏓🏋️‍♂️🤺🏹🏑",
                          "Fruits"      : "🍏🍎🍐🍊🍋🍌🍉🍇🍓🍈",
                          "Cars"        : "🚗🚕🚙🚌🚎🏎🚓🚑🚒🚐",
                          "Electronics" : "⌚️📱💻⌨️🖥🖨🖲🕹📽📷",
                          "Flags"       : "🏁🚩🏳️‍🌈🇦🇫🇦🇽🇦🇱🇩🇿🇦🇸🇦🇩🇦🇴"]
    
    private var randomTheme: String {
        return Array(themes.values).randomElement!
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Choose Theme" else { return }
        if let themeName = (sender as? UIButton)?.currentTitle {
            let theme = themes[themeName] ?? randomTheme
            if let cvc = segue.destination as? ConcentrationViewController {
                cvc.theme = theme
            }
        }
    }
    
}
