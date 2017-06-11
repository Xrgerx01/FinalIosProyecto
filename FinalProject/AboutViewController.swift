//
//  AboutViewController.swift
//  City Tour
//
//  Created by ROGER A. CHIROQUE RAMIREZ on 23/03/17.
//  Copyright © 2017 ROGER A. CHIROQUE RAMIREZ All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openLinkedIn(_ sender: AnyObject) {
        
        if let openLink = URL(string: "https://co.linkedin.com/in/roger-chiroque-07909248") {
            
            UIApplication.shared.openURL(openLink)
        }
        
    }
    
    
    
    @IBAction func openFacebook(_ sender: AnyObject) {
        
        let openLink = URL(string: "https://www.facebook.com/roger.a.chiroqueramirez")
        UIApplication.shared.openURL(openLink!)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
