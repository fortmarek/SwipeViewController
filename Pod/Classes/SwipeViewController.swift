//
//  SwipeViewController.swift
//  SwipeBetweenViewControllers
//
//  Created by Marek Fořt on 11.03.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit


open class SwipeViewController: UINavigationController, UIPageViewControllerDelegate, UIScrollViewDelegate, Navigation, BarButtonItem, SwipeButton, SelectionBar {
    
    //Values to change, either here or in your subclass of PageViewController
    
    //SelectionBar
    var selectionBarHeight = CGFloat(0)
    var selectionBarWidth = CGFloat(0)
    var selectionBarColor = UIColor.black
    
    //SwipeButtons
    var offset = CGFloat(40)
    var bottomOfset = CGFloat(0)
    var buttonColor = UIColor.black
    var selectedButtonColor = UIColor.green
    var buttonFont = UIFont.systemFont(ofSize: 18)
    open var currentPageIndex = 1 //Besides keeping current page index it also determines what will be the first view
    var spaces = [CGFloat]()
    var x = CGFloat(0)
    var titleImages = [SwipeButtonWithImage]()
    
    //NavigationBar
    var navigationBarColor = UIColor.white
    var leftBarButtonItem: UIBarButtonItem?
    var rightBarButtonItem: UIBarButtonItem?
    open var equalSpaces = true
    
    
    //Other values (should not be changed)
    var pageArray = [UIViewController]()
    var buttons = [UIButton]()
    var viewWidth = CGFloat()
    var barButtonItemWidth: CGFloat = 0
    var navigationBarHeight = CGFloat(0)
    var selectionBar = UIView()
    var pageController = UIPageViewController()
    var totalButtonWidth = CGFloat(0)
    var finalPageIndex = -1
    var indexNotIncremented = true
    var pageScrollView = UIScrollView()
    var animationFinished = true
    var navView: NavigationView = NavigationView()
    var valueToSubtract: CGFloat = 0
    
