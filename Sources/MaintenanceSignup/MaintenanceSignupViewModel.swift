import Foundation

struct NotificationSignupError: Error, LocalizedError {
    let description: String
    
    var errorDescription: String? {
        description
    }
}

class MaintenanceSignupViewModel {
    func addEmailToContactList(
        _ email: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let session = URLSession.shared
        let completion: (Result<Void, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        var urlComponents = URLComponents(string: "https://pc.serapisnow.com/api/v1/subscribers")
        
        urlComponents?.queryItems = [
            .init(name: "api_token", value: ProfitSendConfiguration.shared.apiToken),
            .init(name: "EMAIL", value: email),
            .init(name: "list_uid", value: ProfitSendConfiguration.shared.listUID)
        ]
        
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(.success(()))
            } else {
                do {
                    if let data = data,
                       let decoded = try? JSONDecoder().decode(ErrorResponse.self, from: data),
                       let errorMessage = decoded.emailErrors.first {
                        throw NotificationSignupError(description: errorMessage)
                    } else {
                        throw NotificationSignupError(description: "Failed to register the email address")
                    }
                } catch let error {
                    completion(.failure(error))
                }
                
            }
        }
        
        task.resume()
    }
}

struct ErrorResponse: Codable {
    let emailErrors: [String]
    
    enum CodingKeys: String, CodingKey {
        case emailErrors = "EMAIL"
    }
}
