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
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    
    convenience init(hello: String, rootViewController: UIViewController) {
        self.init(rootViewController: rootViewController)
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let VC1 = UIViewController()
        VC1.view.backgroundColor = UIColor(red: 0.19, green: 0.36, blue: 0.60, alpha: 1.0)
        VC1.title = "Recent"
        let VC2 = UIViewController()
        VC2.view.backgroundColor = UIColor(red: 0.70, green: 0.23, blue: 0.92, alpha: 1.0)
        VC2.title = "Favourite"
        let VC3 = UIViewController()
        VC3.view.backgroundColor = UIColor(red: 0.17, green: 0.70, blue: 0.27, alpha: 1.0)
        VC3.title = "Trending"
        
        
        setViewControllerArray([VC1, VC2])
        setFirstViewController(0)
        setSelectionBar(80, height: 3, color: UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0))
        setButtonsWithSelectedColor(UIFont.systemFont(ofSize: 18), color: UIColor.black, selectedColor: UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0))
        equalSpaces = true
        setButtonsOffset(90, bottomOffset: 0)
        
        //Button with image example
        //let buttonOne = SwipeButtonWithImage(image: UIImage(named: "Hearts"), selectedImage: UIImage(named: "YellowHearts"), size: CGSize(width: 40, height: 40))
        //setButtonsWithImages([buttonOne, buttonOne, buttonOne])
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(push))
        setNavigationWithItem(UIColor.white, leftItem: barButtonItem, rightItem: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func push(sender: UIBarButtonItem) {
        let VC4 = UIViewController()
        VC4.view.backgroundColor = UIColor.purple
        VC4.title = "Cool"
        self.pushViewController(VC4, animated: true)
    }
    
    
}
