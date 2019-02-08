//
//  ViewController.swift
//  Places
//
//  Created by Wojciech Karaś on 30/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit
import RealmSwift

class CategoriesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        loadCategories()
    }

    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "Add new category to store your favourite places.", preferredStyle: .alert)
        
        alert.addTextField {
            textField in
            textField.placeholder = "Category"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let addAction = UIAlertAction(title: "Add", style: .default) {
            action in
            if let text = alert.textFields?.first?.text {
                if !text.isEmpty{
                    let newCategory = Category()
                    newCategory.name = text
                    self.save(category: newCategory)
                }
            }
        }
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlacesSegue" {
            if let placesViewController = segue.destination as? PlacesViewController {
                if let indexPath = sender as? IndexPath {
                    placesViewController.selectedCategory = categories?[indexPath.row]
                }
            }
        }
    }
    
    private func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    private func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
            tableView.reloadData()
        } catch {
            print("Error saving new category. \(error.localizedDescription)")
        }
    }
    
}

//MARK: - TableView Methods
extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PlacesSegue", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            do {
                try realm.write {
                    for place in category.places {
                        realm.delete(place)
                    }
                    realm.delete(category)
                }
                tableView.reloadData()
            } catch {
                print("Error deleting category. \(error.localizedDescription)")
            }
        }
    }
}