    var selectionBarDelegate: SelectionBar?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        barButtonItemWidth = pageController.navigationController?.navigationBar.topItem?.titleView?.layoutMargins.left ?? 0
    }
    
    open func setSwipeViewController() {
        navigationBar.barTintColor = navigationBarColor
        navigationBar.isTranslucent = false
        
        setPageController()
        
        //Interface init
        var interfaceController = NavigationView()
        interfaceController.delegate = self
        interfaceController.barDelegate = self
        interfaceController.barButtonDelegate = self
        interfaceController.swipeButtonDelegate = self
        
        navView = interfaceController
        
        pageController.navigationController?.navigationBar.topItem?.titleView = UIView()
        barButtonItemWidth = pageController.navigationController?.navigationBar.topItem?.titleView?.layoutMargins.left ?? 0
        
        let navigationView = interfaceController.initNavigationView()
        pageController.navigationController?.navigationBar.topItem?.titleView = navigationView
        
        
        
        syncScrollView()
        
        //Init of initial view controller
        guard currentPageIndex >= 1 else {return}
        let initialViewController = pageArray[currentPageIndex - 1]
        pageController.setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
        
        //Select button of initial view controller - change to selected image
        buttons[currentPageIndex - 1].isSelected = true
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        setSwipeViewController()
    }
    
    
    //MARK: Public functions
    
    open func setViewControllerArray(_ viewControllers: [UIViewController]) {
        pageArray = viewControllers
        view.backgroundColor = pageArray[currentPageIndex - 1].view.backgroundColor
    }
    
    open func addViewController(_ viewController: UIViewController) {
        pageArray.append(viewController)
        view.backgroundColor = pageArray[currentPageIndex - 1].view.backgroundColor
    }
    
    open func setFirstViewController(_ viewControllerIndex: Int) {
        currentPageIndex = viewControllerIndex + 1
        view.backgroundColor = pageArray[viewControllerIndex].view.backgroundColor
    }
    
    open func setSelectionBar(_ width: CGFloat, height: CGFloat, color: UIColor) {
        selectionBarWidth = width
        selectionBarHeight = height
        selectionBarColor = color
    }
    
    open func setButtons(_ font: UIFont, color: UIColor) {
        buttonFont = font
        buttonColor = color
        //When the colors are the same there is no change
        selectedButtonColor = color
    }
    
    open func setButtonsWithSelectedColor(_ font: UIFont, color: UIColor, selectedColor: UIColor) {
        buttonFont = font
        buttonColor = color
        selectedButtonColor = selectedColor
    }
    
    open func setButtonsOffset(_ offset: CGFloat, bottomOffset: CGFloat) {
        self.offset = offset
        self.bottomOfset = bottomOffset
    }
    
    open func setButtonsWithImages(_ titleImages: Array<SwipeButtonWithImage>) {
        self.titleImages = titleImages
    }
    
    open func setNavigationColor(_ color: UIColor) {
        navigationBarColor = color
    }
    
    open func setNavigationWithItem(_ color: UIColor, leftItem: UIBarButtonItem?, rightItem: UIBarButtonItem?) {
        navigationBarColor = color
        leftBarButtonItem = leftItem
        rightBarButtonItem = rightItem
    }
    
    
    func setBarButtonItem(_ side: Side, barButtonItem: UIBarButtonItem) {
        if side == .left {
            pageController.navigationItem.leftBarButtonItem = barButtonItem
            getValueToSubtract()
            navView.swipeButtonDelegate?.buttons.forEach {$0.frame.origin.x -= valueToSubtract}
            navView.delegate?.selectionBar.frame.origin.x -= valueToSubtract
        }
        else {
            pageController.navigationItem.rightBarButtonItem = barButtonItem
        }
        
    }
    
    private func getValueToSubtract() {
        guard let firstButton = navView.swipeButtonDelegate?.buttons.first else {return}
        let convertedXOrigin = firstButton.convert(firstButton.frame.origin, to: view).x
        let barButtonWidth: CGFloat = equalSpaces ? 0 : barButtonItemWidth
        let valueToSubtract: CGFloat = (convertedXOrigin - offset + barButtonWidth) / 2 - (navView.swipeButtonDelegate?.x ?? 0) / 2
        self.valueToSubtract = valueToSubtract
    }
    
    
    
    
    func syncScrollView() {
        for view in pageController.view.subviews {
            if view.isKind(of: UIScrollView.self) {
                pageScrollView = view as! UIScrollView
                pageScrollView.delegate = self
            }
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
            
            let selectionBarOriginX = originX - (selectionBarWidth - button.frame.width) / 2 + offset - barButtonItemWidth - valueToSubtract
            
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
                let expression = button.frame.width + space / 2 + (selectionBarWidth - button.frame.width) / 2
                newRatio = view.frame.width / (expression + nextSpace / 2 - (selectionBarWidth - nextButton.frame.width) / 2)
                
            }
            
            
            selectionBar.frame = CGRect(x: selectionBarOriginX - (xFromCenter/newRatio), y: selectionBar.frame.origin.y, width: selectionBarWidth, height: selectionBarHeight)
            return
            
        }
        
    }
    
    
    //Triggered when selected button in navigation view is changed
    func scrollToNextViewController(_ index: Int) {
        
        let currentViewControllerIndex = currentPageIndex - 1
        
        //Comparing index (i.e. tab where user is going to) and when compared, we can now know what direction we should go
        //Index is on the right
        if index > currentViewControllerIndex {
            
            //loop - if user goes from tab 1 to tab 3 we want to have tab 2 in animation
            for viewControllerIndex in currentViewControllerIndex...index {
                let destinationViewController = pageArray[viewControllerIndex]
                pageController.setViewControllers([destinationViewController], direction: .forward, animated: true, completion:nil)
                
            }
        }
            //Index is on the left
        else {
            
            for viewControllerIndex in (index...currentViewControllerIndex).reversed() {
                let destinationViewController = pageArray[viewControllerIndex]
                pageController.setViewControllers([destinationViewController], direction: .reverse, animated: true, completion: nil)
                
            }
        }
        
    }
    
    @objc func switchTabs(_ sender: UIButton) {
        
        let index = sender.tag - 1
        
        //Can't animate twice to the same controller (otherwise weird stuff happens)
        guard index != finalPageIndex && index != currentPageIndex - 1 && animationFinished else {return}
        
        animationFinished = false
        finalPageIndex = index
        scrollToNextViewController(index)
    }
    
    func addFunction(_ button: UIButton) {
        button.addTarget(self, action: #selector(self.switchTabs(_:)), for: .touchUpInside)
    }
    
    
    
    func setPageController() {
        
        guard (self.topViewController as? UIPageViewController) != nil else {return}
        
        pageController = self.topViewController as! UIPageViewController
        pageController.delegate = self
        pageController.dataSource = self
        
        viewWidth = view.frame.width
        navigationBarHeight = navigationBar.frame.height
    }
    
    func changeButtonColor(_ xFromCenter: CGFloat) {
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
            
            button.isSelected = true
            previousButton.isSelected = false
        }
            
            //Going right, current button selected
        else if 0 ... halfBorder ~= xFromCenter && currentPageIndex > 1 {
            
            let button = buttons[currentPageIndex - 1]
            let previousButton = buttons[currentPageIndex - 2]
            
            button.titleLabel?.textColor = selectedButtonColor
            previousButton.titleLabel?.textColor = buttonColor
            
            button.isSelected = true
            previousButton.isSelected = false
        }
            
            //Going left, current button selected
        else if -halfBorder ... 0 ~= xFromCenter && currentPageIndex < buttons.count {
            
            let previousButton = buttons[currentPageIndex]
            let button = buttons[currentPageIndex - 1]
            
            button.titleLabel?.textColor = selectedButtonColor
            previousButton.titleLabel?.textColor = buttonColor
            
            button.isSelected = true
            previousButton.isSelected = false
        }
            
            //Going right, next button selected
        else if -border ... -viewWidthHalf ~= xFromCenter && currentPageIndex < buttons.count {
            let button = buttons[currentPageIndex]
            let previousButton = buttons[currentPageIndex - 1]
            
            button.titleLabel?.textColor = selectedButtonColor
            previousButton.titleLabel?.textColor = buttonColor
            
            button.isSelected = true
            previousButton.isSelected = false
            
            
        }
        
    }
    
}

extension SwipeViewController: UIPageViewControllerDataSource {
    //Swiping left
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        //Get current view controller index
        guard let viewControllerIndex = pageArray.index(of: viewController) else {return nil}
        
        let previousIndex = viewControllerIndex - 1
        
        //Making sure the index doesn't get bigger than the array of view controllers
        guard previousIndex >= 0 && pageArray.count > previousIndex else {return nil}
        
        return pageArray[previousIndex]
    }
    
    //Swiping right
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //Get current view controller index
        guard let viewControllerIndex = pageArray.index(of: viewController) else {return nil}
        
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


