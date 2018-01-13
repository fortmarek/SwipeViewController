//
//  TestViewController.swift
//  SwipeViewController_Example
//
//  Created by Marek Fořt on 1/13/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.setTitle("Button", for: .normal)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    @objc private func buttonTapped() {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        navigationController?.pushViewController(viewController, animated: true)
    }
}
