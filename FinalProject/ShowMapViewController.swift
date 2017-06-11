//
//  ShowMapViewController.swift
//  FinalProject
//
//  Created by Roger A. Chiroque on 3/20/17.
//  Copyright © 2017 Roger Chiroque. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ShowMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, ARDataSource {
    var route: Route? = nil
    
    fileprivate var overlays: [MKOverlay] = [MKOverlay]()
    fileprivate let locationManager = CLLocationManager()
    fileprivate var pointDistance: Double = 0.0
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        mapView.removeOverlays(overlays)
        overlays.removeAll()
        mapView.showsUserLocation = false
        locationManager.delegate = self
        
        doLayout()
        
        let coords = convertIntoKeyValuePair()
        var prevLocation: CLLocation? = nil
        
        for (name,c) in coords {
            let currentLocation = CLLocation(latitude: (c.first?.key)!, longitude: (c.first?.value)!)
            let locationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (c.first?.key)!, longitude: (c.first?.value)!), addressDictionary: nil)
            let locationMapItem = MKMapItem(placemark: locationPlacemark)
            if let prev = prevLocation {
                pointDistance += currentLocation.distance(from: prev)
                if pointDistance > 0 {
                    let prevPlacemark = MKPlacemark(coordinate: prev.coordinate, addressDictionary: nil)
                    let prevMapItem = MKMapItem(placemark: prevPlacemark)
                    
                    presentRoute(prevMapItem, destination: locationMapItem)
                    pointDistance = 0
                }
            }
            prevLocation = currentLocation
            let region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
            setPin(name, subtitle: "", latitude: (c.first?.key)!, longitude: (c.first?.value)!)
        }
        setImagePin(route!.name!, subtitle: route!.descript!, image: route!.image as Data?,latitude: (prevLocation?.coordinate.latitude)!, longitude: (prevLocation?.coordinate.longitude)!)
        //setPin(route!.name!, subtitle: route!.descript!, latitude: (prevLocation?.coordinate.latitude)!, longitude: (prevLocation?.coordinate.longitude)!)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        print(route!.name!)
        
        var url = "https://maps.google.com/maps?q="

        let coords = convertIntoKeyValuePair()
        for (_,c) in coords {
            url += "\(c.first!.key)" + "," + "\(c.first!.value)"
            url += "&ll=" + "\(c.first!.key)" + "," + "\(c.first!.value)"
            url += "&spn=0.005&t=k"
            break
        }
        print(url)
        let data: [Any] = [route!.name!, URL(string: url)!]
        let activity = UIActivityViewController(activityItems: data, applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }
    
    @IBAction func startAR(_ sender: Any) {
        let delta = 0.005
        let location: CLLocation = CLLocationManager().location!
        let locations = convertIntoKeyValuePair()
        
        
        let dummyAnnotations = obtenAnotaciones(locations: locations, latitud: location.coordinate.latitude, longitud: location.coordinate.longitude, delta: delta, numeroDeElementos: locations.count)
        
        let arViewController = ARViewController()
        arViewController.dataSource = self
        arViewController.maxDistance = 0
        arViewController.maxVisibleAnnotations = 100
        arViewController.maxVerticalLevel = 5
        arViewController.headingSmoothingFactor = 0.05
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        arViewController.setAnnotations(dummyAnnotations)
        arViewController.uiOptions.debugEnabled = true
        arViewController.uiOptions.closeButtonEnabled = true
        //arViewController.interfaceOrientationMask = .landscape
        arViewController.onDidFailToFindLocation = {
            [weak self, weak arViewController] elapsedSeconds, acquiredLocationBefore in
            // Show alert and dismiss
        }
        self.present(arViewController, animated: true, completion: nil)
    }
    
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let view = TestAnnotationView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.frame = CGRect(x: 0, y: 0, width: 150, height: 60)
        return view
    }
    
    private func obtenAnotaciones( locations: [String:[Double:Double]], latitud: Double, longitud: Double, delta: Double, numeroDeElementos: Int) -> Array<ARAnnotation>{
        
        var anotaciones: [ARAnnotation] = []
        
        for (name,coords) in locations
        {
            let anotacion = ARAnnotation()
            anotacion.location = self.obtenerPosiciones(latitud: (coords.first?.key)!, longitud: (coords.first?.value)!, delta: delta)
            anotacion.title = name
            anotaciones.append(anotacion)
        }
        return anotaciones
        
    }
    
    private func obtenerPosiciones( latitud: Double, longitud: Double, delta: Double )-> CLLocation{
        var lat = latitud
        var lon = longitud
        let latDelta = -(delta/2) + drand48() * delta
        let lonDelta = -(delta/2) + drand48() * delta
        lat = lat + latDelta
        lon = lon + lonDelta
        return CLLocation(latitude: lat, longitude: lon)
    }

    
    func convertIntoKeyValuePair() -> [String:[Double:Double]] {
        var coords: [String:[Double: Double]] = [:]
        let points:[String] = (route?.locationPoints?.components(separatedBy: "|"))!
        
        for point in points {
            if point.contains(":"){
                let latLog = point.components(separatedBy: ":")
                
                var c: [Double: Double] = [:]
                if latLog.count == 3 {
                    c.updateValue(Double(latLog[2])!, forKey: Double(latLog[1])!)
                    coords.updateValue(c, forKey: String(latLog[0])!)
                }
            }
        }
        return coords
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        overlays.append(overlay)
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {  //Handle user location annotation..
            return nil  //Default is to let the system handle it.
        }
        
        if !annotation.isKind(of: ImageAnnotation.self) {  //Handle non-ImageAnnotations..
            var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
                pinAnnotationView?.canShowCallout = true
                pinAnnotationView?.rightCalloutAccessoryView =  UIButton(type: .infoDark)  as UIButton
            }
            return pinAnnotationView
        }
        
        func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
                     calloutAccessoryControlTapped control: UIControl!) {
            
            if control == view.rightCalloutAccessoryView {
                print("Disclosure Pressed! \(view.annotation?.subtitle)")
            }
            
        }
        
        //Handle ImageAnnotations..
        var view: ImageAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? ImageAnnotationView
        if view == nil {
            view = ImageAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
        }
        
        let annotation = annotation as! ImageAnnotation
        view?.image = annotation.image
        view?.annotation = annotation
        
        return view
    }
    
    func setImagePin(_ title: String, subtitle: String, image: Data?, latitude: Double, longitude: Double) {
        let annotation = ImageAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        
        if let i = image {
            annotation.image = UIImage(data: i, scale: UIScreen.main.scale)
        }
        annotation.title = title
        annotation.subtitle = subtitle
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func setPin(_ title: String, subtitle: String, latitude: Double, longitude: Double) {
        let pin = MKPointAnnotation()
        pin.title = title
        pin.subtitle = subtitle
        pin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(pin)
        }
    }
    
    func presentRoute(_ origin: MKMapItem, destination: MKMapItem) {
        let request = MKDirectionsRequest()
        request.source = origin
        request.destination = destination
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: {
            response, error in
            if error != nil {
                print(error!)
            } else {
                self.showRoute(response!, origin: origin)
            }
        })
    }
    
    func showRoute(_ response: MKDirectionsResponse, origin: MKMapItem) {
        for route in response.routes {
            DispatchQueue.main.async {
                self.mapView.add(route.polyline, level: .aboveLabels)
            }
        }
    }

    func doLayout() {
        self.view.addSubview(self.mapView)
        self.mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
    }
}
