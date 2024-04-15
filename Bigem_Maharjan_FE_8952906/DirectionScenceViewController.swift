//
//  DirectionScenceViewController.swift
//  Bigem_Maharjan_FE_8952906
//
//  Created by user240741 on 4/13/24.
//

import UIKit
import MapKit
import CoreLocation

class DirectionScenceViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //Map View
    @IBOutlet weak var mapView: MKMapView!
    
    //Home Icon
    @IBAction func goHome(_ sender: Any) {
        // Implementing the code to navigate back to the main screen
        navigationController?.popToRootViewController(animated: true)
    }
    
    //Zoom Slider for user to zoom in and out of the map
    @IBAction func zoomSliding(_ sender: UISlider) {
        let value = Double(sender.value)
        let span = MKCoordinateSpan(latitudeDelta: value, longitudeDelta: value)
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    //change location add button
    @IBAction func changeLocation(_ sender: Any) {
        //Alert box with the message
        let alert = UIAlertController(title:"Start point and End Point", message:"Enter your start point and end point", preferredStyle: .alert)
        
        //textfield in alert box for start and end point location
        alert.addTextField{field in field.placeholder = "Enter start point"}
        alert.addTextField{field in field.placeholder = "Enter end point"}
        
        //Cancel button in alert
        alert.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler:{[weak alert](_) in alert?.dismiss(animated:true)}))
        
        //Submit button in alert
        alert.addAction(UIAlertAction(title:"Submit", style:.default, handler:{ [weak self] (_) in
            guard let startCity = alert.textFields?[0].text,
                  let endCity = alert.textFields?[1].text else {
                return
            }
            self?.geocodeAndShowOnMap(startCity: startCity, endCity: endCity)
            
            
        }))
        self.present(alert, animated:true, completion: nil)
    }
    
    //creating variable for location manager
    var locationManager: CLLocationManager!
    
    //Current Location
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    //Setup of Location function
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
        
        //Function for setting up the map
        setupMap()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //map setup function for start point
    func setupMap() {
        // Add start point pin
        if let currentLocation = locationManager.location {
            let startPin = MKPointAnnotation()
            startPin.coordinate = currentLocation.coordinate
            startPin.title = "Start Point"
            mapView.addAnnotation(startPin)
            
            // Zoom to start point
            let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //getting the coordinate of the location entered by the user
    func geocodeAndShowOnMap(startCity: String, endCity: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(startCity) { (startPlacemarks, startError) in
            if let startError = startError {
                print("Geocoding start city failed: \(startError.localizedDescription)")
                return
            }
            
            guard let startPlacemark = startPlacemarks?.first else {
                print("No placemark found for start city")
                return
            }
            
            let startCoordinate = startPlacemark.location?.coordinate
            self.addPinToMap(coordinate: startCoordinate, title: "Start", subtitle: startCity)
            
            geocoder.geocodeAddressString(endCity) { (endPlacemarks, endError) in
                if let endError = endError {
                    print("Geocoding end city failed: \(endError.localizedDescription)")
                    return
                }
                
                guard let endPlacemark = endPlacemarks?.first else {
                    print("No placemark found for end city")
                    return
                }
                
                let endCoordinate = endPlacemark.location?.coordinate
                self.addPinToMap(coordinate: endCoordinate, title: "End", subtitle: endCity)
                
                //                   self.showRouteOnMap(startCoordinate: startCoordinate, endCoordinate: endCoordinate, transportType: .automobile)
                
                self.showRouteOnMap(startCoordinate: startCoordinate, endCoordinate: endCoordinate)
            }
        }
    }
    
    
    //    adding the pin point
    func addPinToMap(coordinate: CLLocationCoordinate2D?, title: String, subtitle: String) {
        guard let coordinate = coordinate else {
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
    
    func showRouteOnMap(startCoordinate: CLLocationCoordinate2D?, endCoordinate: CLLocationCoordinate2D?) {
        guard let startCoordinate = startCoordinate, let endCoordinate = endCoordinate else {
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                print("Directions error: \(error.localizedDescription)")
                return
            }
            
            if let route = response?.routes.first {
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            }
        }
    }
    
    //Walking button
    @IBAction func walking(_ sender: UIButton) {
        //        showRouteWithTransportType(.walking)
    }
    
    //Vehicle button
    @IBAction func vehicle(_ sender: UIButton) {
        //        showRouteWithTransportType(.automobile)
    }
    
    //For mode of travel
    func showRouteWithTransportType(_ transportType: MKDirectionsTransportType) {
        //           guard let annotations = mapView.annotations as? [MKPointAnnotation], annotations.count >= 2 else {
        //               return
        //           }
        //
        //           let startAnnotation = annotations[0]
        //           let endAnnotation = annotations[1]
        //
        //           showRouteOnMap(startCoordinate: startAnnotation.coordinate, endCoordinate: endAnnotation.coordinate, transportType: transportType)
        //       }
    }
}
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }


