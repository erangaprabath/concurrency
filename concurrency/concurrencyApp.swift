//
//  concurrencyApp.swift
//  concurrency
//
//  Created by Eranga prabath on 2023-11-22.
//

import SwiftUI

@main
struct concurrencyApp: App {

    var body: some Scene {
        WindowGroup {
            DownloadImageWithAsync()
        }
    }
}
