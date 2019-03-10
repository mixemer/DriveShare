//
//  ConectViewController.swift
//  DriveShare
//
//  Created by Mehmet Sahin on 3/10/19.
//  Copyright © 2019 Mehmet Sahin. All rights reserved.
//

import Alamofire
import UIKit
import SmartcarAuth

class ConectViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var vehicleText = ""
    var id = ""
    var model = ""
    var data = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // TODO: Authorization Step 1: Initialize the Smartcar object
        appDelegate.smartcar = SmartcarAuth(
            clientId: Constants.clientId,
            redirectUri: "sc\(Constants.clientId)://exchange",
            development: true, // true
            completion: completion
        )
        
        // display a button
        let button = UIButton(frame: CGRect(x: 0, y: 530, width: 250, height: 50))
        button.addTarget(self, action: #selector(self.connectPressed(_:)), for: .touchUpInside)
        button.setTitle("Connect your vehicle", for: .normal)
        button.backgroundColor = UIColor.black
        self.view.addSubview(button)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectPressed(_ sender: UIButton) {
        // TODO: Authorization Step 2: Launch authorization flow
        //        self.performSegue(withIdentifier: "displayVehicleInfo", sender: self)
        let smartcar = appDelegate.smartcar!
        smartcar.launchAuthFlow(viewController: self)
        
        
    }
    
    func completion(err: Error?, code: String?, state: String?) -> Any {
        // TODO: Authorization Step 3b: Receive an authorization code
        print(code!);
        print("in completion")
        
        // TODO: Request Step 1: Obtain an access token
        Alamofire.request("\(Constants.appServer)/exchange?code=\(code!)", method: .get)
            .responseJSON {
                a in
                // TODO: Request Step 2: Get vehicle information
                // send request to retrieve the vehicle info
                Alamofire.request("\(Constants.appServer)/vehicleInfo", method: .get).responseJSON { response in
                    
                    
                    if let result = response.result.value {
                        print(result)
                        let JSON = result as! NSDictionary
                        
                        self.id = JSON.object(forKey: "id")!  as! String
                        self.model = JSON.object(forKey: "model")!  as! String
                        
                        //                        let vehicle = "\(year) \(make) \(model)"
                        //                        self.vehicleText = vehicle
                    }
                }
                
                Alamofire.request("\(Constants.appServer)/vehicleLoc", method: .get).responseJSON {
                    response in
                    //                    print(response.result.value!)
                    if let result = response.result.value {
                        let JSON = result as! NSDictionary
                        self.data = JSON.object(forKey: "data")!  as! NSDictionary
                        
                        print("data \(self.data)")
                        print("lat \(String(describing: self.data["latitude"]))")
                        print("long \(String(describing: self.data["longitude"]))")
                        
                        self.performSegue(withIdentifier: "displayVehicleInfo", sender: self)
                    }
                }
                
                //                Alamofire.request("\(Constants.appServer)/vehiclelock", method: .get).responseJSON {
                //                    response in
                ////                    print(response.result.value!)
                //                }
        }
        
        return ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if let destinationVC = segue.destination as? InfoViewController {
        //            destinationVC.text = self.vehicleText
        //            destinationVC.id = id
        //        }
        
        if let destinationVC = segue.destination as? OwnerHomeViewController {
            destinationVC.long = self.data["longitude"] as! Double
            destinationVC.lat = self.data["latitude"] as! Double
            destinationVC.id = self.id
            destinationVC.model = self.model
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
