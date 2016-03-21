//
//  ViewController.swift
//  SwipeBetweenViewControllers
//
//  Created by Marek Fořt on 14.03.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit
import SwipeViewController

class ViewController: SwipeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let VC1 = UIViewController()
        VC1.view.backgroundColor = UIColor.blueColor()
        VC1.title = "Recent"
        let VC2 = UIViewController()
        VC2.view.backgroundColor = UIColor.greenColor()
        VC2.title = "Random"
        let VC3 = UIViewController()
        VC3.view.backgroundColor = UIColor.blackColor()
        VC3.title = "Recent"
        let VC4 = UIViewController()
        VC4.view.backgroundColor = UIColor.purpleColor()
        VC4.title = "H"
        
        
        setViewControllerArray([VC1, VC2, VC3])
        setSelectionBar(80, height: 3, color: UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0))
        setButtonsWithSelectedColor(UIFont.systemFontOfSize(18), color: UIColor.blackColor(), selectedColor: UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0))
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: nil)
        setNavigationWithItem(UIColor.whiteColor(), leftItem: barButtonItem, rightItem: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func push() {
        let VC4 = UIViewController()
        VC4.view.backgroundColor = UIColor.purpleColor()
        VC4.title = "Cool"
        self.pushViewController(VC4, animated: true)
    }
    
    
    
}
