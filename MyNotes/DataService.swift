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

typealias GetNoteResponse = (Note?, Error?) -> Void

typealias LoadNotesResponse = ([Note]?, Error?) -> Void

typealias UpdateNoteResponse = (Note?, Error?) -> Void

typealias DeleteNoteResponse = (Error?) -> Void

protocol DataService {
    func getNote(_ noteId: String, onCompletion: @escaping GetNoteResponse) -> Void
    func loadNotes(onCompletion: @escaping LoadNotesResponse) -> Void
    func updateNote(_ note: Note, onCompletion: @escaping UpdateNoteResponse) -> Void
    func deleteNote(_ noteId: String, onCompletion: @escaping DeleteNoteResponse) -> Void
}

enum DataServiceError: Error {
    case NoSuchNote
    case NetworkError(errorMessage: String)
}
