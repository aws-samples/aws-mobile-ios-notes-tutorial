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

/*
 * Implementation of a mock data service that stores all the data in-memory
 */
class MockDataService : DataService {
    
    static var notes = [Note]()
    
    // Initialize 20 notes for mocking purposes.
    init() {
        for index in 1...20 {
            let note = Note(id: UUID().uuidString, title: "Note \(index)", content: "This is note \(index)")
            MockDataService.notes.append(note)
        }
    }
    
    // Get a specific note by noteId
    func getNote(_ noteId: String, onCompletion: @escaping (Note?, Error?) -> Void) {
        for (_, element) in MockDataService.notes.enumerated() {
            if (element.id == noteId) {
                onCompletion(element, nil)
                return
            }
        }
        onCompletion(nil, DataServiceError.NoSuchNote)
    }
    
    // Load all the notes
    func loadNotes(onCompletion: @escaping ([Note]?, Error?) -> Void) {
        onCompletion(MockDataService.notes, nil)
    }
    
    // Update a note (either create or update)
    func updateNote(_ note: Note, onCompletion: @escaping (Note?, Error?) -> Void) {
        if (note.id == nil) {
            let newNote = Note(id: UUID().uuidString, title: note.title, content: note.content)
            MockDataService.notes.append(newNote)
            onCompletion(newNote, nil)
        } else {
            for (index, element) in MockDataService.notes.enumerated() {
                if (element.id == note.id) {
                    MockDataService.notes[index] = note
                    onCompletion(note, nil)
                    return
                }
            }
            onCompletion(nil, DataServiceError.NoSuchNote)
        }
    }
    
    // Delete a note from the service
    func deleteNote(_ noteId: String, onCompletion: @escaping (Error?) -> Void) {
        var index = -1
        for (listIndex, element) in MockDataService.notes.enumerated() {
            if (element.id == noteId) {
                index = listIndex
            }
        }
        if (index == -1) {
            onCompletion(DataServiceError.NoSuchNote)
        } else {
            MockDataService.notes.remove(at: index)
            onCompletion(nil)
        }
    }
}
