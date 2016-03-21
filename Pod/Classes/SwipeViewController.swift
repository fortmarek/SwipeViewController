//
//  SwipeViewController.swift
//  SwipeBetweenViewControllers
//
//  Created by Marek Fořt on 11.03.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit


public class SwipeViewController: UINavigationController, UIPageViewControllerDelegate, UIScrollViewDelegate, Navigation, BarButtonItem, SwipeButton, SelectionBar {
    
    //Values to change, either here or in your subclass of PageViewController
    
    
    //SelectionBar
    var selectionBarHeight = CGFloat(0)
    var selectionBarWidth = CGFloat(0)
    var selectionBarColor = UIColor()
    
    //SwipeButtons
    var offset = CGFloat(40)
    var bottomOfset = CGFloat(0)
    var buttonColor = UIColor.whiteColor()
    var selectedButtonColor = UIColor.orangeColor()
    var buttonFont = UIFont.systemFontOfSize(18)
    var currentPageIndex = 2 //Besides keeping current page index it also determines what will be the first view
    
    //NavigationBar
    var navigationBarColor = UIColor.whiteColor()
    var leftBarButtonItem: UIBarButtonItem?
    var rightBarButtonItem: UIBarButtonItem?
    
    
    //Other values (should not be changed)
    var pageArray = [UIViewController]()
    var buttons = [UIButton]()
    var viewWidth = CGFloat()
    var x = 0 as CGFloat //Distance between elements
    var barButtonItemWidth = CGFloat(8) //Extra offset when there is barButtonItem (and some default, you can check the value by pageController.navigationController?.navigationBar.topItem?.titleView?.layoutMargins.left
    var navigationBarHeight = 0 as CGFloat
    var selectionBar = UIView()
    var pageController = UIPageViewController()
    var totalButtonWidth = CGFloat(0)
    var finalPageIndex = -1
    var indexNotIncremented = true
    var pageScrollView = UIScrollView()
    
    var selectionBarDelegate: SelectionBar?
    
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override public func viewWillAppear(animated: Bool) {
        
        navigationBar.barTintColor = navigationBarColor
        navigationBar.translucent = false
        
        setPageController()
        
        
        //Interface init
        var interfaceController = NavigationView()
        
        interfaceController.delegate = self
        interfaceController.barDelegate = self
        interfaceController.barButtonDelegate = self
        interfaceController.swipeButtonDelegate = self
        
        //Navigation View
        let navigationView = interfaceController.initNavigationView()
        pageController.navigationController?.navigationBar.topItem?.titleView = navigationView
        
        syncScrollView()
        
        //Init of initial view controller
        guard currentPageIndex > 1 else {return}
        let initialViewController = pageArray[currentPageIndex - 1]
        pageController.setViewControllers([initialViewController], direction: .Forward, animated: true, completion: nil)
        
    }
    
    
    
    //MARK: Public functions
    
    public func setViewControllerArray(viewControllers: [UIViewController]) {
        pageArray = viewControllers
    }
    
    public func addViewController(viewController: UIViewController) {
        pageArray.append(viewController)
    }
    
    public func setSelectionBar(width: CGFloat, height: CGFloat, color: UIColor) {
        selectionBarWidth = width
        selectionBarHeight = height
        selectionBarColor = color
    }
    
    public func setButtons(font: UIFont, color: UIColor) {
        buttonFont = font
        buttonColor = color
        //When the colors are the same there is no change
        selectedButtonColor = color
    }
    
    public func setButtonsWithSelectedColor(font: UIFont, color: UIColor, selectedColor: UIColor) {
        buttonFont = font
        buttonColor = color
        selectedButtonColor = selectedColor
    }
    
    public func setButtonsOffset(offset: CGFloat, bottomOffset: CGFloat) {
        self.offset = offset
        self.bottomOfset = bottomOffset
    }
    
    public func setNavigationColor(color: UIColor) {
        navigationBarColor = color
    }
    
    public func setNavigationWithItem(color: UIColor, leftItem: UIBarButtonItem?, rightItem: UIBarButtonItem?) {
        navigationBarColor = color
        leftBarButtonItem = leftItem
        rightBarButtonItem = rightItem
    }
    
    
    
    
    func syncScrollView() {
        for view in pageController.view.subviews {
            if view.isKindOfClass(UIScrollView) {
                pageScrollView = view as! UIScrollView
                pageScrollView.delegate = self
            }
        }
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        let xFromCenter = view.frame.size.width - scrollView.contentOffset.x
        var width = 0 as CGFloat
        
        
        guard currentPageIndex > 0 && currentPageIndex <= buttons.count else {return}
        
        //Ensuring currentPageIndex is not changed twice
        if -374 ... 374 ~= xFromCenter {
            indexNotIncremented = true
        }
        
        //Resetting finalPageIndex for switching tabs
        if xFromCenter == 0 {
            finalPageIndex = -1
        }
        
        //Going right
        if xFromCenter <= -375 && indexNotIncremented {
            view.backgroundColor = pageArray[currentPageIndex].view.backgroundColor
            currentPageIndex += 1
            indexNotIncremented = false
        }
            
            //Going left
        else if xFromCenter >= 375 && indexNotIncremented {
            view.backgroundColor = pageArray[currentPageIndex - 2].view.backgroundColor
            currentPageIndex -= 1
            indexNotIncremented = false
        }
        
        if buttonColor != selectedButtonColor {
            changeButtonColor(xFromCenter)
        }
        
        
        for button in buttons {
            
            //Calculate position for selectionBar
            let originX = x * CGFloat(button.tag) + width
            width += button.frame.width
            
            
            let selectionBarOriginX = originX - (selectionBarWidth - button.frame.width) / 2 + offset - barButtonItemWidth
            
            //Get button with current index
            guard button.tag == currentPageIndex
                else {continue}
            
            var nextButton = UIButton()
            
            if xFromCenter < 0 && button.tag < buttons.count {
                nextButton = buttons[button.tag]
            }
            else if xFromCenter > 0 && button.tag != 1 {
                nextButton = buttons[button.tag - 2]
            }
            
            let newRatio = (view.frame.width) / (2 * x + button.frame.width - (selectionBarWidth - nextButton.frame.width) / 2 - (x  - (selectionBarWidth - button.frame.width) / 2))
            
            selectionBar.frame = CGRect(x: selectionBarOriginX - (xFromCenter/newRatio), y: selectionBar.frame.origin.y, width: selectionBarWidth, height: selectionBarHeight)
            return
            
        }
        
    }
    
    
    
    
    
