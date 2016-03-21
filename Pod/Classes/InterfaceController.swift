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
    case Left, Right
}

protocol SwipeButton {
    var offset: CGFloat { get }
    var bottomOfset: CGFloat { get }
    var selectedButtonColor: UIColor { get }
    var buttonColor: UIColor { get }
    var buttonFont: UIFont { get }
    var x: CGFloat { get set }
    var buttons: Array<UIButton> { get set }
    var pageArray: Array<UIViewController> { get }
    var currentPageIndex: Int { get }
    func addFunction(button: UIButton)
}

protocol BarButtonItem {
    var leftBarButtonItem: UIBarButtonItem? { get }
    var rightBarButtonItem: UIBarButtonItem? { get }
    var barButtonItemWidth: CGFloat { get set }
    func setBarButtonItem(side: Side, barButtonItem: UIBarButtonItem)
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
        
        initBarButtonItem()
        initButtons()
        initSelectionBar()
        
        return (navigationView)
    }
    
    
    var selectionBarOriginX = CGFloat(0)
    
    private func initSelectionBar() {
        
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
    
    private func initBarButtonItem() {
        
        guard var barButtonDelegate = barButtonDelegate else {return}
        
        if let leftBarButtonItem = barButtonDelegate.leftBarButtonItem {
            barButtonDelegate.setBarButtonItem(.Left, barButtonItem: leftBarButtonItem)
            if let buttonWidth = leftBarButtonItem.valueForKey("view")?.frame.width {
                barButtonDelegate.barButtonItemWidth += buttonWidth
            }
        }
        
        if let rightBarButtonItem = barButtonDelegate.rightBarButtonItem {
            barButtonDelegate.setBarButtonItem(.Right, barButtonItem: rightBarButtonItem)
        }
        
        
    }
    
    private mutating func initButtons() {
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
            
            //Tag
            tag += 1
            button.tag = tag
            
            //Title font and color
            guard let pageTitle = page.title else { return }
            let attributes = [NSFontAttributeName:buttonDelegate.buttonFont]
            let attributedTitle = NSAttributedString(string: pageTitle, attributes: attributes)
            button.setAttributedTitle(attributedTitle, forState: .Normal)
            
            
            guard let titleLabel = button.titleLabel else {continue}
            titleLabel.textColor = buttonDelegate.buttonColor
            
            
            titleLabel.sizeToFit()
            
            button.frame = titleLabel.frame
            
            
            totalButtonWidth += button.frame.width
            
            buttons.append(button)
        }
        
        //Space between buttons
        buttonDelegate.x = (delegate.viewWidth - 2 * buttonDelegate.offset - totalButtonWidth) / CGFloat(buttons.count + 1)
        var width = 0 as CGFloat
        
        for button in buttons {
            
            let buttonHeight = button.frame.height
            let buttonWidth = button.frame.width
            
            let originY = navigationView.frame.height - barDelegate.selectionBarHeight - buttonDelegate.bottomOfset - 22
            let originX = buttonDelegate.x * CGFloat(button.tag) + width + buttonDelegate.offset - barButtonDelegate.barButtonItemWidth
            
            if button.tag == buttonDelegate.currentPageIndex {
                guard let titleLabel = button.titleLabel else {continue}
                selectionBarOriginX = originX - (barDelegate.selectionBarWidth - buttonWidth) / 2
                titleLabel.textColor = buttonDelegate.selectedButtonColor
            }
            
            
            width += button.frame.width
            
            button.frame = CGRect(x: originX, y: originY, width: buttonWidth, height: buttonHeight)
            
            
            buttonDelegate.addFunction(button)
            navigationView.addSubview(button)
        }
        
        buttonDelegate.buttons = buttons
        
    }
}



