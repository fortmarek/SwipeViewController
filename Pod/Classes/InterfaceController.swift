//
//  UIController.swift
//  SwipeBetweenViewControllers
//
//  Created by Marek Fořt on 14.03.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import Foundation
import UIKit


protocol SelectionBar {
    var selectionBarHeight: CGFloat { get }
    var selectionBarWidth: CGFloat { get }
    var selectionBarColor: UIColor { get }
    var selectionBar: UIView { get set }
}

enum Side {
    case left, right
}

protocol SwipeButton {
    var offset: CGFloat { get }
    var bottomOfset: CGFloat { get }
    var selectedButtonColor: UIColor { get }
    var buttonColor: UIColor { get }
    var buttonFont: UIFont { get }
    var buttons: Array<UIButton> { get set }
    var pageArray: Array<UIViewController> { get }
    var currentPageIndex: Int { get }
    var spaces: Array<CGFloat> { get set }
    func addFunction(_ button: UIButton)
    var equalSpaces: Bool { get }
    var titleImages: Array<SwipeButtonWithImage> { get }
    var x: CGFloat { get set }
}

protocol BarButtonItem {
    var leftBarButtonItem: UIBarButtonItem? { get }
    var rightBarButtonItem: UIBarButtonItem? { get }
    var barButtonItemWidth: CGFloat { get set }
    func setBarButtonItem(_ side: Side, barButtonItem: UIBarButtonItem)
}

protocol Navigation {
    var navigationBarHeight: CGFloat { get }
    var viewWidth: CGFloat { get }
    var navigationBarColor: UIColor { get }
    var selectionBar: UIView { get set }
}

struct NavigationView {
    
    var delegate: Navigation?
    var barDelegate: SelectionBar?
    var barButtonDelegate: BarButtonItem?
    var swipeButtonDelegate: SwipeButton?
    
    var navigationView = UIView()
    
    mutating func initNavigationView() -> (UIView) {
        
        guard let delegate = delegate else {return UIView()}
        
        //Navigation View
        navigationView.backgroundColor = delegate.navigationBarColor
        navigationView.frame = CGRect(x: 0 , y: 0, width: delegate.viewWidth, height: delegate.navigationBarHeight)
        
        initButtons()
        initSelectionBar()
        initBarButtonItem()
        
        return (navigationView)
    }
    
    
    var selectionBarOriginX = CGFloat(0)
    
    fileprivate func initSelectionBar() {
        
        guard
            var delegate = delegate,
            let barDelegate = barDelegate,
            let buttonDelegate = swipeButtonDelegate
            else {return}
        let selectionBar = UIView()
        
        //SelectionBar
        let originY = navigationView.frame.height - barDelegate.selectionBarHeight - buttonDelegate.bottomOfset
        selectionBar.frame = CGRect(x: selectionBarOriginX , y: originY, width: barDelegate.selectionBarWidth, height: barDelegate.selectionBarHeight)
        selectionBar.backgroundColor = barDelegate.selectionBarColor
        navigationView.addSubview(selectionBar)
        delegate.selectionBar = selectionBar
    }
    
    func initBarButtonItem() {
        
        guard let barButtonDelegate = self.barButtonDelegate else {return}
        
        if let leftBarButtonItem = barButtonDelegate.leftBarButtonItem {
            barButtonDelegate.setBarButtonItem(.left, barButtonItem: leftBarButtonItem)
        }
        
        if let rightBarButtonItem = barButtonDelegate.rightBarButtonItem {
            barButtonDelegate.setBarButtonItem(.right, barButtonItem: rightBarButtonItem)
        }
        
    }
    
    fileprivate mutating func initButtons() {
        guard
            let delegate = delegate,
            let barDelegate = barDelegate,
            var buttonDelegate = swipeButtonDelegate,
            let barButtonDelegate = barButtonDelegate
            else {return}
        
        var buttons = [UIButton]()
        var totalButtonWidth = 0 as CGFloat
        
        //Buttons
        
        var tag = 0
        for page in buttonDelegate.pageArray {
            let button = UIButton()
            
            if buttonDelegate.titleImages.isEmpty {
                setTitleLabel(page, font: buttonDelegate.buttonFont, color: buttonDelegate.buttonColor, button: button)
            }
                
            else {
                //UI of button with image
                
                //Getting buttnWithImage struct from array
                let buttonWithImage = buttonDelegate.titleImages[tag]
                //Normal image
                button.setImage(buttonWithImage.image, for: UIControlState())
                //Selected image
                button.setImage(buttonWithImage.selectedImage, for: .selected)
                //Button tint color
                button.tintColor = buttonDelegate.buttonColor
                
                //Button size
                if let size = buttonWithImage.size {
                    button.frame.size = size
                }
                
            }
            
            //Tag
            tag += 1
            button.tag = tag
            
            totalButtonWidth += button.frame.width
            
            buttons.append(button)
        }
        
        
        var space = CGFloat(0)
        var width = CGFloat(0)
        
        if buttonDelegate.equalSpaces {
            //Space between buttons
            let offset: CGFloat = buttonDelegate.offset
            buttonDelegate.x = (delegate.viewWidth - 2 * offset - totalButtonWidth) / CGFloat(buttons.count + 1)
        }

        else {
            //Space reserved for one button (with label and spaces around it)
            space = (delegate.viewWidth - 2 * buttonDelegate.offset) / CGFloat(buttons.count)
        }

        for button in buttons {

            let buttonHeight = button.frame.height
            let buttonWidth = button.frame.width

            let originY = navigationView.frame.height - barDelegate.selectionBarHeight - buttonDelegate.bottomOfset - buttonHeight - 3
            var originX = CGFloat(0)

            if buttonDelegate.equalSpaces {
                originX = buttonDelegate.x * CGFloat(button.tag) + width + buttonDelegate.offset - barButtonDelegate.barButtonItemWidth
                width += buttonWidth
            }

            else {
                let buttonSpace = space - buttonWidth
                originX = buttonSpace / 2 + width + buttonDelegate.offset - barButtonDelegate.barButtonItemWidth
                width += buttonWidth + space - buttonWidth
                swipeButtonDelegate?.spaces.append(buttonSpace)
            }



            if button.tag == buttonDelegate.currentPageIndex {
                guard let titleLabel = button.titleLabel else {continue}
                selectionBarOriginX = originX - (barDelegate.selectionBarWidth - buttonWidth) / 2
                titleLabel.textColor = buttonDelegate.selectedButtonColor
            }

            button.frame = CGRect(x: originX, y: originY, width: buttonWidth, height: buttonHeight)
            buttonDelegate.addFunction(button)
            navigationView.addSubview(button)
        }
        
        buttonDelegate.buttons = buttons
        
    }
    
    fileprivate func setTitleLabel(_ page: UIViewController, font: UIFont, color: UIColor, button: UIButton) {
        //Title font and color
        guard let pageTitle = page.title else { return }
        let attributes: [NSAttributedStringKey:Any] = [.font:font]
        let attributedTitle = NSAttributedString(string: pageTitle, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: UIControlState())
        
        
        guard let titleLabel = button.titleLabel else {return}
        titleLabel.textColor = color
        
        titleLabel.sizeToFit()
        
        button.frame = titleLabel.frame
    }
    
    fileprivate func setImageButtons(_ button: UIButton, imageName: String, color: UIColor, titleFrame: CGSize) {
        button.setImage(UIImage(named: imageName), for: UIControlState())
        button.frame.size = titleFrame
        button.tintColor = color
    }
}



