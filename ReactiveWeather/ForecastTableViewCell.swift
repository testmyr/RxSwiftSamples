//
//  ForecastTableViewCell.swift
//  ReactiveWeather
//
//  Created by sdk on 8/28/17.
//  Copyright © 2017 Sdk. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgWeatherIcon: UIImageView!
    @IBOutlet weak var lblTemperatureValue: UILabel!
    @IBOutlet weak var lblWindSpeedValue: UILabel!
    @IBOutlet weak var lblHumidityValue: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDate (timeStamp: TimeInterval) {
        let form = DateFormatter()
        form.locale = Locale.current
        form.dateFormat = "dd-MM-yyyy  hh:mm"
        let dateText = form.string(from: Date(timeIntervalSince1970: timeStamp))
        lblDate.text = dateText
    }

}
