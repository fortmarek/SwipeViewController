//
//  ViewController.swift
//  SwipeBetweenViewControllers
//
//  Created by Marek Fořt on 14.03.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import SwipeViewController
import UIKit

class ViewController: SwipeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(push))
        barButtonItem.tintColor = .black
        leftBarButtonItem = barButtonItem
    }

    @objc func push(sender _: UIBarButtonItem) {
        let VC4 = UIViewController()
        VC4.view.backgroundColor = UIColor.purple
        VC4.title = "Cool"
        pushViewController(VC4, animated: true)
    }
}
