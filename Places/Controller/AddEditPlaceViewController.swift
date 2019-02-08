//
//  AddEditPlaceViewController.swift
//  Places
//
//  Created by Wojciech Karaś on 01/02/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit
import MapKit

protocol AddEditPlaceViewControllerDelegate: class {
    func addEditPlaceViewController(_ controller: AddEditPlaceViewController, didFinishAdding place: Place)
    func addEditPlaceViewController(_ controller: AddEditPlaceViewController, didFinishEditing place: Place, with newPlace: Place)
}

class AddEditPlaceViewController: UIViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var placeDescriptionTextField: UITextField!
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var townLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    
    weak var delegate: AddEditPlaceViewControllerDelegate?
    var selectedPlace: Place?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if let selectedPlace = selectedPlace {
            
            navigationItem.title = selectedPlace.name
            nameTextField.text = selectedPlace.name
            placeDescriptionTextField.text = selectedPlace.placeDescription
            
            let latitude = CLLocationDegrees(selectedPlace.latitude)
            let longitude = CLLocationDegrees(selectedPlace.longitude)
            setAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            setMapTo(latitude: latitude, longitude: longitude)
            
        } else {
            navigationItem.title = "Add Place"
            locationManager.startUpdatingLocation()
        }
        
        nameTextField.delegate = self
        nameTextField.becomeFirstResponder()
        
        placeDescriptionTextField.delegate = self
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        if let selectedPlace = selectedPlace {
            let place = Place()
            setPlace(place)
            delegate?.addEditPlaceViewController(self, didFinishEditing: selectedPlace, with: place)
        } else {
            let place = Place()
            setPlace(place)
            delegate?.addEditPlaceViewController(self, didFinishAdding: place)
        }
    }
    
    @objc private func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .ended {
            let touchPoint = longPressGestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            setAnnotation(coordinate: coordinate)
            if let text = nameTextField.text, !text.isEmpty {
                doneButton.isEnabled = true
            }
        }
    }
    
    private func setMapTo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func setAnnotation(coordinate: CLLocationCoordinate2D) {
        if let annotation = mapView.annotations.first {
            mapView.removeAnnotation(annotation)
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = nameTextField.text
        annotation.subtitle = placeDescriptionTextField.text
        mapView.addAnnotation(annotation)
        setInfo(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    private func setPlace(_ place: Place) {
        if let annotation = mapView.annotations.first {
            place.latitude = Float(annotation.coordinate.latitude)
            place.longitude = Float(annotation.coordinate.longitude)
        }
        place.name = nameTextField.text
        place.placeDescription = placeDescriptionTextField.text
    }
    
    private func setInfo(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) {
            placemarks, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let placemark = placemarks?.first {
                self.countryLabel.text = placemark.country
                self.townLabel.text = placemark.locality
                self.streetLabel.text = (placemark.thoroughfare ?? "") + " " + (placemark.subThoroughfare ?? "")
            }
        }
    }
}

//MARK: - TextField Methods
extension AddEditPlaceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === nameTextField {
            if let oldName = textField.text {
                if let stringRange = Range(range, in: oldName) {
                    let newName = oldName.replacingCharacters(in: stringRange, with: string)
                    doneButton.isEnabled = !newName.isEmpty && mapView.annotations.first != nil
                }
            }
        } else if textField == placeDescriptionTextField {
            if let text = nameTextField.text, !text.isEmpty, let _ = mapView.annotations.first {
                doneButton.isEnabled = true
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let annotation = mapView.annotations.first {
            setAnnotation(coordinate: annotation.coordinate)
        }
    }
}

//MARK: - LocationManager Methods
extension AddEditPlaceViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last, location.horizontalAccuracy > 0 {
            manager.stopUpdatingLocation()
            manager.delegate = nil
            setMapTo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
