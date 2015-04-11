//
//  ViewController.swift
//  BumpInto
//
//  Created by Nazim Amin on 4/11/15.
//  Copyright (c) 2015 sensnoia. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var zoomOut: UIButton!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initiatLocationManager()
    }
    
    func initiatLocationManager(){
    // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        if(CLLocationManager.locationServicesEnabled()){
            let status = CLLocationManager.authorizationStatus()
            if(status  == CLAuthorizationStatus.NotDetermined){
                self.locationManager.requestAlwaysAuthorization()
            }else{
                locationManager.distanceFilter = kCLDistanceFilterNone
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
    
                mapView.delegate = self
                mapView.mapType = MKMapType.Standard
                mapView.showsUserLocation = true
                mapView.showsBuildings = true
            }
        }
        else{
            println("Location service isn't enabled")
        }
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //if the locationManager fails
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        initiatLocationManager()
    }
    //this gets called in every single move
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var xy = locationObj.coordinate
        var speed = locationObj.speed
        println("Latitude \(xy.latitude)")
        println("Longitude: \(xy.longitude)")
        println("Speed: \(speed)")
    }
    //zoom out function/. hardcoded
    @IBAction func ZoomOutButton(sender: UIButton) {
        var MapSpan = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta*2, longitudeDelta: mapView.region.span.longitudeDelta*2)
        var MapRegion = MKCoordinateRegion(center: mapView.region.center, span: MapSpan)
        mapView.setRegion(MapRegion, animated: true)
    }
}

