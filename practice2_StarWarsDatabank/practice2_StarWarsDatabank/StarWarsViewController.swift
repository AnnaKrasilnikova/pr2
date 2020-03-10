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
    var characterArray = [Character]()
    var lastSearchCharactersArray = [Character]()
    var filteredCharactersArray = [Character]()
    var nextUrl = ""
    var isInfoReceived = false
    var characterInfoToBeSend = Character()
    var searchTimer: Timer?
    var numberOfSection = 1
    final let tableRowHeight: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        getInfoFromUrl(url: urlString)
        while !isInfoReceived {
            sleep(2)
        }
        setUpSearchBar()
    }

    //MARK: function for getting info about characters from API
    func getInfoFromUrl (url: String){
        guard let url = URL(string: url) else { return }
        var downoadTask = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        downoadTask.httpMethod = "GET"
        URLSession.shared.dataTask(with: downoadTask , completionHandler: {(data, response, error ) -> Void in
            guard error == nil else {
                guard let errorMsg = error?.localizedDescription else { return }
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
            } else { self.isInfoReceived = true }
        }).resume()
    }

    //MARK: function for displaying error messages
    func getAlert(error: String){
        let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: function for saving info about last searching results
    func addToSavedSearhResults(){
        if filteredCharactersArray.count > 0 {
            let tmpCharacterArray = lastSearchCharactersArray
            lastSearchCharactersArray = filteredCharactersArray
            for i in 0..<tmpCharacterArray.count {
                if !lastSearchCharactersArray.contains(where:({ character -> Bool in character.name.contains(tmpCharacterArray[i].name)})){
                        lastSearchCharactersArray.append(tmpCharacterArray[i])
                    if lastSearchCharactersArray.count>10 { break }
                }
            }
        }
    }
    
    //MARK: reload tableView
    func reloadData(){
        if lastSearchCharactersArray.count > 0 { numberOfSection = 2 }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    //MARK: function for filter characters array
    @objc func doMyFilter() {
        guard let searchingText = searchTimer?.userInfo as? String else { return}
        if searchingText != "" {
            filteredCharactersArray = characterArray.filter({ character -> Bool in
            character.name.lowercased().contains(searchingText.lowercased())
            })
            if filteredCharactersArray.count == 0 {
                getAlert(error: "No matches found!")
            }
            reloadData()
        }
    }
}


extension StarWarsViewController: UISearchBarDelegate {
    private func setUpSearchBar(){
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        addToSavedSearhResults()
        if let searchTimer = searchTimer {
            searchTimer.invalidate()
        }
        searchTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.doMyFilter), userInfo: searchText, repeats: false)
    }
}

extension StarWarsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSection
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
            case 1: return "Last search results:"
            default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableRowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
            case 0: return filteredCharactersArray.count
            case 1: return lastSearchCharactersArray.count
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell")
        guard let characterCell = cell as? CharacterTableViewCell else { return UITableViewCell() }
        switch(indexPath.section){
            case 0: characterCell.characterLabel.text = filteredCharactersArray[indexPath.row].name
            case 1: characterCell.characterLabel.text = lastSearchCharactersArray[indexPath.row].name
            default: break
        }
        return characterCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section){
            case 0:  characterInfoToBeSend = filteredCharactersArray[indexPath.row]
            case 1:  characterInfoToBeSend = lastSearchCharactersArray[indexPath.row]
            default: break
        }
        performSegue(withIdentifier: "characterInfoSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch(indexPath.section){
                case 0: filteredCharactersArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                case 1: lastSearchCharactersArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                default: break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let characterInfo = segue.destination as? CharacterViewController else { return }
        characterInfo.character = characterInfoToBeSend
    }
}

extension StarWarsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowHeight
    }
}
