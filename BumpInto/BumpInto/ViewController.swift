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
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //if the locationManager fails
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        initiatLocationManager()
    }
    
    
    func sendPost(x: String, y: String, xDelta: String, yDelta: String){
        var URL: NSURL = NSURL(string: "http://localhost:8080/data/")!
        var userName = "Numaer"
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:URL)
        request.HTTPMethod = "POST"
        //var bodyData = "{\"name\": \(userName), \"location\" : {\"x\": \"\(x)\", \"y\": \"\(y)\"}}"
        var bodyData = "name=\(userName)&x=\(x)&y=\(y)&xDelta=\(xDelta), &yDelta=\(yDelta)"
        //println(bodyData)
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
                {
                    (response, data, error) in
                    println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
    }
    
    //this gets called in every single second or so
	// put this shit in place of myperiodic function
	// call createTimer when you need to start doing this
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        var xy = locationObj.coordinate
        var speed = locationObj.speed
        var m_latDelta = mapView.region.span.latitudeDelta
        var m_longDelta = mapView.region.span.longitudeDelta
        

        var latitudeText:String = "\(xy.latitude)"
        var longitudeText:String = "\(xy.longitude)"
        var latDeltaText:String = "\(m_latDelta)"
        var longDeltaText:String = "\(m_latDelta)"
        delay(30) {
        
        //sendPost(latitudeText, y: longitudeText, xDelta: latDeltaText, yDelta: longDeltaText)
        

        //use this to calculate how far they are
        //var distance = locationObj.distanceFromLocation(<#location: CLLocation!#>)
        
        println("Latitude \(xy.latitude)")
        println("Longitude: \(xy.longitude)")
        println("Speed: \(speed)")
        println("LangDelta: \(m_latDelta)")
        println("LongDelta: \(m_longDelta)")

        var latDelta:CLLocationDegrees = 0.01 //mapView.region.span.latitudeDelta*2
        var longDelta:CLLocationDegrees = 0.01 //mapView.region.span.latitudeDelta*2
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        var pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(37, -122)
        
        var region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        self.mapView.setRegion(region, animated: true)
        
        var positionAnnotation = MKPointAnnotation()
        
        positionAnnotation.coordinate = pointLocation
        positionAnnotation.title = "name of the User"
        
        self.mapView.addAnnotation(positionAnnotation)
        }
            
    }
    func mapView(mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            let reuseId = "reuseID"
            var redPin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            
            if(redPin == nil){
                redPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                redPin!.canShowCallout = true
                redPin!.animatesDrop = true
                redPin!.pinColor = .Red
                redPin!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            } else {
                redPin!.annotation = annotation
            }
            return redPin!
    }

}

