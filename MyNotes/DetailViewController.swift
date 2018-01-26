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
import UIKit
import Foundation
import CoreData
import CoreGraphics

/* DetailViewController is a single note detail screen
*  You can view note details and/or edit the note title or content
*  The note details auto-save; no need to manually save note details
*/
class DetailViewController: UIViewController {
    
    var noteContentProvider: NotesContentProvider? = nil
    
    @IBOutlet weak var noteContent: UITextView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var noteTitle: UITextField!
    
    // Assign all the textfields to this action for keyboard collapse
    @IBAction func resignKeyboardTextField(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    static var noteId: String?
    
    // Timer! Property for auto-saving of a note
    var autoSaveTimer: Timer!
    
    var notes: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize Notes contentProvider
        noteContentProvider = NotesContentProvider()
        
        // Start the auto-save timer to call autoSave() every 2 seconds
        autoSaveTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(autoSave), userInfo: nil, repeats: true)
        
        // Prepare textfields with rounded corners
        noteTitle.layer.borderWidth = 0.5
        noteTitle.layer.cornerRadius = 5
        noteContent.layer.borderWidth = 0.5
        noteContent.layer.cornerRadius = 5
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        noteTitle.leftViewMode = .always
        noteTitle.leftView = paddingView
       
        // Do any additional setup after loading the view
        configureView()
    }
    
    var myNote: Note? {
        
        didSet {
            // Set the note Id if passed in from the MasterView
            DetailViewController.noteId = myNote?.value(forKey: "noteId") as? String
            
            // Update the view with passed in note title and content.
            configureView()
        }
    }
    
    // Display the note title and content
    func configureView() {
        
        if let title = myNote?.value(forKey: "title") as? String {
            noteTitle?.text = title
        }
        
        if let content = myNote?.value(forKey: "content") as? String {
            noteContent?.text = content
        }
    }
    
    func autoSave() {
        
        // If this is a NEW note, set the Note Id
        if (DetailViewController.noteId == nil) // Insert
        {
            let id = noteContentProvider?.insert(noteTitle: "", noteContent: "")
            DetailViewController.noteId = id
        }
        else // Update
        {
            let noteId = DetailViewController.noteId
            let noteTitle = self.noteTitle.text
            let noteContent = self.noteContent.text
            noteContentProvider?.update(noteId: noteId!, noteTitle: noteTitle!, noteContent: noteContent!)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Stop the auto-save timer
        if autoSaveTimer != nil {
            autoSaveTimer.invalidate()
        }
        
        // Update the note one last time unless a note was never created
        let noteId = DetailViewController.noteId
        if  noteId != nil {
            noteContentProvider?.update(noteId: (noteId)!, noteTitle: self.noteTitle.text!, noteContent: self.noteContent.text!) //Core Data
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DetailViewController.noteId = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Dismiss keyboard when user taps on view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Dismiss keyboard when user taps the return key on the keyboard after editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

