//
//  PlaceViewController.swift
//  Places
//
//  Created by Wojciech Karaś on 30/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit
import RealmSwift

class PlacesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let realm = try! Realm()
    private var places: Results<Place>?
    private var query: String?
    
    var selectedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedCategory?.name
        loadPlaces()
    }
    
    private func loadPlaces() {
        places = selectedCategory?.places.sorted(byKeyPath: "name", ascending: true)
        if let query = query {
            places = places?.filter(NSPredicate(format: "name CONTAINS[cd] %@", query)).sorted(byKeyPath: "name", ascending: true)
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddPlaceSegue" {
            if let addPlaceViewController = segue.destination as? AddEditPlaceViewController {
                addPlaceViewController.delegate = self
            }
        } else if segue.identifier == "EditPlaceSegue" {
            if let editPlaceViewController = segue.destination as? AddEditPlaceViewController {
                if let indexPath = sender as? IndexPath {
                    editPlaceViewController.selectedPlace = places?[indexPath.row]
                    editPlaceViewController.delegate = self
                }
            }
        }
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddPlaceSegue", sender: nil)
    }
}

//MARK: - TableView Methods
extension PlacesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        cell.textLabel?.text = places?[indexPath.row].name
        cell.detailTextLabel?.text = places?[indexPath.row].placeDescription
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "EditPlaceSegue", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let place = places?[indexPath.row]{
            do {
                try realm.write {
                    realm.delete(place)
                }
                tableView.reloadData()
            } catch {
                print("Error deleting place. \(error.localizedDescription)")
            }
        }
    }
}

extension PlacesViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        query = nil
        searchBar.resignFirstResponder()
        loadPlaces()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            query = !text.isEmpty ? text : nil
        }
        searchBar.resignFirstResponder()
        loadPlaces()
    }
}

//MARK: - AddEditPlaceViewController Methods
extension PlacesViewController: AddEditPlaceViewControllerDelegate {
    func addEditPlaceViewController(_ controller: AddEditPlaceViewController, didFinishAdding place: Place) {
        if let selectedCategory = selectedCategory {
            do {
                try realm.write {
                    selectedCategory.places.append(place)
                }
                tableView.reloadData()
                navigationController?.popViewController(animated: true)
            } catch {
                print("Error saving new place. \(error.localizedDescription)")
            }
        }
    }
    
    func addEditPlaceViewController(_ controller: AddEditPlaceViewController, didFinishEditing place: Place, with newPlace: Place) {
        do {
            try realm.write {
                place.name = newPlace.name
                place.placeDescription = newPlace.placeDescription
                place.latitude = newPlace.latitude
                place.longitude = newPlace.longitude
            }
            tableView.reloadData()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error editing place. \(error.localizedDescription)")
        }
    }
}
