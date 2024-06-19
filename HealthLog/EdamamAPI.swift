//
//  EdamamAPI.swift
//  HealthLog
//
//  Created by chj on 6/19/24.
//
import Foundation

struct EdamamAPI {
    static let appId = APIKeyManager.shared.getKey(for: "EdamamAppId") ?? ""
    static let appKey = APIKeyManager.shared.getKey(for: "EdamamAppKey") ?? ""
    static let baseUrl = "https://api.edamam.com/api/food-database/v2/parser"

    static func fetchCalories(for food: String, completion: @escaping (Double?, String?) -> Void) {
        let urlString = "\(baseUrl)?ingr=\(food.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&app_id=\(appId)&app_key=\(appKey)"
        guard let url = URL(string: urlString) else {
            print("Edamam API: Invalid URL")
            completion(nil, nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Edamam API Error: \(error)")
                completion(nil, nil)
                return
            }

            guard let data = data else {
                print("Edamam API: No data received")
                completion(nil, nil)
                return
            }

            // Print the raw response data
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Edamam API Raw Response: \(rawResponse)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Edamam API Response JSON: \(json)")
                    if let parsed = json["parsed"] as? [[String: Any]],
                       let food = parsed.first?["food"] as? [String: Any],
                       let nutrients = food["nutrients"] as? [String: Double],
                       let calories = nutrients["ENERC_KCAL"] {
                        let measure = parsed.first?["measure"] as? [String: Any]
                        let quantity = parsed.first?["quantity"] as? Double
                        let unit = measure?["label"] as? String
                        let servingSize = quantity != nil && unit != nil ? "\(quantity!) \(unit!)" : "standard serving"
                        completion(calories, servingSize)
                    } else {
                        print("Edamam API: JSON parsing failed")
                        completion(nil, nil)
                    }
                } else {
                    print("Edamam API: JSON decoding error")
                    completion(nil, nil)
                }
            } catch {
                print("Edamam API: JSON decoding error - \(error)")
                completion(nil, nil)
            }
        }

        task.resume()
    }
}
