/*
 * Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file
 * except in compliance with the License. A copy of the License is located at
 *
 *    http://aws.amazon.com/apache2.0/
 *
 * or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for
 * the specific language governing permissions and limitations under the License.
 */

import Foundation
import UIKit

class DetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var idLabel: UILabel!
    
    let PLACEHOLDER_TEXT = "Enter note content here..."
    let PlaceholderColor = UIColor.lightGray
    let TextColor = UIColor.black
    
    var analyticsService: AnalyticsService? = nil
    var dataService: DataService? = nil
    var noteId: String? = nil
    var inProgress: Bool = false
    
    var detailItem: Note? {
        didSet {
            noteId = detailItem?.id
            if (dataService != nil) {
                configureView()
            }
        }
    }
    
    func setNoteDetail(_ note: Note?) {
        detailItem = note
    }
    
    // Assigned to all text fields for keyboard collapse
    @IBAction func resignKeyboardTextField(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        analyticsService = (UIApplication.shared.delegate as! AppDelegate).analyticsService
        dataService = (UIApplication.shared.delegate as! AppDelegate).dataService
        
        // Set up delegate for monitoring the text entered into the title and content fields
        titleTextField.delegate = self
        titleTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        contentTextView.delegate = self
        contentTextView.text = PLACEHOLDER_TEXT
        contentTextView.textColor = PlaceholderColor

        // Configure the view if data is available
        configureView()
    }
    
    // When text is changed, save the change
    @objc func textFieldDidChange(_ textField: UITextField) {
        saveToDataService()
    }
    
    // When text is changed, save the change
    func textViewDidChange(_ textView: UITextView) {
        saveToDataService()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == PlaceholderColor {
            textView.text = nil
            textView.textColor = TextColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = PLACEHOLDER_TEXT
            textView.textColor = PlaceholderColor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Update the user interface when the detail item changes
    func configureView() {
        if let note = detailItem {
            if let id = note.id {
                idLabel.text = id
            }
            if let title = note.title {
                titleTextField.text = title
            }
            if let content = note.content {
                if (!content.isEmpty) {
                    contentTextView.text = content
                    contentTextView.textColor = UIColor.black
                }
            }
            titleTextField.isHidden = false
            contentTextView.isHidden = false
        } else {
            idLabel.text = "Click on a note to view it"
            titleTextField.isHidden = true
            contentTextView.isHidden = true
        }
    }
    
    // Ideally, we would use this to submit to a queue of requests that are then processed asynchronously
    // In this simple case, we just call the data service directly.  You can use RxSwift for queuing of
    // requests to save.
    func saveToDataService() {
        let title = titleTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        let content = (contentTextView.textColor == PlaceholderColor) ? "" : contentTextView.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        let note = Note(id: noteId ?? nil, title: title, content: content)
        
        // Skip saving of empty items
        if (note.id == nil && note.title == "") {
            return
        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            self.debouncedSave(note)
        }
    }
        
    func debouncedSave(_ note: Note) {
        if (!inProgress) {
            inProgress = true
            analyticsService?.recordEvent("SaveNote", parameters: ["id":note.id ?? "new"], metrics: nil)
            dataService?.updateNote(note) { (note, error) in
                if (error != nil) {
                    self.analyticsService?.recordEvent("Error", parameters: ["op":"updateNote"], metrics: nil)
                    self.showErrorAlert(error?.localizedDescription ?? "Unknown Error", title: "updateNote Error")
                } else if (note != nil) {
                    if (self.detailItem != nil) {
                        self.noteId = note!.id
                        self.idLabel.text = self.noteId
                    } else {
                        self.detailItem = note
                    }
                    NotificationCenter.default.post(name: Notification.Name("NoteChangedIdentifier"), object: note)
                } else {
                    self.analyticsService?.recordEvent("Error", parameters: ["op":"updateNote"], metrics: nil)
                    self.showErrorAlert("note is nil", title: "updateNote Error")
                }
                self.inProgress = false
                let title = self.titleTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
                let content = (self.contentTextView.textColor == self.PlaceholderColor) ? "" : self.contentTextView.text?.trimmingCharacters(in: CharacterSet.whitespaces)
                if (title != note?.title || content != note?.content) {
                    self.saveToDataService()
                }
            }
        }
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

