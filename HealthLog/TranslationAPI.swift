//
//  TranslationAPI.swift
//  HealthLog
//
//  Created by chj on 6/19/24.
//
import Foundation

struct TranslationAPI {
    static let apiKey = APIKeyManager.shared.getKey(for: "GoogleTranslationAPIKey") ?? ""
    static let baseUrl = "https://translation.googleapis.com/language/translate/v2"

    static func translateToEnglish(text: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(baseUrl)?key=\(apiKey)") else {
            print("Translation API: Invalid URL")
            completion(nil) // 번역 실패 시 nil 반환
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "q": text,
            "target": "en"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Translation API Error: \(error)")
                completion(nil) // 번역 실패 시 nil 반환
                return
            }

            guard let data = data else {
                print("Translation API: No data received")
                completion(nil) // 번역 실패 시 nil 반환
                return
            }

            // Print the raw response data
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Translation API Raw Response: \(rawResponse)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let translations = data["translations"] as? [[String: Any]],
                   let translation = translations.first?["translatedText"] as? String {
                    print("Translated Text: \(translation)")
                    completion(translation)
                } else {
                    print("Translation API: JSON parsing failed")
                    completion(nil) // 번역 실패 시 nil 반환
                }
            } catch {
                print("Translation API: JSON decoding error - \(error)")
                completion(nil) // 번역 실패 시 nil 반환
            }
        }

        task.resume()
    }
}
