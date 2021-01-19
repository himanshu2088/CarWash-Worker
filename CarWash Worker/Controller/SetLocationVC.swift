//
//  SetLocationVC.swift
//  CarWash Worker
//
//  Created by Himanshu Joshi on 11/01/21.
//

import UIKit
import CoreLocation
import MapKit
import Firebase

class SetLocationVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var oldAnnotation: MKPointAnnotation!
    var newAnnotation: MKPointAnnotation!
    var annotationValue = 0
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmBtn.layer.cornerRadius = 15.0
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
    }
    
    @objc func longTap(gestureRecognizer: UIGestureRecognizer) {
        confirmBtn.isHidden = false
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        if annotationValue == 0 {
            oldAnnotation = annotation
            newAnnotation = annotation
            annotationValue = 1
        } else {
            oldAnnotation = newAnnotation
            newAnnotation = annotation
            removeAnnotation(annotation: oldAnnotation)
        }
        
    }
    
    @IBAction func confirmBtnPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Confirm Location", message: "Are your sure want to confirm this location?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { [self] (action) in
            Firestore.firestore().collection("workers").document((Auth.auth().currentUser?.uid)!).updateData(["location" : "\(newAnnotation.coordinate)"]) { (error) in
                if let error = error {
                    print("Error while updating location, \(error.localizedDescription)")
                }
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController2") as! HomeViewController2
                navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    func removeAnnotation(annotation: MKPointAnnotation) {
        mapView.removeAnnotation(annotation)
    }
    
    //Location Manager Methods
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
        }
    }
    
}
