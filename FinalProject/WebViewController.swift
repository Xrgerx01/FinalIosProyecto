//
//  WebViewController.swift
//  FinalProject
//
//  Created by Roger Chiroque on 17/07/16.
//  Copyright © 2016 Roger Chiroque. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    var urls: String?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let curl = URL(string: urls!)
        let request = URLRequest(url: curl!)
        webView.loadRequest(request)
    }
}
