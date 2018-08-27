//
//  MasterViewController.swift
//  MyNotes
//
//  Created by Hall, Adrian on 8/24/18.
//  Copyright © 2018 Hall, Adrian. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    var dataService : DataService? = nil
    var detailViewController: DetailViewController? = nil
    var notes = [Note]() {
        didSet {
            // When we do something to the data, reload it.
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get a reference to the data service from the AppDelegate
        dataService = (UIApplication.shared.delegate as! AppDelegate).dataService
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    func loadNotesFromDataService() {
        dataService?.loadNotes() { (notesFromNetwork, error) in
            if error == nil {
                if notesFromNetwork == nil {
                    self.notes = [Note]() // Clear the notes out
                } else {
                    self.notes = notesFromNetwork!
                }
            } else {
                showErrorAlert(error?.localizedDescription ?? "Unknown data service error", title: "LoadNotes Error")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        // Load the notes from the data service whenever we refresh
        loadNotesFromDataService()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func insertNewObject(_ sender: Any) {
        self.performSegue(withIdentifier: "showDetail", sender: (Any).self)
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var object: Note? = nil
        
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                object = notes[indexPath.row]
            } else {
                object = Note()
            }
                
            let controller = segue.destination as! DetailViewController
            controller.detailItem = object
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = notes[indexPath.row].title ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: (Any).self)
    }

    // Enable swipe-to-delete
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Handle a swipe into swipe-to-delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let noteId = notes[indexPath.row].id else {
                showErrorAlert("Invalid note ID presented for swipe-to-delete", title: "Bad Error")
                return
            }
            
            // Delete the note from the backend
            dataService?.deleteNote(noteId) { (error) in
                if error == nil {
                    notes.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                } else {
                    showErrorAlert(error?.localizedDescription ?? "Unknown Error", title: "Row not removed")
                }
            }
        }
    }
    
    // Display the given error message as an alert pop-up
    func showErrorAlert(_ errorMessage: String, title: String?) {
        let alertController = UIAlertController(title: title ?? "Error", message: errorMessage, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}

