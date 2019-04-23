//
//  InsertLocationVC.swift
//  Meme Weather
//
//  Created by Kang-hee cho on 4/13/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import UIKit
import CoreLocation
import os.log


class InsertLocationVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //start implementation of the view controller
    //textfield
    @IBOutlet weak var OurTableView: UITableView!
    @IBOutlet weak var DoneButton: UIBarButtonItem!
    @IBOutlet weak var CancelButton: UIBarButtonItem!
    @IBOutlet weak var LocationSearchBar: UISearchBar!
    
    var placemarkArray: [CLPlacemark] = []
    var selectedPlacemark: CLPlacemark!
    var ourLocation: String! //to return to the main view
    var LocationSuggestions: [String] = [] //to store all suggestions
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationSearchBar.delegate = self //so we can access the search bar's functions
        OurTableView.delegate = self //so we can access the table view's functions
        OurTableView.dataSource = self //so we can push and pull data from the table view
        OurTableView.isHidden = true
        

        // Do any additional setup after loading the view.
    }
    
//Search Bar Delegator Functions
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //this is when the user begins typing their location
        OurTableView.isHidden = false
    }
    
    //search button was clicked so set the parameter we want to return to the previous view
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        OurTableView.isHidden = true
        ourLocation = LocationSearchBar.text //set our location text
        searchBar.resignFirstResponder() // hide the keyboard after search tapped
    }
    
    //get all relevent places thanks to cllocation and pass the array to the next function
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text == ""){ OurTableView.isHidden = true }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(LocationSearchBar.text!) { (placemarks, error) in
            guard
                let placemarks = placemarks
                else{
                    return
                }
            if(placemarks.count != 0){
                self.addDataToTableArray(placemarks: placemarks)
            }
        }
    }
    
    
//Table View Delegator Functions
    func addDataToTableArray(placemarks: [CLPlacemark]){ //we put all our relevant locations returned by geolocaiton into the array that the table will use to reload
        self.deleteTableData()
        placemarkArray.removeAll()
        for placemark: CLPlacemark in placemarks{
            var combinationString = ""
            if(placemark.subLocality != nil){
                combinationString += placemark.subLocality!
                combinationString += ", "
            }
            if(placemark.locality != nil){
                combinationString += placemark.locality!
                combinationString += ", "
            }
            if(placemark.administrativeArea != nil){
                combinationString += placemark.administrativeArea!
                combinationString += ", "
            }
            if(placemark.country != nil){
            combinationString += placemark.country!
            }
            if(combinationString != ""){
                LocationSuggestions.append(combinationString)
                placemarkArray.append(placemark)
            }
        }
        self.updateTableData()
    }
    
    func updateTableData(){
        OurTableView.reloadData()
    }
    
    func deleteTableData(){
        LocationSuggestions.removeAll()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = LocationSuggestions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LocationSearchBar.text = LocationSuggestions[indexPath.row]
        self.searchBarSearchButtonClicked(LocationSearchBar)
        selectedPlacemark = placemarkArray[indexPath.row]
        tableView.isHidden = true
    }
    
    
    //Other UI fucntions: buttons, etc
    
    @IBAction func Cancel(_ sender: UIButton) {
        //close the enter location modal and do absolutely nothing
        //doing abosolutely nothing is very important so we don't screw up our code
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //executes when done is tapped
        //prepare for the segue unwind into the main view controller
        super.prepare(for: segue, sender: sender)
        if let ourNewLocation = LocationSearchBar.text{
            ourLocation = ourNewLocation
        }
    }
}
