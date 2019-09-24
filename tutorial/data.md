# Add a Serverless Backend to the Notes App

In the [previous section](./auth.md) of this tutorial, we added a simple sign-up / sign-in flow to the sample note-taking app with email validation. This tutorial assumes you have completed the previous tutorials. If you jumped to this step, go back and [start from the beginning](./index.md). In this tutorial, we add a GraphQL API backed by a NoSQL database to our mobile backend, and then configure a basic data access provider to the note-taking app.

You should be able to complete this section of the tutorial in 45-60 minutes.

## Add Data Access API to the Backend

1. In a terminal window, navigate to the root of iOS notes tutorial project folder, and  create a `server` subdirectory.

2. In the `server` directory, create a file called `schema-model.graphql` using your favorite text editor.

3. In the `schema-model.graphql` file, copy the following schema definition:

    ```graphql
    type Note @model @auth(rules:[{allow: owner}]) {
        id: ID!
        title: String!
        content: String!
    }
    ```

4. In the terminal window, enter the following command:

    ```bash
    $ amplify add api
    ```

5. When prompted by the CLI, do the following:

   * Select a service type: **GraphQL**.
   * Choose an authorization type: **Amazon Cognito User Pool**.
   * Do you have an annotated GraphQL schema: **Y**.
   * Provide your schema file path: **./server/schema-model.graphql**.

6. To deploy the new service, enter the following (When asked if you want to generate the API answer "no" as we will do that in the next task):

    ```bash
    $ amplify push
    ```
    
    * Are you sure you want to continue: Y
    * Do you want to generate code for your newly created GraphQL API: n

The AWS CloudFormation template that is generated creates an Amazon DynamoDB table that is protected by Amazon Cognito user pool authentication.  Access is provided by AWS AppSync.  AWS AppSync will tag each record that is inserted into the database with the user ID of the authenticated user.  The authenticated user will only be able to read the records that they own.

In addition to updating the `awsconfiguration.json` file, the Amplify CLI will also generate the `schema.graphql` file under the `./amplify/backend/api/YOURAPI/build` directory. The `schema.graphql` file will be used by the Amplify CLI to run code generation for GraphQL operations.

## Generate an API Stub Class

To integrate the iOS notes app with AWS AppSync, we need to generate strongly typed Swift API code based on the GraphQL notes schema and operations. This Swift API code is a class that helps you create native Swift request and response data objects for persisting notes in the cloud.

To interact with AWS AppSync, the iOS client needs to define GraphQL queries and mutations which are converted to strongly typed Swift objects by the Amplify codegen step below.

1. In Xcode, create a new folder called `GraphQLOperations`:

    *  In the Xcode Project Navigator, right-click on the `MyNotes` folder that is a child of the top-level `MyNotes` project. Choose **New Group...**.
    *  Enter the name `GraphQLOperations`.

2. Under the `GraphQLOperations` folder called `notes-operations.graphql`, create a new file as follows:

    *  In the Xcode Project Navigator, right-click the `GraphQLOperations` folder you created, and choose **New File...**.
    *  For **Filter**, enter **Empty**.
    *  In the **Other** section, choose **Empty**, and then choose **Next**.
    *  For **Save As**, enter `notes-operations.graphql`, and then choose **Create**.

3. In the file you just created, copy the following operations:

    ```graphql
    query GetNote($id:ID!) {
        getNote(id:$id) {
            id
            title
            content
        }
    }

    query ListNotes($limit:Int,$nextToken:String) {
        listNotes(limit:$limit,nextToken:$nextToken) {
            items {
                id
                title
                content
            }
            nextToken
        }
    }

    mutation CreateNote($input:CreateNoteInput!) {
        createNote(input:$input) {
            id
            title
            content
        }
    }

    mutation UpdateNote($input:UpdateNoteInput!) {
        updateNote(input:$input) {
            id
            title
            content
        }
    }

    mutation DeleteNote($id:ID!) {
        deleteNote(input: { id: $id }) {
            id
        }
    }
    ```

