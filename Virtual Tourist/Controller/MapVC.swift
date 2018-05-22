//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by sudo on 3/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import MapKit
import CoreLocation
import Foundation
var selectedAnnotation: MKPointAnnotation?

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 7000
    var pin: [Pin] = []
    var dataController:DataController!

    @IBOutlet weak var instructionText: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedAnnotation:MKAnnotation?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
//            DestroysCoreDataMaintence(result)
            pin = result
//            pin.removeAll(keepingCapacity: false)
//            pin.removeAll()
            for object in pin {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: object.lat , longitude: object.long)
                mapView.addAnnotation(annotation)
            }
            print(pin)
               mapView.reloadInputViews()
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem?.title = "Edit"
    }
    
    
    
    func addDoubleTap() {
        
        //Long gesture will drop the pin
        let doubleTap = UILongPressGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
//                doubleTap.numberOfTapsRequired = 0
        doubleTap.minimumPressDuration = 0.5
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
    }
    func savedPin (lat: Double, long: Double) {

        let pin = Pin(context: dataController.viewContext)
        pin.lat = lat
        pin.long = long
        pin.creationDate = Date()
        try? dataController.viewContext.save()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(mapView.selectedAnnotations)
        print(pin.count)
//        performSegue(withIdentifier: "toPhoto", sender: hello)
    }

    


    //Maintence File
    fileprivate func DestroysCoreDataMaintence(_ result: [Pin]) {
        for object in result {
            dataController.viewContext.delete(object)
        }
    }
}
extension MapVC: MKMapViewDelegate{
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    @objc func dropPin(sender: UITapGestureRecognizer) {
        //Drop pin on the map
        let annotation = MKPointAnnotation()
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print("This is the map gps coordinate\(touchCoordinate)")
        annotation.coordinate = CLLocationCoordinate2D(latitude: touchCoordinate.latitude , longitude: touchCoordinate.longitude)
        mapView.addAnnotation(annotation)
        //This will save the pin in coreData
        let lat = Double(touchCoordinate.latitude)
        let long = Double(touchCoordinate.longitude)
        savedPin(lat: lat, long: long)
    }
}
extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        centerMapOnUserLocation()
    }
}
