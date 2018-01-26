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
import CoreData
import UIKit

// The content provider for the internal Note database (Core Data)

public class NotesContentProvider  {
    
    var myNotes: [NSManagedObject] = []
    let emptyTitle: String? = " "
    let emptyContent: String? = " "
    
    func getContext() -> NSManagedObjectContext {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return managedContext
    }
    
    /**
     * Insert a new record into the database using NSManagedObjectContext
     *
     * @param noteTitle the note title to be inserted
     * @param noteContent the note content to be inserted
     * @return noteId the unique Note Id
     */
    func insert(noteTitle: String, noteContent: String) -> String {
        
        // Get NSManagedObjectContext
        let managedContext = getContext()
        
        let entity = NSEntityDescription.entity(forEntityName: "Note",
                                                in: managedContext)!
        
        let myNote = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // Set the Note Id
        let newNoteId = NSUUID().uuidString
        myNote.setValue(NSDate(), forKeyPath: "creationDate")
        print("New note being created: \(newNoteId)")
        
        myNote.setValue(newNoteId, forKeyPath: "noteId")
        myNote.setValue(noteTitle, forKeyPath: "title")
        myNote.setValue(noteContent, forKeyPath: "content")
        
        do {
            try managedContext.save()
            myNotes.append(myNote)
        } catch let error as NSError {
            print("Could not save note. \(error), \(error.userInfo)")
        }
        print("New Note Saved : \(newNoteId)")
        return newNoteId
    }
    
    /**
     * Update an existing Note using NSManagedObjectContext
     * @param noteId the unique identifier for this note
     * @param noteTitle the note title to be updated
     * @param noteContent the note content to be updated
     */
    func update(noteId: String, noteTitle: String, noteContent: String)  {
        
        // Get NSManagedObjectContext
        let managedContext = getContext()
        
        let entity = NSEntityDescription.entity(forEntityName: "Note",
                                                in: managedContext)!
        
        let myNote = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        myNote.setValue(noteId, forKeyPath: "noteId")
        myNote.setValue(noteTitle, forKeyPath: "title")
        myNote.setValue(noteContent, forKeyPath: "content")
        myNote.setValue(NSDate(), forKeyPath: "updatedDate")
        
        do {
            try managedContext.save()
            myNotes.append(myNote)
        } catch let error as NSError {
            print("Could not save note. \(error), \(error.userInfo)")
        }
        print("Updated note with NoteId: \(noteId)")
    }
    
    /**
     * Delete note using NSManagedObjectContext and NSManagedObject
     * @param managedObjectContext the managed context for the note to be deleted
     * @param managedObj the core data managed object for note to be deleted
     * @param noteId the noteId to be delete
     */
    public func delete(managedObjectContext: NSManagedObjectContext, managedObj: NSManagedObject, noteId: String!)  {
        let context = managedObjectContext
        context.delete(managedObj)
        
        do {
            try context.save()
            print("Deleted local NoteId: \(noteId)")
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved local delete error \(nserror), \(nserror.userInfo)")
        }
    }
}
