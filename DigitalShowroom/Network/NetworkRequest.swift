//
//  NetworkRequest.swift
//  DigitalShowroom
//
//  Created by Vikas Kharb on 30/01/2022.
//

import Foundation

enum Requests {
    case cars
    case doorAndWindowsLockStatus(String)
    case downloadImage(String)
    
    var path: String {
        switch self {
        case .cars:
            return "cars"
            
        case .doorAndWindowsLockStatus(let vinNumber):
            return "cars/doorstatus/\(vinNumber)"
            
        case .downloadImage(let imageURL):
            return imageURL
            
        }
    }
    
    var requestMethod: String {
        switch self {
        case .cars, .downloadImage, .doorAndWindowsLockStatus:
            return "GET"
        }
    }
}

struct NetworkRequest <T: Decodable> {
    let baseURL: String = "https://digitalshowroomnodejs.herokuapp.com/"
    var request: Requests
    
    init(request: Requests) {
        self.request = request
    }
    
    // MARK: - Public methods
    func execute(completion: @escaping ((Result<T, Error>) -> Void)) {
        guard let url = URL(string: baseURL + request.path) else {
            completion(.failure(NetworkRequestError.genericError("Invalid URL")))
            return
        }
        
        performNetworkRequest(with: createURLRequest(url: url)) { result in
            switch result {
                
            case .success(let responseData):
                if let decodedData = decodeData(input: responseData, withType: T.self) {
                    completion(.success(decodedData))
                } else {
                    completion(.failure(NetworkRequestError.jsonParseError))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func downloadImage(completion: @escaping ((Result<Data, Error>) -> Void)) {
        guard let url = URL(string: baseURL + request.path) else {
            completion(.failure(NetworkRequestError.genericError("Invalid URL")))
            return
        }
        
        performNetworkRequest(with: createURLRequest(url: url), completion: completion)
    }
    
    func createURLRequest(url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.requestMethod
        return urlRequest
    }
}

// MARK: Private methods
extension NetworkRequest {
    private func performNetworkRequest(with urlRequest: URLRequest, completion: @escaping ((Result<Data, Error>) -> Void)) {
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            guard let responseData = data else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NetworkRequestError.genericError("Network Error")))
                }
                
                return
            }
            completion(.success(responseData))
        }
        task.resume()
    }
    
    private func decodeData<T: Decodable>(input: Data, withType: T.Type) -> T? {
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(T.self, from: input)
            return decodedData
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
}
