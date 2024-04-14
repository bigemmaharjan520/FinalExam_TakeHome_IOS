//
//  NewsScenceViewController.swift
//  Bigem_Maharjan_FE_8952906
//
//  Created by user240741 on 4/13/24.
//

import UIKit

import CoreLocation

class NewsScenceViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var allTasks = [String]() //creating array variable to store the tasks
    
    var arrayOfArrays: [[String]] = [] //To store the all task array
    
    @IBOutlet weak var newsTableView: UITableView!
    
    //Home Icon
    @IBAction func goHome(_ sender: Any) {
        // Implementing the code to navigate back to the main screen
        navigationController?.popToRootViewController(animated: true)
    }
    
    //Change location to the one that you want to get news on
    @IBAction func getLocationNews(_ sender: Any) {
        //Alert box with the message
        let alert = UIAlertController(title:"Enter your location", message:"Please write name of the location that you are to get the news", preferredStyle: .alert)
        
        //textfield in alert box
        alert.addTextField{field in field.placeholder = "Enter location..."}
        
        //Cancel button in alert
        alert.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler:{[weak alert](_) in alert?.dismiss(animated:true)}))
        
        //Submit button in alert
        alert.addAction(UIAlertAction(title:"Submit", style:.default, handler:{ [weak self] (_) in
            if let field = alert.textFields?.first{
                if let text = field.text, !text.isEmpty{
                    
                    DispatchQueue.main.async{
                        //For Data persistence
                        var currentTasks = UserDefaults.standard.stringArray(forKey: "newsLocation") ?? []
                        currentTasks.append(text)
                        UserDefaults.standard.setValue(currentTasks, forKey: "newsLocation")
                        
                        //storing value in cityName label
                        self?.newsLocation = text
                        
                        //Calling get weather function once the city name is changed
                        self?.requestNews(for: text)
                        
                        self?.newsTableView.reloadData() //reloading
                        
                    }
                }
            }}))
        self.present(alert, animated:true, completion: nil)
    }
    
    
    //News Source
//    @IBOutlet weak var sourceNews: UILabel!
//
//    //News Author
//    @IBOutlet weak var authorNews: UILabel!
//
//    //News Title
//    @IBOutlet weak var titleNews: UILabel!
//
//    //News Description
//    @IBOutlet weak var descNews: UILabel!

 
 //creating variable for location manager
 var locationManager: CLLocationManager!

 //Current Location
 var currentLocation: CLLocation?
 
 //creating variable for storing location name
 var newsLocation: String = ""
 

 
 override func viewDidLoad() {
     super.viewDidLoad()
//        self.allTasks = UserDefaults.standard.stringArray(forKey: "allTasks") ?? []
//        newsTableView.dataSource = self
//        newsTableView.delegate = self

     // Do any additional setup after loading the view.
     setup()
     
     newsLocation = "Waterloo"
 }
 
 //Settup of Location function
 func setup(){
     locationManager = CLLocationManager()
     locationManager.delegate = self
     
     //asking for user permission to get access to location
     locationManager.requestWhenInUseAuthorization()
     
     //Starting the location
     locationManager.startUpdatingLocation()
 }
 
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         guard let location = locations.first else {
             return
         }
         
         // Reverse geocode location
         CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
             if let error = error {
                 print("Reverse geocode failed: \(error.localizedDescription)")
                 return
             }
             
             if let placemark = placemarks?.first {
                 // Display location name
                 if let city = placemark.locality {
                     self.newsLocation = "\(city)"
                 } else {
                     self.newsLocation = "Unknown Location"
                 }
             }
         }
         
         // Stop updating location after the first update
         locationManager.stopUpdatingLocation()
     
     //calling the function
     requestNews(for: newsLocation)
     }
 
 
 //For User Location
 func requestNews(for locationName: String){
     let newsApiUrl = "https://newsapi.org/v2/top-headlines?q=\(locationName)&apiKey=057473595377489fadd3fd971d48d6ea"
     
     print("https://newsapi.org/v2/top-headlines?q=\(locationName)&apiKey=057473595377489fadd3fd971d48d6ea")
     
     //Using Url Session to make a request
     URLSession.shared.dataTask(with: URL(string: newsApiUrl)!, completionHandler: {
         data, response, error in
         //Validation
         guard let data = data, error == nil else {
             print("Seems some error")
             return
         }
         
         //Converting data to models/ some object
         var json: NewsReportResponse?
         
         do{
             json = try JSONDecoder().decode(NewsReportResponse.self, from: data)
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
             //Changing the title, description, author and source according to the city name
             for number in result.articles {
//                    self.titleNews.text = number.title
//
//                    self.descNews.text = number.description
//
//                    self.authorNews.text = number.author
//
//                    self.sourceNews.text = number.source.name
                 
                 self.allTasks.append(number.title)
                 self.allTasks.append(number.description ?? "No Description")
                 self.allTasks.append(number.author)
                 self.allTasks.append(number.source.name)
             }
             
             self.arrayOfArrays.append(self.allTasks)
         }
     })
 }
 
 //For Table View
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return allTasks.count
 }
 
 //For Table View Cell
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "todoListCell", for: indexPath)
     
     cell.textLabel?.text = allTasks[indexPath.row]
     
     // Configure cell UI elements
//          cell.Title.text = "Title"
//          cell.subtitleLabel.text = "Subtitle"
     
     return cell
 }

}


struct NewsReportResponse: Codable {
 let status: String
 let totalResults: Int
 let articles: [Article]
}

// MARK: - Article
struct Article: Codable {
 let source: Source
 let author, title: String
 let description: String?
 let url: String
 let urlToImage: JSONNull?
 let publishedAt: Date
 let content: JSONNull?
}

// MARK: - Source
struct Source: Codable {
 let id, name: String
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

 public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
     return true
 }

 public var hashValue: Int {
     return 0
 }

 public init() {}

 public required init(from decoder: Decoder) throws {
     let container = try decoder.singleValueContainer()
     if !container.decodeNil() {
         throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
     }
 }

 public func encode(to encoder: Encoder) throws {
     var container = encoder.singleValueContainer()
     try container.encodeNil()
 }
}

