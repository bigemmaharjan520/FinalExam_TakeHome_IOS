//
//  NewsScenceViewController.swift
//  Bigem_Maharjan_FE_8952906
//
//  Created by user240741 on 4/13/24.
//

import UIKit

import CoreLocation

class NewsScenceViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //Table View
    @IBOutlet weak var newsTableView: UITableView!
    
    //Creating a struct for storing the needed news information
    struct NewsReport {
        let newsTitle: String
        let newsDesc: String?
        let newsAuthor: String
        let newsSource: String
    }
    
    var arrayOfNewsReport: [NewsReport] = [] //To store the all news array
             
    //creating variable for location manager
    var locationManager: CLLocationManager!

    //Current Location
    var currentLocation: CLLocation?
     
    //creating variable for storing location name
    var newsLocation: String = ""
        
    //Home Icon
    @IBAction func goHome(_ sender: Any) {
        // Implementing the code to navigate back to the main screen
        navigationController?.popToRootViewController(animated: true)
    }
    

    //Change location to the one that you want to get news on
    @IBAction func changeNewsLocation(_ sender: Any) {
   
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
                                                
                        //Calling get weather function once the city name is changed
                        self?.requestNews(for: text)
                        
                        self?.newsTableView.reloadData() //reloading
                        
                    }
                }
            }}))
        self.present(alert, animated:true, completion: nil)
    }
    
 override func viewDidLoad() {
     super.viewDidLoad()
        newsTableView.dataSource = self
        newsTableView.delegate = self

     // Do any additional setup after loading the view.
     setup()
     
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
    
         // Reverse geocode location to get the name of the location that user is located
         CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
             if let error = error {
                 print("Reverse geocode failed: \(error.localizedDescription)")
                 return
             }
             
             if let placemark = placemarks?.first {
                 // Display location name
                 if let city = placemark.locality {
                     self.newsLocation = "\(city)"
//                     calling the function
                     self.requestNews(for: "\(city)")
                 } else {
                     self.newsLocation = "Waterloo" //Providing by default value
                 }
             }
         }
         
         // Stop updating location after the first update
         locationManager.stopUpdatingLocation()
     
     //
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
             //Using if condition to check whether the total result is 0 or not
             if(result.totalResults == 0){
                     self.arrayOfNewsReport.removeAll() //Getting removeAll() to remove the data as it changes according to location
                 //Displaying if no any news is available
                 let getNews = NewsReport(newsTitle: "No News Available", newsDesc: "Click on plus sign to change location.", newsAuthor: "Please check later.", newsSource: "Thank you.")
                 
                 self.arrayOfNewsReport.append(getNews) //Adding the data
             }else{
                 self.arrayOfNewsReport.removeAll() //Getting removeAll() to remove the data as it changes according to location
                 //Changing the title, description, author and source according to the city name
                 for number in result.articles {
                     let getNews = NewsReport(newsTitle: number.title, newsDesc: number.description, newsAuthor: number.author, newsSource: number.source.name)

                     self.arrayOfNewsReport.append(getNews) //Adding the data
                     
    //                 print(self.arrayOfNewsReport)
                 }
             }
             
             // Reload table view data after fetching news
            self.newsTableView.reloadData()
         }
     }).resume()
 }
 
 //For Table View count
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return arrayOfNewsReport.count
 }
 
 //For Table View Cell
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let report = arrayOfNewsReport[indexPath.row]
    
     let cell = newsTableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
     
     //Checking which data to display
     if(report.newsTitle == "No News Available"){
         cell.newsTitle.text = report.newsTitle
         cell.newsDescription.text = report.newsDesc
         cell.newsAuthor.text = report.newsAuthor
         cell.newsSource.text = report.newsSource
         return cell
     }else{
         cell.newsTitle.text = "Title: \(report.newsTitle)"
         cell.newsDescription.text = "Description: \(report.newsDesc ?? "No Description")"
         cell.newsAuthor.text = "Author: \(report.newsAuthor)"
         cell.newsSource.text = "Source: \(report.newsSource)"
         return cell
     }
 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           // Return the desired height for the cells
           return 150 // Adjust this value according to your requirement
       }
}


// Parsing JSON
// MARK: - NewsReportResponse
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
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

// MARK: - Source
struct Source: Codable {
    let id, name: String
}
