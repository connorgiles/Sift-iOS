//
//  LaunchViewController.swift
//  Sift
//
//  Created by Connor Giles on 2015-03-29.
//  Copyright (c) 2015 Connor Giles. All rights reserved.
//

import UIKit
import pop

class LaunchViewController: UIViewController {
    

    @IBOutlet weak var logo: UIImageView!
    
    override func viewDidAppear(animated: Bool) {
        let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.toValue = 1
        anim.completionBlock = {
            (pop: POPAnimation!, done: Bool) -> Void in
            if done {
                self.performSegueWithIdentifier("launchApp", sender: self)
            }
        }
        
        logo.pop_addAnimation(anim, forKey: "fadeIn")
        
        logo.pop_animationForKey("fadeIn")
        
    }
}
