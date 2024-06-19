//
//  APIKeyManager.swift
//  HealthLog
//
//  Created by chj on 6/19/24.
//
import Foundation

struct APIKeyManager {
    static let shared = APIKeyManager()
    private var keys: [String: String] = [:]

    private init() {
        if let url = Bundle.main.url(forResource: "apikeys", withExtension: "plist"),
           let data = try? Data(contentsOf: url) {
            keys = (try? PropertyListSerialization.propertyList(from: data, format: nil)) as? [String: String] ?? [:]
        }
    }

    func getKey(for key: String) -> String? {
        return keys[key]
    }
}
