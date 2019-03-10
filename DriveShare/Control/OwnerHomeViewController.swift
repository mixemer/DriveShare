//
//  OwnerHomeViewController.swift
//  DriveShare
//
//  Created by Mehmet Sahin on 3/10/19.
//  Copyright © 2019 Mehmet Sahin. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class OwnerHomeViewController: UIViewController {

    var lat = Double()
    var long = Double()
    var model = ""
    var id = ""
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMap()
        updateBackEnd()
        
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func initMap() {
        //        print("lat \(lat) and long \(long)")
//        let initialLocation = CLLocation(latitude: lat, longitude: long)
        let initialLocation = CLLocation(latitude: 40.485348, longitude: -74.438255)
        centerMapOnLocation(location: initialLocation)
        let annotation = MKPointAnnotation()
        let initialLocation2 = CLLocationCoordinate2D(latitude: 40.485348, longitude: -74.438255)
        annotation.coordinate = initialLocation2
//        annotation.title = "Point \(index+1)"
         mapView.addAnnotation(annotation)
    }
    
    func updateBackEnd() {
        let parameters: [String: Any] = [
            "model" : model,
            "modelId" : id,
            "longitude" : long,
            "latitude": lat
        ]
        
        Alamofire.request("\(Constants.appServer)/api/car", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
        }
    }
    
    
    @IBAction func switchToggle(_ sender: UISwitch) {
        if sender.isOn {
            Alamofire.request("\(Constants.appServer)/vehicleUnlock", method: .get).responseJSON {
                response in
                print("Car Uncloked")
            }
        } else {
            Alamofire.request("\(Constants.appServer)/vehicleLock", method: .get).responseJSON {
                response in
                print("CarLloked")
            }
        }
    }
    
}
