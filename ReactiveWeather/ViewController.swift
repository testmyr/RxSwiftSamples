//
//  ViewController.swift
//  ReactiveWeather
//
//  Created by sdk on 8/27/17.
//  Copyright © 2017 Sdk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var srchBrCity: UISearchBar!
    @IBOutlet weak var tblVwSearchResult: UITableView!
    
    var citiesList = Variable<[String]>([])
    //actually it's a root VC that is not realesed until app quits but nonetheless...
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listing()
        downloading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func downloading() {
        //use a word contains more then two letters
        let searchInput = srchBrCity.rx.value
            .filter {
                let numberOfLetters = ($0 ?? "").characters.count
                if numberOfLetters < 3 {
                    self.citiesList.value = []
                    return false
                }
                return true
        }
        let searching = searchInput.flatMap { inputText in
            return GeoHelper.shared.searchCities(text: inputText ?? "Error")
        }
        //making indeed a request for getting the list of cities
        searching.bind(to: citiesList)
            .disposed(by: disposeBag)
        //hide keyboard
        srchBrCity.rx.searchButtonClicked.subscribe {_ in
            self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    private func listing() {
        citiesList.asObservable().bind(to: tblVwSearchResult.rx.items) {
            (tableView: UITableView, index: Int, element: String) in
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cityCell")
            cell.textLabel?.text = element
            return cell }
            .disposed(by: disposeBag)
        
        tblVwSearchResult.rx
            .modelSelected(String.self)
            .subscribe(onNext: { city in
                
//                    .subscribe {
//                    forecastsTuple in
//                    print(forecastsTuple)
//                }
                let photosViewController = self.storyboard!.instantiateViewController(withIdentifier: "ForecastViewController") as! ForecastViewController
                photosViewController.city = city
                self.navigationController!.pushViewController(photosViewController, animated: true)
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}