4. In a terminal window, navigate to your project directory, and run the following command. This tells Amplify CLI to generate the `NotesAPI.swift` file based on the GraphQL schema and our mutations and query operations `notes-operations.graphql` file.

    ```bash
    $ amplify add codegen
    ```

    * The file name pattern of graphql queries: :userinput:`./MyNotes/GraphQLOperations/notes-operations.graphql`
    * Do you want to generate/update all possible GraphQL operations - queries, mutations and subscriptions: **Y**
    * Enter maximum statement depth: Enter the default
    * The file name for the generated code: :userinput:`NotesAPI.swift`
    * Do you want to generate code for your newly created GraphQL API: **Y**

You should now have a `NotesAPI.swift` file in the root of your project.

> What is in the `NotesAPI.swift` file?
>
> Your mobile app sends GraphQL commands (mutations and queries) to the AWS AppSync service.  These are template commands that are converted to the Swift class `NotesAPI.swift` file that you can use in your application.

## Add API Dependencies

1. Add the following API dependencies in your project's `Podfile`:

    ```
    platform :ios, '9.0'
    target :'MyNotes' do
        use_frameworks!

        # Analytics dependency
        pod 'AWSPinpoint', '~> 2.10.0'

        # Auth dependencies
        pod 'AWSMobileClient', '~> 2.10.0'
        pod 'AWSAuthUI', '~> 2.10.0'
        pod 'AWSUserPoolsSignIn', '~> 2.10.0'
        
        pod 'AWSCore', '~> 2.10.0'
  
        # API dependency
        
        pod 'AWSAppSync', '~> 2.14.0'

        # other pods
    end
    ```

2. In a terminal under your project folder, run the following:

    ```bash
    $  pod install -–repo-update
    ```

## Add NotesAPI.swift to Your Xcode Project

1. Open your project in Xcode as follows:

    ```bash
    $ open MyNotes.xcworkspace
    ```

2. Drag the `NotesAPI.swift` file from your project folder to the Xcode project. In **Options**, clear the **Copy items if needed** check box.  By clearing **Copy items if needed** you ensure that the Amplify CLI can re-generate the `NotesAPI.swift` file when we change the schema.

3. Choose **Finish**.

You have now created the AWS resources you need and connected them to your app.

## Create an AWS AppSync Authentication Context

1. In the Xcode project explorer, right-click the `MyNotes` directory, and then choose **New File...**
2. Choose **Swift File**, and then choose **Next**.
3. Enter the name `MyCognitoUserPoolsAuthProvider.swift`, and then choose **Create**.
4. In the file you just created, copy the following code:

    ```swift
    import AWSUserPoolsSignIn
    import AWSAppSync

    class MyCognitoUserPoolsAuthProvider: AWSCognitoUserPoolsAuthProvider {
        func getLatestAuthToken() -> String {
            var token: String? = nil
            AWSCognitoUserPoolsSignInProvider.sharedInstance()
                .getUserPool().currentUser()?.getSession()        
                .continueOnSuccessWith(block: { (task) -> Any? in
                    token = task.result!.idToken!.tokenString
                    return nil
                })
                .waitUntilFinished()

            if token != nil {
                return token!
            } else {
                return ""
            }
        }
    }
    ```

## Create an AWS AppSync DataService Class

All data access is already routed through a `DataService` protocol, which has a concrete implementation in `MockDataService.swift`.  We will now replace the mock data service with an implementation that reads and writes data to AWS AppSync.

