//
//  MockDataService.swift
//  MyNotes
//
//  Created by Hall, Adrian on 8/24/18.
//  Copyright © 2018 Hall, Adrian. All rights reserved.
//

import Foundation

/*
 * Implementation of a mock data service that stores all the data in-memory
 */
class MockDataService : DataService {
    var notes = [Note]()
    
    // Initialize 30 notes for mocking purposes.
    init() {
        for index in 1...30 {
            let note = Note(id: UUID().uuidString, title: "Note \(index)", content: "This is note \(index)")
            notes.append(note)
        }
    }
    
    // Get a specific note by noteId
    func getNote(_ noteId: String, onCompletion: (Note?, Error?) -> Void) {
        for (_, element) in notes.enumerated() {
            if (element.id == noteId) {
                onCompletion(element, nil)
                return
            }
        }
        onCompletion(nil, DataServiceError.NoSuchNote)
    }
    
    // Load all the notes
    func loadNotes(onCompletion: ([Note]?, Error?) -> Void) {
        onCompletion(notes, nil)
    }
    
    // Update a note (either create or update)
    func updateNote(_ note: Note, onCompletion: (Note?, Error?) -> Void) {
        if (note.id == nil) {
            let newNote = Note(id: UUID().uuidString, title: note.title, content: note.content)
            notes.append(newNote)
            onCompletion(note, nil)
        } else {
            for (index, element) in notes.enumerated() {
                if (element.id == note.id) {
                    notes[index] = note
                    onCompletion(note, nil)
                    return
                }
            }
            onCompletion(nil, DataServiceError.NoSuchNote)
        }
    }
    
    // Delete a note from the service
    func deleteNote(_ noteId: String, onCompletion: (Error?) -> Void) {
        var index = -1
        for (listIndex, element) in notes.enumerated() {
            if (element.id == noteId) {
                index = listIndex
            }
        }
        if (index == -1) {
            onCompletion(DataServiceError.NoSuchNote)
        } else {
            notes.remove(at: index)
            onCompletion(nil)
        }
    }
}
