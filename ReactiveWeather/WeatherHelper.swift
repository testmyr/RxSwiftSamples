//
//  WeatherHelper.swift
//  ReactiveWeather
//
//  Created by sdk on 8/27/17.
//  Copyright © 2017 Sdk. All rights reserved.
//

import Foundation
import RxAlamofire
import RxSwift
import SwiftyJSON


struct Weather {
    let timeStamp: Double
    let temperature: Int
    let windSpeed: Double
    let humidity: Int
    let icon: String
    
//    static let empty = Weather(
//        cityName: "Unknown",
//        temperature: -1000,
//        humidity: 0,
//        icon: iconNameToChar(icon: "e")
//    )
}

class WeatherHelper {
    private let baseURL = "http://api.openweathermap.org/data/2.5/forecast"
    private let baseIconURL = "http://openweathermap.org/img/w/"
    private let openWeatherDataKey = "0507e43ab6d98102f62cb416cfab6b96"
    
    static var shared = WeatherHelper()
    private init() {}
    
    enum WeatherHelperError: Error {
        case cityNotFound
        case serverFailure
        case invalidJSON
    }
    
    func currentWeather(city: String) -> Observable<([Weather], String?)> {
        return buildRequest(params: [("q", city)]).map() { json in
            guard let forecasts = json["list"].array else {
                throw WeatherHelperError.invalidJSON
            }
            var city: String?            
            let cityJSON = json["city"] as JSON
            city = cityJSON["name"].string
            if let country = cityJSON["country"].string, city != nil {
                city = city! + ", " + country
            }
            return (forecasts
            .flatMap { forecastJSON in
                var iconURL: String?
                if let iconName = forecastJSON["weather"][0]["icon"].string {
                    iconURL = self.baseIconURL + iconName + ".png"
                }
            return Weather(
                timeStamp: forecastJSON["dt"].double ?? NSDate().timeIntervalSince1970,
                temperature: forecastJSON["main"]["temp"].int ?? -1000,
                windSpeed: forecastJSON["wind"]["speed"].double  ?? 0.0,
                humidity: forecastJSON["main"]["humidity"].int  ?? 0,
                icon: iconURL  ?? "e"
            )
            }, city)
        
        }
    }
    
    private func buildRequest(method: String = "GET", params: [(String, String)]) -> Observable<JSON> {
        
        let request: Observable<URLRequest> = Observable.create() { observer in
            let url = URL(string: self.baseURL)!
            var request = URLRequest(url: url)
            let keyQueryItem = URLQueryItem(name: "appid", value: self.openWeatherDataKey)
            let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
            let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            if method == "GET" {
                var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
                queryItems.append(keyQueryItem)
                queryItems.append(unitsQueryItem)
                urlComponents.queryItems = queryItems
            } else {
                urlComponents.queryItems = [keyQueryItem, unitsQueryItem]
                
                let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                request.httpBody = jsonData
            }
            
            request.url = urlComponents.url!
            request.httpMethod = method
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            observer.onNext(request)
            observer.onCompleted()
            
            return Disposables.create()
        }
        
        let session = URLSession.shared
        return request.flatMap() { request in
            return session.rx.response(request: request).map() { response, data in
                if 200 ..< 300 ~= response.statusCode {
                    return JSON(data: data)
                } else if 400 ..< 500 ~= response.statusCode {
                    throw WeatherHelperError.cityNotFound
                } else {
                    throw WeatherHelperError.serverFailure
                }
            }
        }
    }
}
