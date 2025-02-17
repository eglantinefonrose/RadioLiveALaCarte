//
//  GroovyMorningFM_MobileAppApp.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import SwiftUI

@main
struct GroovyMorningFM_MobileAppApp: App {
    var body: some Scene {
        WindowGroup {
            GroovyRootView(apiService: APIService.shared)
        }
    }
}
