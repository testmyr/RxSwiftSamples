//
//  ForecastViewController.swift
//  ReactiveWeather
//
//  Created by sdk on 8/28/17.
//  Copyright © 2017 Sdk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ForecastViewController: UIViewController {
    static let maxAttempts = 4
    
    @IBOutlet weak var tblForecasts: UITableView!
    
    var city: String?
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        loading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func loading() {
        if city != nil {
            let list = WeatherHelper.shared.currentWeather(city: city!)
                .retryWhen(retryHandler)
            .share()
            
                list.subscribe(onNext: { forecastsTuple in
                    print(forecastsTuple)
                },
                           onError: {e in
                            if let error = e as? NSError, error.code == NSURLErrorNotConnectedToInternet {
                                DispatchQueue.main.async {
                                    self.title = "No Internet connection."
                                }
                            }
                })
                .disposed(by: self.disposeBag)
            //fulfill tableView
            list.map { $0.0 }
                .bind(to: self.tblForecasts.rx.items) {
                    (tableView: UITableView, index: Int, forecastItem: Weather) in
                    let cell: ForecastTableViewCell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: IndexPath(row: index, section: 0)) as! ForecastTableViewCell
                    cell.setDate(timeStamp: forecastItem.timeStamp)
                    cell.lblTemperatureValue.text = String(forecastItem.temperature) + "°C"
                    cell.lblWindSpeedValue.text = String(forecastItem.windSpeed) + "mph"
                    cell.lblHumidityValue.text = String(forecastItem.humidity) + "%"
                    
                    cell.imgWeatherIcon.kf.setImage(with: URL(string: forecastItem.icon))
                    return cell }
                .disposed(by: disposeBag)
            //update title
            list.map { $0.1 ?? "" }
                .bind(to: self.rx.title)
            .disposed(by: disposeBag)
        }
    }
    
    private let retryHandler: (Observable<Error>) -> Observable<Int> = { e in
        return e.flatMapWithIndex { (error, attempt) -> Observable<Int> in
            if attempt >= maxAttempts - 1 {
                return Observable.error(error)
            }
            if let castError = error as? WeatherHelper.WeatherHelperError, castError == .invalidJSON || castError == .cityNotFound{
                return Observable.error(error)
            }
            //TODO rm after review
            print("== retrying after \(attempt + 1) seconds ==")
            return Observable<Int>.timer(Double(attempt + 1), scheduler: MainScheduler.instance).take(1)
        }
    }
}
