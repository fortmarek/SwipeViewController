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
    var selectionBarColor = UIColor.blackColor()
    
    //SwipeButtons
    var offset = CGFloat(40)
    var bottomOfset = CGFloat(0)
    var buttonColor = UIColor.blackColor()
    var selectedButtonColor = UIColor.greenColor()
    var buttonFont = UIFont.systemFontOfSize(18)
    var currentPageIndex = 1 //Besides keeping current page index it also determines what will be the first view
    var spaces = [CGFloat]()
    var x = CGFloat(0)
    var titleImages = [SwipeButtonWithImage]()
    
    //NavigationBar
    var navigationBarColor = UIColor.whiteColor()
    var leftBarButtonItem: UIBarButtonItem?
    var rightBarButtonItem: UIBarButtonItem?
    public var equalSpaces = true
    
    
    //Other values (should not be changed)
    var pageArray = [UIViewController]()
    var buttons = [UIButton]()
    var viewWidth = CGFloat()
    var barButtonItemWidth = CGFloat(8) //Extra offset when there is barButtonItem (and some default, you can check the value by pageController.navigationController?.navigationBar.topItem?.titleView?.layoutMargins.left
    var navigationBarHeight = CGFloat(0)
    var selectionBar = UIView()
    var pageController = UIPageViewController()
    var totalButtonWidth = CGFloat(0)
    var finalPageIndex = -1
    var indexNotIncremented = true
    var pageScrollView = UIScrollView()
    var animationFinished = true
    
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
        guard currentPageIndex >= 1 else {return}
        let initialViewController = pageArray[currentPageIndex - 1]
        pageController.setViewControllers([initialViewController], direction: .Forward, animated: true, completion: nil)
        
        //Select button of initial view controller - change to selected image
        buttons[currentPageIndex - 1].selected = true
        
    }
    
    
    
    //MARK: Public functions
    
    public func setViewControllerArray(viewControllers: [UIViewController]) {
        pageArray = viewControllers
    }
    
    public func addViewController(viewController: UIViewController) {
        pageArray.append(viewController)
    }
    
    public func setFirstViewController(viewControllerIndex: Int) {
        currentPageIndex = viewControllerIndex + 1
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
    
    public func setButtonsWithImages(titleImages: Array<SwipeButtonWithImage>) {
        self.titleImages = titleImages
    }
    
    public func setNavigationColor(color: UIColor) {
        navigationBarColor = color
    }
    
    public func setNavigationWithItem(color: UIColor, leftItem: UIBarButtonItem?, rightItem: UIBarButtonItem?) {
        navigationBarColor = color
        leftBarButtonItem = leftItem
        rightBarButtonItem = rightItem
    }
    
    
    
    
    
    
    // Fix for navigationBarHidden
    override public func viewDidLayoutSubviews() {
        
        if self.view.frame.size.height == UIScreen.mainScreen().bounds.height {
            for childVC in childViewControllers {
                childVC.view.frame = CGRectMake(0, navigationBar.frame.size.height, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - navigationBar.frame.size.height);
            }
        }
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
        //print(xFromCenter)
        let border = viewWidth - 1
        
        
        guard currentPageIndex > 0 && currentPageIndex <= buttons.count else {return}
        
        //Ensuring currentPageIndex is not changed twice
        if -border ... border ~= xFromCenter {
            indexNotIncremented = true
        }
        
        //Resetting finalPageIndex for switching tabs
        if xFromCenter == 0 {
            finalPageIndex = -1
            animationFinished = true
        }
        
        //Going right
        if xFromCenter <= -viewWidth && indexNotIncremented && currentPageIndex < buttons.count {
            view.backgroundColor = pageArray[currentPageIndex].view.backgroundColor
            currentPageIndex += 1
            indexNotIncremented = false
        }
            
            //Going left
        else if xFromCenter >= viewWidth && indexNotIncremented && currentPageIndex >= 2 {
            view.backgroundColor = pageArray[currentPageIndex - 2].view.backgroundColor
            currentPageIndex -= 1
            indexNotIncremented = false
        }
        
        
        if buttonColor != selectedButtonColor {
            changeButtonColor(xFromCenter)
        }
        
        
        for button in buttons {
            
            var originX = CGFloat(0)
            var space = CGFloat(0)
            
            if equalSpaces {
                originX = x * CGFloat(button.tag) + width
                width += button.frame.width
            }
            
            else {
                space = spaces[button.tag - 1]
                originX = space / 2 + width
                width += button.frame.width + space
            }

            let selectionBarOriginX = originX - (selectionBarWidth - button.frame.width) / 2 + offset - barButtonItemWidth
            
            //Get button with current index
            guard button.tag == currentPageIndex
                else {continue}
            
            var nextButton = UIButton()
            var nextSpace = CGFloat()
            
            if xFromCenter < 0 && button.tag < buttons.count {
                nextButton = buttons[button.tag]
                if equalSpaces == false {
                    nextSpace = spaces[button.tag]
                }
            }
            else if xFromCenter > 0 && button.tag != 1 {
                nextButton = buttons[button.tag - 2]
                if equalSpaces == false {
                  nextSpace = spaces[button.tag - 2]
                }
            }
            
            var newRatio = CGFloat(0)
            
            if equalSpaces {
                let expression = 2 * x + button.frame.width - (selectionBarWidth - nextButton.frame.width) / 2
                newRatio = view.frame.width / (expression - (x  - (selectionBarWidth - button.frame.width) / 2))
            }
            
            else {
                newRatio = view.frame.width / (button.frame.width + space / 2 + (selectionBarWidth - button.frame.width) / 2 + nextSpace / 2 - (selectionBarWidth - nextButton.frame.width) / 2)
            }


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
                pageController.setViewControllers([destinationViewController], direction: .Forward, animated: true, completion:nil)
                
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
        guard index != finalPageIndex && index != currentPageIndex - 1 && animationFinished else {return}
        
        animationFinished = false
        finalPageIndex = index
        scrollToNextViewController(index)
    }
    
    func addFunction(button: UIButton) {
        button.addTarget(self, action: #selector(self.switchTabs(_:)), forControlEvents: .TouchUpInside)
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
        
        let viewWidthHalf = viewWidth / 2
        let border = viewWidth - 1
        let halfBorder = viewWidthHalf - 1
        
        //Going left, next button selected
        if viewWidthHalf ... border ~= xFromCenter && currentPageIndex > 1 {
            
            let button = buttons[currentPageIndex - 2]
            let previousButton = buttons[currentPageIndex - 1]
            
            button.titleLabel?.textColor = selectedButtonColor
            previousButton.titleLabel?.textColor = buttonColor
            
            button.selected = true
            previousButton.selected = false
        }
            
            //Going right, current button selected
        else if 0 ... halfBorder ~= xFromCenter && currentPageIndex > 1 {
            
            let button = buttons[currentPageIndex - 1]
            let previousButton = buttons[currentPageIndex - 2]
            
            button.titleLabel?.textColor = selectedButtonColor
            previousButton.titleLabel?.textColor = buttonColor
            
            button.selected = true
            previousButton.selected = false
        }
            
            //Going left, current button selected
        else if -halfBorder ... 0 ~= xFromCenter && currentPageIndex < buttons.count {
            
            let previousButton = buttons[currentPageIndex]
            let button = buttons[currentPageIndex - 1]
            
            button.titleLabel?.textColor = selectedButtonColor
            previousButton.titleLabel?.textColor = buttonColor
            
            button.selected = true
            previousButton.selected = false
        }
            
            //Going right, next button selected
        else if -border ... -viewWidthHalf ~= xFromCenter && currentPageIndex < buttons.count {
            let button = buttons[currentPageIndex]
            let previousButton = buttons[currentPageIndex - 1]
            
            button.titleLabel?.textColor = selectedButtonColor
            previousButton.titleLabel?.textColor = buttonColor
            
            button.selected = true
            previousButton.selected = false
            
            
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


public struct SwipeButtonWithImage {
    var size: CGSize?
    var image: UIImage?
    var selectedImage: UIImage?
    
    public init(image: UIImage?, selectedImage: UIImage?, size: CGSize?) {
        self.image = image
        self.selectedImage = selectedImage
        self.size = size
    }
}


