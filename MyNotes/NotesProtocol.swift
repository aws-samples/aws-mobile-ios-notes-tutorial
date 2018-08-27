//
//  NotesProtocol.swift
//  MyNotes
//
//  Created by Hall, Adrian on 8/24/18.
//  Copyright © 2018 Hall, Adrian. All rights reserved.
//

struct Note {
    var id: String? = nil
    var title: String? = nil
    var content: String? = nil
}

protocol NotesProtocol {
    func getNote(noteId: String)
    func loadNotes()
    func createNote()
    func updateNote(note: Note)
    func deleteNote(noteId: String)
}
