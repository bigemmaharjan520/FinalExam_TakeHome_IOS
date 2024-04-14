//
//  ViewController.swift
//  Bigem_Maharjan_FE_8952906
//
//  Created by user240741 on 4/2/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //Speed of wind
    @IBOutlet weak var windSpeed: UILabel!
    
    //Humidity
    @IBOutlet weak var humidity: UILabel!
    
    //Temperature
    @IBOutlet weak var temperature: UILabel!
    
    //Weather Icon
    @IBOutlet weak var weatherIcon: UIImageView!
    
    //Map View
    @IBOutlet weak var mapView: MKMapView!
    
    //creating variable for location manager
    var locationManager: CLLocationManager!

    //Current Location
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional setup after loading the view
                
        setup()
    }
    
    //Settup of Location function
    func setup(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //asking for user permission to get access to location
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        
        //Starting the location
        locationManager.startUpdatingLocation()
        
        //show user location on map
        mapView.showsUserLocation = true
    }

    
    //Map Functionality func
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            userCurrentLocation()
        }
    }
    
    //For user current location
    func userCurrentLocation(){
        guard let location = currentLocation else
        {
            return
        }
        
        //zooming in the user location and showing the annotation
        let userLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        mapView.setRegion(region, animated: true)
        
        
        //Calling weather function
        requestWeatherStatus()
    }
    
    //Weather function starts
    //Getting weather of the current user location
    func requestWeatherStatus(){
        
        guard let location = currentLocation else
        {
            return
        }
        
        //getting coordinate of user location for the weather
        let latitudee = location.coordinate.latitude
       let longitudee = location.coordinate.longitude
        
        //print("Latitude:\(latitudee), Longitude:\(longitudee)")
        //URL Session
        let weatherApiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitudee)&lon=\(longitudee)&appid=fe6e61fc470bfd4e136f083cef57e09c"
        
//        print(weatherApiUrl)
        
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
               
                //Changing weather temp according to location
                self.temperature.text = "\(String((result.main.temp - 273.15).rounded())) °C"
                
                //Changing weather humidity according to location
                self.humidity.text = "\(String(result.main.humidity)) %"
                
                //Changing weather wind speed according to location
                self.windSpeed.text = "\(String(result.wind.speed)) km/h"

                //Changing weather icon according to location
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


//Parsing JSON
struct WeatherResponse: Codable{
    let coord : WeatherCoor
    let weather: [WeatherDescription]
    let base: String
    let main: WeatherMain
    let visibility: Double
    let wind: WeatherWind
    let clouds: WeatherCloud
    let dt: Double
    let sys: WeatherSys
    let id: Int
    let name: String
    let cod: Double
}

//coord
struct WeatherCoor: Codable {
    let lon: Float
    let lat: Float
}

//weather
struct WeatherDescription: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

//main
struct WeatherMain: Codable{
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Double
    let humidity: Int
}

//wind
struct WeatherWind: Codable{
    let speed: Double
    let deg: Double
}

//clouds
struct WeatherCloud: Codable{
    let all: Double
}

//sys
struct WeatherSys: Codable {
    let type: Int
    let id: Int
    let country: String
    let sunrise: Double
    let sunset: Double
}
