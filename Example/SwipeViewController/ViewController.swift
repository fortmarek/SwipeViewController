//
//  ViewController.swift
//  SwipeViewController
//
//  Created by fortmarek on 03/18/2016.
//  Copyright (c) 2016 fortmarek. All rights reserved.
//

import UIKit
import SwipeViewController

class ViewController: SwipeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let VC1 = UIViewController()
        VC1.view.backgroundColor = UIColor.blueColor()
        VC1.title = "Random"
        let VC2 = UIViewController()
        VC2.view.backgroundColor = UIColor.greenColor()
        VC2.title = "Recent"
        let VC3 = UIViewController()
        VC3.view.backgroundColor = UIColor.blackColor()
        VC3.title = "Popular"
        let VC4 = UIViewController()
        VC4.view.backgroundColor = UIColor.purpleColor()
        VC4.title = "Cool"
        
        setViewControllerArray([VC1, VC2, VC3, VC4])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

