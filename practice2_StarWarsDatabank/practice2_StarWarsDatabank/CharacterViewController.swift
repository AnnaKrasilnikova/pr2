//
//  CharacterViewController.swift
//  practice2_StarWarsDatabank
//
//  Created by Anna Krasilnikova on 24.02.2020.
//  Copyright © 2020 Anna Krasilnikova. All rights reserved.
//

import UIKit

class CharacterViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var massLabel: UILabel!
    @IBOutlet weak var skinColorLabel: UILabel!
    @IBOutlet weak var hairColorLabel: UILabel!
    @IBOutlet weak var eyeColorLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    var character = Character()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCharacterInfo()
    }
    
    private func setCharacterInfo(){
        nameLabel.text = character.name
        heightLabel.text = character.height
        massLabel.text = character.mass
        skinColorLabel.text = character.skin_color
        hairColorLabel.text = character.hair_color
        eyeColorLabel.text = character.eye_color
        birthDateLabel.text = character.birth_year
        genderLabel.text = character.gender
    }

}
