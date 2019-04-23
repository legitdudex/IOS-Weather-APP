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
import Foundation


class HomePageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var StateName: UILabel!
    @IBOutlet weak var CityName: UILabel!
    @IBOutlet weak var Temperature: UILabel!
    @IBOutlet weak var TempMinLabel: UILabel!
    @IBOutlet weak var TempMin: UILabel!
    @IBOutlet weak var TempHighLabel: UILabel!
    @IBOutlet weak var TempHigh: UILabel!
    @IBOutlet weak var Meme: UIImageView!
    @IBOutlet weak var ChangeButton: UIButton! //we don't really use this outlet in our code since we already defined its action in the storyboard...
    @IBOutlet weak var Forecast: UILabel!
    @IBOutlet var Background: UIView!
    let APIKey: String = "1919a931587b0f192776194fce39ad2c"
    var BaseURL: String = "http://api.openweathermap.org/data/2.5/weather?zip="
    var forecastLabelValue: String = ""
    var tempMinValue: String = ""
    var tempMaxValue: String = ""
    var tempValue: String = ""
    var returnedLocationString: String = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.TempMinLabel.text = "Min"
        self.TempHighLabel.text = "High"
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient")!)
        StateName.text = "NY"
        CityName.text = "NY, EastNorthport, CandySection"
        getWeatherDataFromLocation(countryCode: "us", zipCode: "11731")
        
        
    }
    
    func getWeatherDataFromLocation(countryCode: String, zipCode: String){ //now that we have our location, we can use the weather api to get weather data
        guard let APIURL = URL(string: BaseURL+zipCode+","+countryCode.lowercased()+"&APPID="+APIKey+"&units=imperial") //form our URL
            else{ //if URL is invalid
                print("Invalid URL")
                return
            }
        URLSession.shared.dataTask(with: APIURL) { (data, response, error) in //get json data from API
            guard let data = data else{print(error ?? "Error"); return;}//we must make sure the data is valid/non-nil
            do{
                
                guard let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { print("Error"); return}
                for obj in jsonDictionary{
                    if(obj.key == "weather"){
                        let nestedDictionary = obj.value as? Array ?? []
                        if(nestedDictionary.count != 0){
                            let dictionary = nestedDictionary[0]
                            guard let dict = dictionary as? [String: Any] else{ print("Error"); return }
                            for obj1 in dict{
                                if(obj1.key == "description"){
                                    self.forecastLabelValue = obj1.value as! String
                                }
                            }
                            
                        }
                    }
                    if(obj.key == "main"){
                        guard let dict2 = obj.value as? [String:Any] else {print("Error"); return }
                        for obj2 in dict2{
                            DispatchQueue.main.async {
                            if(obj2.key == "temp"){
                                self.tempValue = String(describing: obj2.value)
                            }
                            if(obj2.key == "temp_min"){
                                self.tempMinValue = String(describing: obj2.value)
                            }
                            if(obj2.key == "temp_max"){
                                self.tempMaxValue = String(describing: obj2.value)
                            }
                                self.updateLabels()
                            }
                        }
                    }
                }
            }catch let jsonError { print("JsonError: ", jsonError) }
        } .resume()
        self.updateLabels()
    }
    
    
    //update the city and state names in the view
    func distributeLocationToParts(location: CLPlacemark){
        StateName.text = location.administrativeArea
        let ad = location.administrativeArea ?? ""
        let local = location.locality ?? ""
        let sublocal = location.subLocality ?? ""
        CityName.text = ad+", "+local
        if(sublocal != ""){
            CityName.text = ad+","+local+","+sublocal
        }
    }
    
    func updateLabels(){
        Forecast.text = self.forecastLabelValue
        TempMin.text = self.tempMinValue.prefix(5)+"°"
        Temperature.text = self.tempValue.prefix(5)+"°"
        TempHigh.text = self.tempMaxValue.prefix(5)+"°"
        setBackground(forecast: self.forecastLabelValue)
        setMeme(forecast: self.forecastLabelValue)
        
    }
    
    func setBackground(forecast: String){ //set the view's background according to the weather
        
    }
    
    func setMeme(forecast: String){ //set the appropriate meme based on the current weather
        
    }
    
    
    @IBAction func unwindToWeatherWithData(sender: UIStoryboardSegue){ //callback from the second view when done was pressed on keyboard
        if(sender.source is InsertLocationVC){
            if let source = sender.source as? InsertLocationVC {
       //the sender has returned the location data. Store it in our location variable
                if(source.selectedPlacemark != nil){
                    self.getWeatherDataFromLocation(countryCode: source.selectedPlacemark.isoCountryCode ?? "", zipCode: source.selectedPlacemark.postalCode ?? "")
                    self.distributeLocationToParts(location: source.selectedPlacemark)
                }
                else if source.selectedPlacemark == nil{
                    returnedLocationString = source.ourLocation
                    self.determineLocationFromInput()
                }
                
            }
        }
    }
    
    
   
    
    //we want to forward geocode the location parameter input from the other view in order to get the most relevant coordinates
    func determineLocationFromInput(){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(returnedLocationString) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let fullLocation: CLPlacemark = placemarks.first
                else{
                    return
                }
            if(placemarks.count != 0){
            DispatchQueue.main.async {
                self.getWeatherDataFromLocation(countryCode: fullLocation.isoCountryCode ?? "", zipCode: fullLocation.postalCode ?? "")
            self.distributeLocationToParts(location: fullLocation)
                }
            }
        }
    }
    
    
}//end class

