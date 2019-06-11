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
        setFirstViewController(0)
        setSelectionBar(80, height: 3, color: UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0))
        setButtonsWithSelectedColor(UIFont.systemFont(ofSize: 18), color: UIColor.black, selectedColor: UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0))
        //        equalSpaces = false

        //Button with image example
        //let buttonOne = SwipeButtonWithImage(image: UIImage(named: "Hearts"), selectedImage: UIImage(named: "YellowHearts"), size: CGSize(width: 40, height: 40))
        //setButtonsWithImages([buttonOne, buttonOne, buttonOne])

        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(push))
        setNavigationWithItem(UIColor.white, leftItem: barButtonItem, rightItem: nil)
    }
    
    @objc func push(sender: UIBarButtonItem) {
        let VC4 = UIViewController()
        VC4.view.backgroundColor = UIColor.purple
        VC4.title = "Cool"
        self.pushViewController(VC4, animated: true)
    }
}
