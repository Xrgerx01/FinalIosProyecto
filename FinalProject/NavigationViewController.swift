//
//  NavigationViewController.swift
//  FinalProject
//
//  Created by Roger Chiroque on 11/07/16.
//  Copyright © 2016 Roger Chiroque. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier != "routeSegue" && segue.identifier != "qrSegue" {
            let origin = sender as! QRViewController
            let vc = segue.destination as! WebViewController
            origin.session?.stopRunning()
            vc.urls = origin.urls
        }
    }
}
