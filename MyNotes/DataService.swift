//
//  DataService.swift
//  MyNotes
//
//  Created by Hall, Adrian on 8/24/18.
//  Copyright © 2018 Hall, Adrian. All rights reserved.
//

typealias GetNoteResponse = (Note?, Error?) -> Void

typealias LoadNotesResponse = ([Note]?, Error?) -> Void

typealias UpdateNoteResponse = (Note?, Error?) -> Void

typealias DeleteNoteResponse = (Error?) -> Void

protocol DataService {
    func getNote(_ noteId: String, onCompletion: GetNoteResponse) -> Void
    func loadNotes(onCompletion: LoadNotesResponse) -> Void
    func updateNote(_ note: Note, onCompletion: UpdateNoteResponse) -> Void
    func deleteNote(_ noteId: String, onCompletion: DeleteNoteResponse) -> Void
}

enum DataServiceError: Error {
    case NoSuchNote
    case NetworkError(errorMessage: String)
}