    //Triggered when selected button in navigation view is changed
    func scrollToNextViewController(index: Int) {
        
        let currentViewControllerIndex = currentPageIndex - 1
        
        //Comparing index (i.e. tab where user is going to) and when compared, we can now know what direction we should go
        //Index is on the right
        if index > currentViewControllerIndex {
            
            //loop - if user goes from tab 1 to tab 3 we want to have tab 2 in animation
            for viewControllerIndex in currentViewControllerIndex...index {
                
                let destinationViewController = pageArray[viewControllerIndex]
                pageController.setViewControllers([destinationViewController], direction: .Forward, animated: true, completion: nil)
            }
        }
            //Index is on the left
        else {
            for viewControllerIndex in (index...currentViewControllerIndex).reverse() {
                let destinationViewController = pageArray[viewControllerIndex]
                pageController.setViewControllers([destinationViewController], direction: .Reverse, animated: true, completion: nil)
                
            }
        }
        
    }
    
    func switchTabs(sender: UIButton) {
        
        let index = sender.tag - 1
        
        //Can't animate twice to the same controller (otherwise weird stuff happens)
        guard index != finalPageIndex else {return}
        
        finalPageIndex = index
        scrollToNextViewController(index)
    }
    
    func addFunction(button: UIButton) {
        button.addTarget(self, action: "switchTabs:", forControlEvents: .TouchUpInside)
    }
    
    func setBarButtonItem(side: Side, barButtonItem: UIBarButtonItem) {
        if side == .Left {
            pageController.navigationItem.leftBarButtonItem = barButtonItem
        }
        else {
            pageController.navigationItem.rightBarButtonItem = barButtonItem
        }
    }
    
    func setPageController() {
        
        guard (self.topViewController as? UIPageViewController) != nil else {return}
        
        pageController = self.topViewController as! UIPageViewController
        pageController.delegate = self
        pageController.dataSource = self
        
        viewWidth = view.frame.width
        navigationBarHeight = navigationBar.frame.height
    }
    
    func changeButtonColor(xFromCenter: CGFloat) {
        //Change color of button before animation finished (i.e. colour changes even when the user is between buttons
        
        //Going left, next button selected
        if 180 ... 374 ~= xFromCenter && currentPageIndex > 1 {
            guard
                let title = buttons[currentPageIndex - 2].titleLabel,
                let previousTitle = buttons[currentPageIndex - 1].titleLabel else {return}
            title.textColor = selectedButtonColor
            previousTitle.textColor = buttonColor
        }
            
            //Going right, current button selected
        else if 0 ... 179 ~= xFromCenter && currentPageIndex > 1 {
            guard
                let title = buttons[currentPageIndex - 2].titleLabel,
                let previousTitle = buttons[currentPageIndex - 1].titleLabel else {return}
            title.textColor = buttonColor
            previousTitle.textColor = selectedButtonColor
        }
            
            //Going left, current button selected
        else if -179 ... 0 ~= xFromCenter && currentPageIndex < buttons.count {
            guard
                let title = buttons[currentPageIndex].titleLabel,
                let previousTitle = buttons[currentPageIndex - 1].titleLabel else {return}
            title.textColor = buttonColor
            previousTitle.textColor = selectedButtonColor
        }
            
            //Going right, next button selected
        else if -374 ... -180 ~= xFromCenter && currentPageIndex < buttons.count {
            guard
                let title = buttons[currentPageIndex].titleLabel,
                let previousTitle = buttons[currentPageIndex - 1].titleLabel else {return}
            title.textColor = selectedButtonColor
            previousTitle.textColor = buttonColor
            
        }
    }
    
    
}

extension SwipeViewController: UIPageViewControllerDataSource {
    //Swiping left
    public func pageViewController(pageViewController: UIPageViewController,
                                   viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        //Get current view controller index
        guard let viewControllerIndex = pageArray.indexOf(viewController) else {return nil}
        
        let previousIndex = viewControllerIndex - 1
        
        //Making sure the index doesn't get bigger than the array of view controllers
        guard previousIndex >= 0 && pageArray.count > previousIndex else {return nil}
        
        return pageArray[previousIndex]
    }
    
    //Swiping right
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        //Get current view controller index
        guard let viewControllerIndex = pageArray.indexOf(viewController) else {return nil}
        
        let nextIndex = viewControllerIndex + 1
        
        //Making sure the index doesn't get bigger than the array of view controllers
        guard pageArray.count > nextIndex else {return nil}
        
        
        return pageArray[nextIndex]
    }
}





