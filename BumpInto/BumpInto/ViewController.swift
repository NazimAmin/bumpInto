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
    
    @IBOutlet weak var doButton: UIButton!
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
                mapView.userTrackingMode = .Follow
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
    //this gets called in every single second or so
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        var xy = locationObj.coordinate
        var speed = locationObj.speed
        
        //use this to calculate how far they are
        //var distance = locationObj.distanceFromLocation(<#location: CLLocation!#>)
        
        println("Latitude \(xy.latitude)")
        println("Longitude: \(xy.longitude)")
        println("Speed: \(speed)")
        
        let loc = self.mapView.userLocation.location
        if loc == nil {
            println("I don't know where you are now")
            return
        }
        
        //getting the relevent place the user is
        let geo = CLGeocoder()
        geo.reverseGeocodeLocation(loc) {
            (placemarks : [AnyObject]!, error : NSError!) in
            if placemarks != nil {
                let p = placemarks[0] as! CLPlacemark
                println("you are at:\n\(p.addressDictionary.values)") // do something with address
            }
        }
        var latDelta:CLLocationDegrees = 0.01 //mapView.region.span.latitudeDelta*2
        
        var longDelta:CLLocationDegrees = 0.01 //mapView.region.span.latitudeDelta*2
        
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        var pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(37, -122)
        
        var region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        mapView.setRegion(region, animated: true)
        
        var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(37, -122)
        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "okay this is the title"
        self.mapView.addAnnotation(objectAnnotation)

    }
}

