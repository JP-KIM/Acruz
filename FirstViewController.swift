//
//  FirstViewController.swift
//  Acruz
//
//  Created by 김정표 on 2016. 6. 4..
//  Copyright © 2016년 Acruz corp. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class FirstViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    var ref: FIRDatabaseReference!
    var myUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        myUid = FIRAuth.auth()?.currentUser?.uid
        
        setupDefaultUI()
        
        startLoadingDefaultPin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupDefaultUI() {
        // MARK:: SEARCH BAR
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = true
        
        navigationItem.titleView = searchBar
        
        // MARK:: MAP VIEW
        self.mapView.delegate = self
        
        // drop example
        let newYorkLocation = CLLocationCoordinate2DMake(40.730872, -74.003066)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = newYorkLocation
        dropPin.title = "New York City"
        mapView.addAnnotation(dropPin)
        
        // MARK:: LONG PRESS EVENT
        let lpgr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FirstViewController.handleLongPress(_:)))
        self.mapView.addGestureRecognizer(lpgr)
    }
    
    func startLoadingDefaultPin() {
        print("startLoadingDefaultPin")
        ref.child("places").observeEventType(.Value, withBlock: { (snapshot) in
            let enumerator = snapshot.children
            while let myValue: AnyObject = enumerator.nextObject() {
                let lat = myValue.value.objectForKey("lat") as? Double
                let lng = myValue.value.objectForKey("lng") as? Double
                
                //print("lat:\(lat), lng:\(lng)")
                
                let mapCoordinate = CLLocationCoordinate2DMake(lat!, lng!)
                
                print("lat:\(mapCoordinate.latitude), lng:\(mapCoordinate.longitude)")
                
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = mapCoordinate
                dropPin.title = "New York City"
                dropPin.subtitle = "bar?"
                self.mapView.addAnnotation(dropPin)
                
            }
        })
    }
    
    func addTapped() {
        
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != UIGestureRecognizerState.Began) {
            return;
        }
        
        let touchPoint:CGPoint = gestureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate:CLLocationCoordinate2D =
            self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        
        
        print("latitude: \(touchMapCoordinate.latitude), longitude: \(touchMapCoordinate.longitude)")
        
        // firebase add
        let key = ref.child("places").childByAutoId().key
        let place = ["lat": touchMapCoordinate.latitude,
                     "lng": touchMapCoordinate.longitude,
                    ]
        let childUpdate = ["/places/\(key)": place]
        ref.updateChildValues(childUpdate)
        
        /* 
        // will be dropped by callback from server
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = touchMapCoordinate
        dropPin.title = "New York City"
        mapView.addAnnotation(dropPin)
         */
    }
    
    /*
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
            if (annotation is MKUserLocation) {
                return nil
            }
            
            if (annotation.isKindOfClass(CustomAnnotation)) {
                let customAnnotation = annotation as? CustomAnnotation
                mapView.translatesAutoresizingMaskIntoConstraints = false
                var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomAnnotation") as MKAnnotationView!
                
                if (annotationView == nil) {
                    annotationView = customAnnotation?.annotationView()
                } else {
                    annotationView.annotation = annotation;
                }
                
                self.addBounceAnimationToView(annotationView)
                return annotationView
            } else {
                return nil
            }
        }*/

    // When user taps on the disclosure button you can perform a segue to navigate to another view controller
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            print(view.annotation!.title) // annotation's title
            print(view.annotation!.subtitle) // annotation's subttitle
            
            //Perform a segue here to navigate to another viewcontroller
            // On tapping the disclosure button you will get here
            self.performSegueWithIdentifier("DetailView", sender: self)
            
        }
    }
    
    // Here we add disclosure button inside annotation window
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil
            print("MKAnnotationView nil")
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            //println("Pinview was nil")
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        let button = UIButton(type: UIButtonType.DetailDisclosure) // button with info sign in it
        
        pinView?.rightCalloutAccessoryView = button
        
        return pinView!
    }
 
    // TODO: what's this?
    //@IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    //    print("unwind function")
    //}

}

