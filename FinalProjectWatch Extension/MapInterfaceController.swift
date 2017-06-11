//
//  MapInterfaceController.swift
//  FinalProject
//
//  Created by Roger A. Chiroque on 3/27/17.
//  Copyright © 2017 Roger Chiroque. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class MapInterfaceController: WKInterfaceController, WCSessionDelegate {
    var session: WCSession? = nil
    var route = ""
    
    @IBOutlet var mapView: WKInterfaceMap!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() && session == nil {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
        
        self.route = context as! String
        print(route)
        // Configure interface objects here.
    }

    override func didAppear() {
        if (session!.isReachable) {
            print("is reachable")
            getRoute(session: self.session!)
        } else {
            print("is not reachable")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let e = error {
            print(e)
        } else {
            print("WatchKit: Active watch session")
            getRoute(session: self.session!)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
    }
    
    func getRoute(session: WCSession) {
        session.sendMessage(["getRoute": self.route], replyHandler:
            {(reply: [String: Any]) -> Void in
                if reply["route"] != nil {
                    self.setMap(data: reply["route"] as! [String : String])
                }
        }, errorHandler: {
            (error: Error) -> Void in
            print(error)
        })
    }

    func setMap(data: [String: String]) {
        var points: [String:[Double:Double]]?
        
        for (id, info) in data {
            switch id {
            case "points":
                points = convertIntoKeyValuePair(points: info)
            default:
                print("nothing")
            }
        }
        
        let lastPoint = points?.keys.sorted().last.map({ ($0, points?[$0]!) })
        let location = CLLocationCoordinate2D(latitude: (lastPoint?.1?.first?.key)!, longitude: (lastPoint?.1?.first?.value)!)
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        self.mapView.setRegion(region)
        
        for (_, point) in points! {
            for c in point {
                self.mapView.addAnnotation(CLLocationCoordinate2D(latitude: (c.key), longitude: (c.value)), with: .red)
            }
        }
    }
    
    func convertIntoKeyValuePair(points: String) -> [String:[Double:Double]] {
        var coords: [String:[Double: Double]] = [:]
        let points:[String] = (points.components(separatedBy: "|"))
        
        for point in points {
            if point.contains(":"){
                let latLog = point.components(separatedBy: ":")
                
                var c: [Double: Double] = [:]
                c.updateValue(Double(latLog[2])!, forKey: Double(latLog[1])!)
                
                coords.updateValue(c, forKey: String(latLog[0])!)
            }
        }
        return coords
    }
    
}
