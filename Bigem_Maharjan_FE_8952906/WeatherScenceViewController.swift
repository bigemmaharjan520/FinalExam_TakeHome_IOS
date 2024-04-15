//
//  WeatherScenceViewController.swift
//  Bigem_Maharjan_FE_8952906
//
//  Created by user240741 on 4/11/24.
//

import UIKit

class WeatherScenceViewController: UIViewController {

    //For speed of wind
    @IBOutlet weak var windSpeed: UILabel!
    
    //For humidity
    @IBOutlet weak var humidity: UILabel!
    
    //For Visibility
    @IBOutlet weak var visibility: UILabel!
    
    //Weather Temperature
    @IBOutlet weak var temperature: UILabel!
    
    //Weather description
    @IBOutlet weak var weatherDesc: UILabel!
    
    //Weather Icon
    @IBOutlet weak var weatherIcon: UIImageView!
    
    //City Name
    @IBOutlet weak var cityName: UILabel!
    
    
    //Change City Name Plus Button
    @IBAction func changeCityName(_ sender: Any) {
        //Alert box with the message
        let alert = UIAlertController(title:"Enter your location", message:"Please write name of the location that you are", preferredStyle: .alert)
        
        //textfield in alert box
        alert.addTextField{field in field.placeholder = "Enter location..."}
        
        //Cancel button in alert
        alert.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler:{[weak alert](_) in alert?.dismiss(animated:true)}))
        
        //Submit button in alert
        alert.addAction(UIAlertAction(title:"Submit", style:.default, handler:{ [weak self] (_) in
            if let field = alert.textFields?.first{
            if let text = field.text, !text.isEmpty{
                
                DispatchQueue.main.async{
//                    //For Data persistence
                    var currentTasks = UserDefaults.standard.stringArray(forKey: "cityName") ?? []
                    currentTasks.append(text)
                    UserDefaults.standard.setValue(currentTasks, forKey: "cityName")
                    
                    //storing value in cityName label
                    self?.cityName.text = text
                    
                    //Calling get weather function once the city name is changed
                    self?.getWeather(for: text)
                }
            }
        }}))
        self.present(alert, animated:true, completion: nil)
    }
    
    
    //Home Icon
    @IBAction func goHome(_ sender: Any) {
        // Implementing the code to navigate back to the main screen
            navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cityName.text = "Waterloo"
        getWeather(for: cityName.text!)
    }
    
    
        //function for getting weather
    func getWeather(for location: String){
            
            //URL Session
            let weatherApiUrl = "https://api.openweathermap.org/data/2.5/weather?q=\(location)&appid=fe6e61fc470bfd4e136f083cef57e09c"
            
            //Using urlSession to make a request
            URLSession.shared.dataTask(with: URL(string: weatherApiUrl)!, completionHandler: {data, response, error in
                //Validation
                guard let data = data, error == nil else {
                    print("Seems some error")
                    return
                }
                
                //Converting data to models/ some object
                var json: WeatherResponse?
                do{
                    json = try JSONDecoder().decode(WeatherResponse.self, from: data)
                }
                catch{
                    print("error: \(error)")
                }
                
                //If no error is found in do catch below code is run
                guard let result = json else {
                    return
                }
                
                
                //Updating user interface
                //Using Dispatch
                DispatchQueue.main.async {
                                       
                    //Changing weather description according to location entered
                    self.weatherDesc.text = result.weather[0].main
                    
                    //Changing weather temp according to location entered
                    self.temperature.text = "\(String((result.main.temp - 273.15).rounded())) °C"
                    
                    //Changing weather humidity according to location entered
                    self.humidity.text = "\(String(result.main.humidity)) %"
                    
                    //Changing weather wind speed according to location entered
                    self.windSpeed.text = "\(String(result.wind.speed)) km/h"
                    
                    //Changing weather icon according to location entered
                    self.visibility.text = "\(String(result.visibility / 1000.0)) km"

                    //Changing weather icon according to location entered
                    let getWeatherAPIIcon = "https://openweathermap.org/img/w/\(result.weather[0].icon).png"
                    URLSession.shared.dataTask(with: URL(string: getWeatherAPIIcon)!, completionHandler: {data, response, error in
                        //Validation
                        guard let data = data, error == nil else {
                            print("Seems some error")
                            return
                        }
                        //Using Dispatch
                        DispatchQueue.main.async {
                            self.weatherIcon.image = UIImage(data: data)
                        }
                    }).resume()
                }
            }).resume()
        }
    }



