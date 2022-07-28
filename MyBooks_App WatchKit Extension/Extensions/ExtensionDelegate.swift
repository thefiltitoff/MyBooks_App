//
//  ExtensionDelegate.swift
//  MyBooks_App WatchKit Extension
//
//  Created by Felix Titov on 7/2/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    func applicationDidFinishLaunching() {
        setupWatchConnectivity()
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("Activated")
        }
    }
    
}

extension ExtensionDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC session activation failde with error: " + "\(error.localizedDescription)")
            return
        }
        print("WC session activated with state: " + "\(activationState.rawValue)")
    }
    
    // Work with simulator
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("I'm there")
        print(message)
        var pickedBooks = [BookItem]()
        if let books = message["books"] as? [[String: Any]] {
            books.forEach { (book) in
                if let book = BookItem(data: book) {
                    pickedBooks.append(book)
                }
            }
        }
        UserSettings.userBooks = pickedBooks
        
        DispatchQueue.main.async {
            WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "PickedBooks", context: [:] as AnyObject)])
        }
    }
    
    // Work with real device
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("I'm there")
        print(applicationContext)
        var pickedBooks = [BookItem]()
        if let books = applicationContext["books"] as? [[String: Any]] {
            books.forEach { (book) in
                if let book = BookItem(data: book) {
                    pickedBooks.append(book)
                }
            }
        }
        UserSettings.userBooks = pickedBooks

        DispatchQueue.main.async {
            WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "PickedBooks", context: [:] as AnyObject)])
        }
    }
    
}
