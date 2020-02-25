//
//  StarWarsViewController.swift
//  practice2_StarWarsDatabank
//
//  Created by Anna Krasilnikova on 14.02.2020.
//  Copyright © 2020 Anna Krasilnikova. All rights reserved.
//

import UIKit

struct Characters: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Character]
}

struct Character: Codable {
    var name = ""
    var height = ""
    var mass = ""
    var hair_color = ""
    var skin_color = ""
    var eye_color = ""
    var birth_year = ""
    var gender = ""
    var homeworld = ""
    var films = [""]
    var species = [""]
    var vehicles = [""]
    var starships = [""]
    var created = ""
    var edited = ""
    var url = ""
}

class StarWarsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
   
    
    final let urlString = "https://swapi.co/api/people"
    //var characterNamesArray = [String]()
    //var currentCharacterNamesArray = [String]()
    var characterArray = [Character]()
    var currentCharacterArray = [Character]()
    var nextUrl = ""
    var characterInfoToBeSend = Character()

    override func viewDidLoad() {
        super.viewDidLoad()
        getCharactersInfo()
        setUpSearchBar()
    }

    func getInfoFromUrl (url: String){
        guard let url = URL(string: url) else { return }
        var downoadTask = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        downoadTask.httpMethod = "GET"
        URLSession.shared.dataTask(with: downoadTask , completionHandler: {(data, response, error ) -> Void in
            if error != nil {
                guard let errorMsg = error?.localizedDescription else {return}
                self.getAlert(error: errorMsg)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.getAlert(error: response?.textEncodingName ?? "Server error!")
                return
            }
            guard let data = data else { return }
            let character = try! JSONDecoder().decode(Characters.self, from: data)
            for i in 0..<character.results.count{
                self.characterArray.append(character.results[i])
            }
            self.nextUrl = character.next ?? ""
            if self.nextUrl != "" {
                self.getInfoFromUrl(url: self.nextUrl)
            }
        }).resume()
        reloadData()
    }
    
    func getAlert(error: String){
        let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    func reloadData(){
        currentCharacterArray = characterArray
        tableView.reloadData()
    }
    
    func getCharactersInfo (){
        getInfoFromUrl(url: urlString)
        reloadData()
    }
    
}

extension StarWarsViewController: UISearchBarDelegate {
    private func setUpSearchBar(){
        searchBar.delegate = self
        reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            reloadData()
            return
        }
        currentCharacterArray = characterArray.filter({ character -> Bool in
            character.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

extension StarWarsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCharacterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell")
        guard let characterCell = cell as? CharacterTableViewCell else { return UITableViewCell() }
        characterCell.characterLabel.text = currentCharacterArray[indexPath.row].name
        return characterCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        print(currentCharacterArray[indexPath.row])
        characterInfoToBeSend = currentCharacterArray[indexPath.row]
        print(characterInfoToBeSend)
        self.performSegue(withIdentifier: "characterInfoSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let characterInfo = segue.destination as? CharacterViewController else {return}
        characterInfo.character = characterInfoToBeSend
    }
}

extension StarWarsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
