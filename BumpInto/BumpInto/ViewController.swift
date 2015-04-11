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
	/*
		// this is the dispatch source code, that creates a timer
		dispatch_source_t CreateDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block){
			dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
			if (timer){
				dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
				dispatch_source_set_event_handler(timer, block);
				dispatch_resume(timer);
   }
   return timer;
}
void CreateTimer() // this shit makes a timer
{
   dispatch_source_t aTimer = CreateDispatchTimer(5ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC, dispatch_get_main_queue(), ^{ 
		MyPeriodicTask(); }); // heres where we place the method that updates shit, the function needs to be here
		// when you call the timer, the function is then called
		// ths has te potential to be hazardous, so make sure to call it when youre good and ready
 
   // Store it somewhere for later use.
    if (aTimer)
    {
        MyStoreTimer(aTimer);
    }
}

MyPeriodicTask(){
	// update location nd shit here
	
}
	*/
    
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
        var locationObj = locationArray.lastObject as CLLocation
        var xy = locationObj.coordinate
        var speed = locationObj.speed
        var m_latDelta = mapView.region.span.latitudeDelta
        var m_longDelta = mapView.region.span.longitudeDelta
        
        var latitudeText:String = "\(xy.latitude)"
        var longitudeText:String = "\(xy.longitude)"
        var latDeltaText:String = "\(m_latDelta)"
        var longDeltaText:String = "\(m_latDelta)"
        
        
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
        mapView.setRegion(region, animated: true)
        
        
        var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(37, -122)
        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "okay this is the title"
        self.mapView.addAnnotation(objectAnnotation)
        
    }
}

