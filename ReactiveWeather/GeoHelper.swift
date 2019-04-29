//
//  GeoHelper.swift
//  ReactiveWeather
//
//  Created by sdk on 8/27/17.
//  Copyright © 2017 Sdk. All rights reserved.
//

import Foundation
import RxAlamofire
import RxSwift

//TODO
enum GeoHelperError: Error {
    case invalidURL(String)
    case invalidParameter(String, Any)
    case invalidJSON(String)
}

class GeoHelper {
    private let baseURL = "http://gd.geobytes.com/AutoCompleteCity"
    
    static var shared = GeoHelper()
    private init() {}
    
    func searchCities(text: String) -> Observable<[String]> {
        return json(.get, baseURL, parameters: ["q" : text])
            //.debug()
            .map {
                guard let cities = $0 as? [String] else {
                    throw GeoHelperError.invalidJSON(self.baseURL)
                }
                return cities
        }
    }
}