1. In the Xcode project explorer, right-click the `MyNotes` directory, and then choose **New File...**
2. Choose **Swift File**, and then choose **Next**.
3. Enter the name `AWSDataService.swift`, and then choose **Create**.
4. In the file you just created, copy the following code:

    ```swift
    import AWSCore
    import AWSAppSync

    class AWSDataService : DataService {

        // AWS AppSync Client
        var appSyncClient: AWSAppSyncClient?
        let databaseURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("appsync.db")

        // Notes
        var notes = [Note]()

        init() {
            do {
                // Initialize the AWS AppSync configuration
   let cacheConfiguration = try AWSAppSyncCacheConfiguration()
            // AppSync configuration & client initialization
            let appSyncServiceConfig = try AWSAppSyncServiceConfig()
            
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: appSyncServiceConfig,
                                                                  userPoolsAuthProvider: MyCognitoUserPoolsAuthProvider(),
                                                                  cacheConfiguration: cacheConfiguration)
                // Initialize the AWS AppSync client
                appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            } catch {
                print("Error initializing appsync client. \(error)")
            }
        }

        // DynamoDB does not accept blanks, so we use a space instead - this converts back to blanks
        func convertNote(id: String?, title: String?, content: String?) -> Note {
            var note = Note()
            note.id = id
            note.title = (title == " ") ? "" : title
            note.content = (content == " ") ? "" : content
            return note
        }

        func getNote(_ noteId: String, onCompletion: @escaping (Note?, Error?) -> Void) {
            appSyncClient?.fetch(query: GetNoteQuery(id: noteId)) { (result, error) in
                if let result = result {
                    onCompletion(self.convertNote(id: result.data?.getNote?.id, title: result.data?.getNote?.title, content:    result.data?.getNote?.content), nil)
                } else {
                    onCompletion(nil, error)
                }
            }
        }

        func loadNotes(onCompletion: @escaping ([Note]?, Error?) -> Void) {
            var myNotes: [Note]? = nil
            appSyncClient?.fetch(query: ListNotesQuery(), cachePolicy: .fetchIgnoringCacheData) { (result, error) in
                if let result = result {
                    myNotes = [Note]()
                    for item in (result.data?.listNotes?.items)! {
                        let note = self.convertNote(id: item?.id, title: item?.title, content: item?.content)
                        myNotes?.append(note)
                    }
                    onCompletion(myNotes, nil)
                } else {
                    onCompletion(nil, error)
                }
            }
        }

        func updateNote(_ note: Note, onCompletion: @escaping (Note?, Error?) -> Void) {
            // DynamoDB doesn't accept empty values, so check first and add an extra space if empty
            let noteTitle = (note.title ?? "").isEmpty ? " " : note.title
            let noteContent = (note.content ?? "").isEmpty ? " " : note.content

            if (note.id == nil) { // Create
                let createNoteInput = CreateNoteInput(title: noteTitle!, content: noteContent!)
                let createMutation = CreateNoteMutation(input: createNoteInput)
                appSyncClient?.perform(mutation: createMutation, resultHandler: { (result, error) in
                    if let result = result {
                        let item = result.data?.createNote
                        onCompletion(self.convertNote(id: item?.id, title: item?.title, content: item?.content), nil)
                    } else if let error = error {
                        onCompletion(nil, error)
                    }
                })
            } else { // Update
                let updateNoteInput = UpdateNoteInput(id: note.id!, title: noteTitle, content: noteContent)
                let updateMutation = UpdateNoteMutation(input: updateNoteInput)
                appSyncClient?.perform(mutation: updateMutation, resultHandler: { (result, error) in
                    if let result = result {
                        let item = result.data?.updateNote
                        onCompletion(self.convertNote(id: item?.id, title: item?.title, content: item?.content), nil)
                    } else if let error = error {
                        onCompletion(nil, error)
                    }
                })
            }
        }

        func deleteNote(_ noteId: String, onCompletion: @escaping (Error?) -> Void) {
            let deleteMutation = DeleteNoteMutation(id: noteId)
            appSyncClient?.perform(mutation: deleteMutation, resultHandler: { (result, error) in
                if result != nil {
                    onCompletion(nil)
                } else if let error = error {
                    onCompletion(error)
                }
            })
        }
    }
    ```

## Register the AWS Data Service

Register the new data service in the `AppDelegate.swift` file as follows:

```swift
// Initialize the analytics service
// analyticsService = LocalAnalyticsService()
analyticsService = AWSAnalyticsService()

// Initialize the data service
// dataService = MockDataService()
dataService = AWSDataService()
```

## Run the Application

Run the application in an iOS simulator and perform some operations.  Create a couple of notes and delete a note.

**Note**: You must be online in order to run this application.

1. Open the [DynamoDB console](https://console.aws.amazon.com/dynamodb/home/).
2. In the left navigation, choose **Tables**.
3. Choose the table for your project.  It will be based on the API name you set.
4. Choose the **Items** tab.

When you insert, edit, or delete notes in the app, you should be able to see the data on the server reflect your actions almost immediately.

## Next Steps

*  Learn about [AWS AppSync](https://aws.amazon.com/appsync/).
*  Learn about [Amazon DynamoDB](https://aws.amazon.com/dynamodb/).

