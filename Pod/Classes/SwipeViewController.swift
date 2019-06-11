//
//  SwipeViewController.swift
//  SwipeBetweenViewControllers
//
//  Created by Marek Fořt on 11.03.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit

public enum Side {
    case left, right
}

open class SwipeViewController: UINavigationController, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    public var pages: [UIViewController] = [] {
        didSet {
            view.backgroundColor = pages[currentPageIndex - 1].view.backgroundColor
        }
    }
    public var startIndex: Int = 0 {
        didSet {
            guard pages.count > startIndex else { return }
            currentPageIndex = startIndex + 1
            view.backgroundColor = pages[startIndex].view.backgroundColor
        }
    }
    public var selectionBarHeight: CGFloat = 0
    public var selectionBarWidth: CGFloat = 0
    public var selectionBarColor: UIColor = .black
    public var buttonFont = UIFont.systemFont(ofSize: 18)
    public var buttonColor: UIColor = .black
    public var selectedButtonColor: UIColor = .green
    public var navigationBarColor: UIColor = .white
    public var leftBarButtonItem: UIBarButtonItem? {
        didSet {
            pageController.navigationItem.leftBarButtonItem = leftBarButtonItem
            getValueToSubtract()
            buttons.forEach { $0.frame.origin.x -= valueToSubtract }
            selectionBar.frame.origin.x -= valueToSubtract
        }
    }
    public var rightBarButtonItem: UIBarButtonItem? {
        didSet {
            pageController.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    
    // SwipeButtons
    var offset: CGFloat = 40
    var bottomOfset: CGFloat = 0

    open var currentPageIndex = 1 // Besides keeping current page index it also determines what will be the first view
    var spaces = [CGFloat]()
    var x: CGFloat = 0
    var titleImages = [SwipeButtonWithImage]()

    private weak var navigationView: UIView!
    open var equalSpaces = true
    
    
    // Other values (should not be changed)
    var buttons = [UIButton]()
    var viewWidth: CGFloat = 0
    var barButtonItemWidth: CGFloat = 0
    var navigationBarHeight: CGFloat = 0
    var selectionBar = UIView()
    var pageController = UIPageViewController()
    var totalButtonWidth: CGFloat = 0
    var finalPageIndex = -1
    var indexNotIncremented = true
    var pageScrollView = UIScrollView()
    var animationFinished = true
    var valueToSubtract: CGFloat = 0

    private var selectionBarOriginX: CGFloat = 0
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        barButtonItemWidth = pageController.navigationController?.navigationBar.topItem?.titleView?.layoutMargins.left ?? 0

        navigationBar.isTranslucent = false
    }
    
    open func setSwipeViewController() {
        navigationBar.barTintColor = navigationBarColor
        
        setPageController()

        let navigationView = UIView(frame: CGRect(x: 0 , y: 0, width: view.frame.width, height: navigationBar.frame.height))
        navigationView.backgroundColor = navigationBarColor
        pageController.navigationController?.navigationBar.topItem?.titleView = navigationView
        self.navigationView = navigationView
        barButtonItemWidth = pageController.navigationController?.navigationBar.topItem?.titleView?.layoutMargins.left ?? 0

        initButtons()
        initSelectionBar()
        
        syncScrollView()
        
        // Init of initial view controller
        guard currentPageIndex >= 1 else {return}
        let initialViewController = pages[currentPageIndex - 1]
        pageController.setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
        
        // Select button of initial view controller - change to selected image
        buttons[currentPageIndex - 1].isSelected = true
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        setSwipeViewController()
    }

    func setTitleLabel(_ page: UIViewController, font: UIFont, color: UIColor, button: UIButton) {
        // Title font and color
        guard let pageTitle = page.title else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedTitle = NSAttributedString(string: pageTitle, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: UIControl.State())


        guard let titleLabel = button.titleLabel else {return}
        titleLabel.textColor = color

        titleLabel.sizeToFit()

        button.frame = titleLabel.frame
    }

    func initSelectionBar() {
        let selectionBar = UIView()

        // SelectionBar
        let originY = navigationView.frame.height - selectionBarHeight - bottomOfset
        selectionBar.frame = CGRect(x: selectionBarOriginX , y: originY, width: selectionBarWidth, height: selectionBarHeight)
        selectionBar.backgroundColor = selectionBarColor
        navigationView.addSubview(selectionBar)
        self.selectionBar = selectionBar
    }

    func initButtons() {
        var buttons = [UIButton]()
        var totalButtonWidth = 0 as CGFloat

        // Buttons

        var tag = 0
        for page in pages {
            let button = UIButton()

            if titleImages.isEmpty {
                setTitleLabel(page, font: buttonFont, color: buttonColor, button: button)
            }

            else {
                // UI of button with image

                // Getting buttnWithImage struct from array
                let buttonWithImage = titleImages[tag]
                // Normal image
                button.setImage(buttonWithImage.image, for: UIControl.State())
                // Selected image
                button.setImage(buttonWithImage.selectedImage, for: .selected)
                // Button tint color
                button.tintColor = buttonColor

                // Button size
                if let size = buttonWithImage.size {
                    button.frame.size = size
                }

            }

            // Tag
            tag += 1
            button.tag = tag

            totalButtonWidth += button.frame.width

            buttons.append(button)
        }


        var space: CGFloat = 0
        var width: CGFloat = 0

        if equalSpaces {
            // Space between buttons
            let offset: CGFloat = self.offset
            x = (view.frame.width - 2 * offset - totalButtonWidth) / CGFloat(buttons.count + 1)
        }

        else {
            // Space reserved for one button (with label and spaces around it)
            space = (view.frame.width - 2 * offset) / CGFloat(buttons.count)
        }

        for button in buttons {

            let buttonHeight = button.frame.height
            let buttonWidth = button.frame.width

            let originY = navigationView.frame.height - selectionBarHeight - bottomOfset - buttonHeight - 3
            var originX: CGFloat = 0

            if equalSpaces {
                originX = x * CGFloat(button.tag) + width + offset - barButtonItemWidth
                width += buttonWidth
            }

            else {
                let buttonSpace = space - buttonWidth
                originX = buttonSpace / 2 + width + offset - barButtonItemWidth
                width += buttonWidth + space - buttonWidth
                spaces.append(buttonSpace)
            }



            if button.tag == currentPageIndex {
                guard let titleLabel = button.titleLabel else {continue}
                selectionBarOriginX = originX - (selectionBarWidth - buttonWidth) / 2
                titleLabel.textColor = selectedButtonColor
            }

            button.frame = CGRect(x: originX, y: originY, width: buttonWidth, height: buttonHeight)
            addFunction(button)
            navigationView.addSubview(button)
        }

        self.buttons = buttons
    }

    open func addViewController(_ viewController: UIViewController) {
        pages.append(viewController)
        view.backgroundColor = pages[currentPageIndex - 1].view.backgroundColor
    }
    
    open func setButtonsOffset(_ offset: CGFloat, bottomOffset: CGFloat) {
        self.offset = offset
        self.bottomOfset = bottomOffset
    }
    
    open func setButtonsWithImages(_ titleImages: Array<SwipeButtonWithImage>) {
        self.titleImages = titleImages
    }
    
    open func setBarButtonItem(_ side: Side, barButtonItem: UIBarButtonItem) {
        if side == .left {
        }
        else {
            pageController.navigationItem.rightBarButtonItem = barButtonItem
        }
    }
    
    private func getValueToSubtract() {
        guard let firstButton = buttons.first else {return}
        let convertedXOrigin = firstButton.convert(firstButton.frame.origin, to: view).x
        let barButtonWidth: CGFloat = equalSpaces ? 0 : barButtonItemWidth
        let valueToSubtract: CGFloat = (convertedXOrigin - offset + barButtonWidth) / 2 - x / 2
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
        // print(xFromCenter)
        let border = viewWidth - 1
        
        
        guard currentPageIndex > 0 && currentPageIndex <= buttons.count else {return}
        
        // Ensuring currentPageIndex is not changed twice
        if -border ... border ~= xFromCenter {
            indexNotIncremented = true
        }
        
        // Resetting finalPageIndex for switching tabs
        if xFromCenter == 0 {
            finalPageIndex = -1
            animationFinished = true
        }
        
        // Going right
        if xFromCenter <= -viewWidth && indexNotIncremented && currentPageIndex < buttons.count {
            view.backgroundColor = pages[currentPageIndex].view.backgroundColor
            currentPageIndex += 1
            indexNotIncremented = false
        }
            
        // Going left
        else if xFromCenter >= viewWidth && indexNotIncremented && currentPageIndex >= 2 {
            view.backgroundColor = pages[currentPageIndex - 2].view.backgroundColor
            currentPageIndex -= 1
            indexNotIncremented = false
        }
        
        if buttonColor != selectedButtonColor {
            changeButtonColor(xFromCenter)
        }
        
        
        for button in buttons {
            
            var originX: CGFloat = 0
            var space: CGFloat = 0
            
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
            
            // Get button with current index
            guard button.tag == currentPageIndex
                else {continue}
            
            var nextButton = UIButton()
            var nextSpace: CGFloat = 0
            
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
            
            var newRatio: CGFloat = 0
            
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
    
    
    // Triggered when selected button in navigation view is changed
    func scrollToNextViewController(_ index: Int) {
        
        let currentViewControllerIndex = currentPageIndex - 1
        
        // Comparing index (i.e. tab where user is going to) and when compared, we can now know what direction we should go
        // Index is on the right
        if index > currentViewControllerIndex {
            
            // loop - if user goes from tab 1 to tab 3 we want to have tab 2 in animation
            for viewControllerIndex in currentViewControllerIndex...index {
                let destinationViewController = pages[viewControllerIndex]
                pageController.setViewControllers([destinationViewController], direction: .forward, animated: true, completion:nil)
                
            }
        }
            // Index is on the left
        else {
            
            for viewControllerIndex in (index...currentViewControllerIndex).reversed() {
                let destinationViewController = pages[viewControllerIndex]
                pageController.setViewControllers([destinationViewController], direction: .reverse, animated: true, completion: nil)
                
            }
        }
        
    }
    
    @objc func switchTabs(_ sender: UIButton) {
        
        let index = sender.tag - 1
        
        // Can't animate twice to the same controller (otherwise weird stuff happens)
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
    }
    
    func changeButtonColor(_ xFromCenter: CGFloat) {
        // Change color of button before animation finished (i.e. colour changes even when the user is between buttons
        
        let viewWidthHalf = viewWidth / 2
        let border = viewWidth - 1
        let halfBorder = viewWidthHalf - 1
        
        // Going left, next button selected
        if viewWidthHalf ... border ~= xFromCenter && currentPageIndex > 1 {
            
            let button = buttons[currentPageIndex - 2]
            let previousButton = buttons[currentPageIndex - 1]
            
            button.titleLabel?.textColor = selectedButtonColor
            previousButton.titleLabel?.textColor = buttonColor
            
            button.isSelected = true
            previousButton.isSelected = false
        }
            
            // Going right, current button selected
        else if 0 ... halfBorder ~= xFromCenter && currentPageIndex > 1 {
            
            let button = buttons[currentPageIndex - 1]
            let previousButton = buttons[currentPageIndex - 2]
            
            button.titleLabel?.textColor = selectedButtonColor
            previousButton.titleLabel?.textColor = buttonColor
            
            button.isSelected = true
            previousButton.isSelected = false
        }
            
            // Going left, current button selected
        else if -halfBorder ... 0 ~= xFromCenter && currentPageIndex < buttons.count {
            
            let previousButton = buttons[currentPageIndex]
            let button = buttons[currentPageIndex - 1]
            
            button.titleLabel?.textColor = selectedButtonColor
            previousButton.titleLabel?.textColor = buttonColor
            
            button.isSelected = true
            previousButton.isSelected = false
        }
            
            // Going right, next button selected
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
    // Swiping left
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // Get current view controller index
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        // Making sure the index doesn't get bigger than the array of view controllers
        guard previousIndex >= 0 && pages.count > previousIndex else {return nil}
        
        return pages[previousIndex]
    }
    
    // Swiping right
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // Get current view controller index
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        // Making sure the index doesn't get bigger than the array of view controllers
        guard pages.count > nextIndex else {return nil}
        
        
        return pages[nextIndex]
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


