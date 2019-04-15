//
//  HomePageVC.swift
//  Meme Weather
//
//  Created by Kang-hee cho on 4/13/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import UIKit
import CoreLocation
import os.log //for console debugging

class HomePageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var StateName: UILabel!
    @IBOutlet weak var CityName: UILabel!
    @IBOutlet weak var Temperature: UILabel!
    @IBOutlet weak var Meme: UIImageView!
    @IBOutlet weak var ChangeButton: UIButton! //we don't really use this outlet in our code since we already defined its action in the storyboard...
    @IBOutlet weak var Forecast: UILabel!
    @IBOutlet var Background: UIView!
    var returnedLocationString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func getWeatherDataFromLocation(locationInformation: [Double]){ //now that we have our location, we can use the weather api to get weather data
        print(locationInformation[0])
        print(locationInformation[1])
        
    }
    
    //update the city and state names in the view
    func distributeLocationToParts(location: CLPlacemark){
        StateName.text = location.administrativeArea
        let subAd = location.subAdministrativeArea ?? ""
        let subloc = location.subLocality ?? ""
        let locality = location.locality ?? ""
        CityName.text = subAd + ", " + subloc + ", " + locality
    }
    
    func setBackground(){ //set the view's background according to the weather
    
    }
    func setForecast(){ //raining, snowing, sunny, etc
        
    }
    func setMeme(){ //set the appropriate meme based on the current weather
        
    }
    
    func setViewElements(cityName: String, temp: String, actualWeather: String){ //above set methods will be called here along with other set functionality
        StateName.text = cityName
        Temperature.text = temp
        Forecast.text = actualWeather
        if(Temperature.text != nil){
            let intTemp: Int = Int(Temperature.text!) ?? 60
            if(intTemp < 32){
                //chilly or snowing
            }
            else if(intTemp > 32){
            
            }
        }
        
        
    }
    
    @IBAction func unwindToWeatherWithData(sender: UIStoryboardSegue){ //callback from the second view when done was pressed on keyboard
        if(sender.source is InsertLocationVC){
            if let source = sender.source as? InsertLocationVC {
       //the sender has returned the location data. Store it in our location variable
                returnedLocationString = source.ourLocation
                self.determineLocationFromInput()
                
            }
        }
    }
    
    
   
    
    //we want to forward geocode the location parameter input from the other view in order to get the most relevant coordinates
    func determineLocationFromInput(){
        var locationInformation: [Double] = []
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(returnedLocationString) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location,
                let fullLocation: CLPlacemark = placemarks.first
                else{
                    return
                }
            locationInformation = [location.coordinate.latitude, location.coordinate.longitude]
            self.getWeatherDataFromLocation(locationInformation: locationInformation)
            self.distributeLocationToParts(location: fullLocation)
        }
    }
    
    
}//end class

