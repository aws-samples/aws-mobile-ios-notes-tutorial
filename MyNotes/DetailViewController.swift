//
//  DetailViewController.swift
//  MyNotes
//
//  Created by Hall, Adrian on 8/24/18.
//  Copyright © 2018 Hall, Adrian. All rights reserved.
//
import Foundation
import UIKit

class DetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    var dataService: DataService? = nil
    var detailItem: Note? {
        didSet {
            if (dataService != nil) {
                configureView()
            }
        }
    }
    
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var idTextField: UILabel!
    
    // Assigned to all text fields for keyboard collapse
    @IBAction func resignKeyboardTextField(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        dataService = (UIApplication.shared.delegate as! AppDelegate).dataService
        configureView()
        
        // Set up delegate for monitoring the text entered into the title and content fields
        titleTextField.delegate = self
        contentTextField.delegate = self
    }
    
    // When text is changed, save the change
    func textFieldDidChange(_ textField: UITextField) {
        saveToDataService()
    }
    
    // When text is changed, save the change
    func textViewDidChange(_ textView: UITextView) {
        saveToDataService()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Update the user interface when the detail item changes
    func configureView() {
        print("configureView")
        if let note = detailItem {
            if let id = note.id {
                idTextField.text = id
            }
            if let title = note.title {
                titleTextField.text = title
                titleTextField.isEnabled = true
            }
            if let content = note.content {
                contentTextField.text = content
                contentTextField.isEditable = true
            }
        } else {
            idTextField.text = "Invalid Note Specification"
            titleTextField.text = "Something went wrong"
            contentTextField.text = "The detailItem property in DetailViewController is nil - this should never happen"
            titleTextField.isEnabled = false
            contentTextField.isEditable = false
        }
    }
    
    // Ideally, we would use this to submit to a queue of requests that are then processed asynchronously
    // In this simple case, we just call the data service directly.  You can use RxSwift for queuing of
    // requests to save.
    func saveToDataService() {
        let title = titleTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        let content = contentTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        let note = Note(id: detailItem?.id ?? nil, title: title, content: content)
        
        if (note.id == nil && note.title == "") {
            print("Skipping save of empty item")
            return
        }
        
        dataService?.updateNote(note) { (note, error) in
            if (error != nil) {
                showErrorAlert(error?.localizedDescription ?? "Unknown Error", title: "updateNote Error")
            } else if (note != nil) {
                if (detailItem != nil) {
                    detailItem!.id = note!.id
                } else {
                    showErrorAlert("detailItem is nil???", title: "Bad Error")
                }
            } else {
                showErrorAlert("note is nil", title: "updateNote Error")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveToDataService()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.detailItem = nil
    }

    // Dismiss the keyboard when the user taps on the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Dismiss keyboard when user taps the return key on the keyboard after editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Display the given error message as an alert pop-up
    func showErrorAlert(_ errorMessage: String, title: String?) {
        let alertController = UIAlertController(title: title ?? "Error", message: errorMessage, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}

