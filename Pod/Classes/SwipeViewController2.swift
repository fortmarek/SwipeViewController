//
//  SwipeViewController2.swift
//  Pods-SwipeViewController_Example
//
//  Created by Marek Fořt on 6/10/19.
//

import Foundation
import UIKit

open class SwipeViewController2: UINavigationController, UIPageViewControllerDelegate, UIScrollViewDelegate {

    public var selectionBarHeight: CGFloat = 3
    public var offset: CGFloat = 0
    public var bottomOfset: CGFloat = 0
    public var buttonColor: UIColor = .black
    public var selectionBarColor = UIColor.black
    public var selectedButtonColor: UIColor = .blue
    public var backgroundColor: UIColor = .white
    public var buttonFont = UIFont.systemFont(ofSize: 18)
    // Besides keeping current page index it also determines what will be the first view
    public var currentPageIndex = 0
    public var spaces: [CGFloat] = []
    public var x: CGFloat = 0

    private(set) public var pageArray: [UIViewController] = []

    //NavigationBar
    public var equalSpaces = true

    private(set) weak var navigationView: UIView!
    private weak var selectionBar: UIView!

    private var selectionBarOriginX: CGFloat = 0
    private var selectionBarWidth: CGFloat = 0

    private var titleImages = [SwipeButtonWithImage]()
    private var buttons: [UIButton] = []
    private weak var pageController: UIPageViewController!
    private var totalButtonWidth: CGFloat = 0
    private var finalPageIndex = -1
    private var indexNotIncremented = true
    private var animationFinished = true
    private var valueToSubtract: CGFloat = 0

    open func setViewControllerArray(_ viewControllers: [UIViewController]) {
        pageArray = viewControllers
        view.backgroundColor = pageArray[currentPageIndex].view.backgroundColor

        guard let pageController = topViewController as? UIPageViewController else { return }
        pageController.delegate = self
        pageController.dataSource = self
        self.pageController = pageController

        let navigationViewFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: navigationBar.frame.height)
        let navigationView = UIView(frame: navigationViewFrame)
        pageController.navigationController?.navigationBar.topItem?.titleView = navigationView
        self.navigationView = navigationView

        let selectionBar = UIView()
        selectionBarWidth = view.frame.width / 2
        view.addSubview(selectionBar)
        self.selectionBar = selectionBar

        let originY = navigationView.frame.origin.y + navigationView.frame.height - selectionBarHeight - bottomOfset
        selectionBar.frame = CGRect(x: selectionBarOriginX, y: originY, width: selectionBarWidth, height: selectionBarHeight)
        selectionBar.backgroundColor = selectedButtonColor

        initButtons()

        if let scrollView = pageController.view.subviews.compactMap({ $0 as? UIScrollView }).first {
            scrollView.delegate = self
        }

        //Select button of initial view controller - change to selected image
        buttons[currentPageIndex].isSelected = true

        //Init of initial view controller
        guard currentPageIndex >= 0 else {return}
        let initialViewController = pageArray[currentPageIndex]
        pageController.setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
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

    open func setNavigationWithItem(_ color: UIColor, leftItem: UIBarButtonItem?, rightItem: UIBarButtonItem?) {
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.rightBarButtonItem = rightItem
    }


    open func setBarButtonItem(_ side: Side, barButtonItem: UIBarButtonItem) {
        if side == .left {
            pageController.navigationItem.leftBarButtonItem = barButtonItem
            getValueToSubtract()
            buttons.forEach {$0.frame.origin.x -= valueToSubtract}
            selectionBar.frame.origin.x -= valueToSubtract
        }
        else {
            pageController.navigationItem.rightBarButtonItem = barButtonItem
        }
    }

    private func getValueToSubtract() {
        guard let firstButton = buttons.first else {return}
        let convertedXOrigin = firstButton.convert(firstButton.frame.origin, to: view).x
        let valueToSubtract: CGFloat = (convertedXOrigin - offset) / 2 - x / 2
        self.valueToSubtract = valueToSubtract
    }

    private func initButtons() {
        let buttons = pageArray.enumerated().map {
            createButton(with: $0.element, tag: $0.offset + 1)
        }

        var space: CGFloat = 0
        var width: CGFloat = 0

        if equalSpaces {
            // Space between buttons
            let offset: CGFloat = self.offset
            x = (view.frame.width - 2 * offset - totalButtonWidth) / CGFloat(buttons.count + 1)
        } else {
            // Space reserved for one button (with label and spaces around it)
            space = (view.frame.width - 2 * offset) / CGFloat(buttons.count)
        }

        for button in buttons {

            let buttonHeight = button.frame.height
            let buttonWidth = view.frame.width / 2

            let originY = navigationView.frame.origin.y + (navigationView.frame.height - buttonHeight) / 2
            var originX: CGFloat = 0

            if equalSpaces {
                originX = x * CGFloat(button.tag) + width + offset
                width += buttonWidth
            } else {
                let buttonSpace = space - buttonWidth
                originX = buttonSpace / 2 + width + offset
                width += buttonWidth + space - buttonWidth
                spaces.append(buttonSpace)
            }

            button.setTitleColor(selectedButtonColor, for: .selected)
            button.setTitleColor(buttonColor, for: .normal)

            if button.tag == currentPageIndex + 1 {
                selectionBarOriginX = originX - (selectionBarWidth - buttonWidth) / 2
            }

            button.frame = CGRect(x: originX, y: originY, width: buttonWidth, height: buttonHeight)
            button.addTarget(self, action: #selector(switchTabs), for: .touchUpInside)
            navigationView.addSubview(button)
        }

        self.buttons = buttons
    }

    private func createButton(with page: UIViewController, tag: Int) -> UIButton {
        let button = UIButton()
        button.setTitle(page.title, for: [])
        button.titleLabel?.font = buttonFont

        button.titleLabel?.sizeToFit()

        button.frame = button.titleLabel?.frame ?? .zero

        button.frame.size.width = view.frame.width / 2

        //Tag
        button.tag = tag

        totalButtonWidth += button.frame.width

        return button
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let xFromCenter = view.frame.size.width - scrollView.contentOffset.x

        //print(xFromCenter)
        let border = view.frame.width - 1

        guard currentPageIndex >= 0 && currentPageIndex < buttons.count else {return}

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
        if xFromCenter <= -view.frame.width && indexNotIncremented && currentPageIndex < buttons.count - 1 {
            currentPageIndex += 1
            indexNotIncremented = false
        }
            //Going left
        else if xFromCenter >= view.frame.width && indexNotIncremented && currentPageIndex >= 1 {
            currentPageIndex -= 1
            indexNotIncremented = false
        }

        if buttonColor != selectedButtonColor {
            changeButtonColor(xFromCenter)
        }

        setSelectionBarFrame(with: xFromCenter)
    }

    private func setSelectionBarFrame(with xFromCenter: CGFloat) {
        var width: CGFloat = 0

        for button in buttons {

            var originX: CGFloat = 0
            var space: CGFloat = 0

            if equalSpaces {
                originX = x * CGFloat(button.tag) + width
                width += button.frame.width
            } else {
                space = spaces[button.tag - 1]
                originX = space / 2 + width
                width += button.frame.width + space
            }

            let selectionBarOriginX = originX - (selectionBarWidth - button.frame.width) / 2 + offset - valueToSubtract

            //Get button with current index
            guard button.tag == currentPageIndex + 1 else { continue }

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

        let currentViewControllerIndex = currentPageIndex

        // Comparing index (i.e. tab where user is going to) and when compared, we can now know what direction we should go
        // Index is on the right
        if index > currentViewControllerIndex {

            // loop - if user goes from tab 1 to tab 3 we want to have tab 2 in animation
            for viewControllerIndex in currentViewControllerIndex...index {
                let destinationViewController = pageArray[viewControllerIndex]
                pageController.setViewControllers([destinationViewController], direction: .forward, animated: true, completion: nil)

            }
        }
            // Index is on the left
        else {

            for viewControllerIndex in (index...currentViewControllerIndex).reversed() {
                let destinationViewController = pageArray[viewControllerIndex]
                pageController.setViewControllers([destinationViewController], direction: .reverse, animated: true, completion: nil)
            }
        }
    }

    @objc func switchTabs(_ sender: UIButton) {
        let index = sender.tag

        //Can't animate twice to the same controller (otherwise weird stuff happens)
        guard index != finalPageIndex && index != currentPageIndex && animationFinished else {return}

        animationFinished = false
        finalPageIndex = index
        scrollToNextViewController(index)
    }

    func changeButtonColor(_ xFromCenter: CGFloat) {
        //Change color of button before animation finished (i.e. colour changes even when the user is between buttons

        let viewWidthHalf = view.frame.width / 2
        let border = view.frame.width - 1
        let halfBorder = viewWidthHalf - 1

        // Going left, next button selected
        if viewWidthHalf ... border ~= xFromCenter && currentPageIndex > 0 {

            let button = buttons[currentPageIndex - 1]
            let previousButton = buttons[currentPageIndex]

            button.isSelected = true
            previousButton.isSelected = false
        }
        // Going right, current button selected
        else if 0 ... halfBorder ~= xFromCenter && currentPageIndex > 0 {

            let button = buttons[currentPageIndex]
            let previousButton = buttons[currentPageIndex - 1]

            button.isSelected = true
            previousButton.isSelected = false
        }
        // Going left, current button selected
        else if -halfBorder ... 0 ~= xFromCenter && currentPageIndex > 0 {

            let previousButton = buttons[currentPageIndex - 1]
            let button = buttons[currentPageIndex]

            button.isSelected = true
            previousButton.isSelected = false
        }

        // Going right, next button selected
        else if -border ... -viewWidthHalf ~= xFromCenter && currentPageIndex < buttons.count - 1 {
            let button = buttons[currentPageIndex + 1]
            let previousButton = buttons[currentPageIndex]

            button.isSelected = true
            previousButton.isSelected = false

        }

    }

}

extension SwipeViewController2: UIPageViewControllerDataSource {
    //Swiping left
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {

        //Get current view controller index
        guard let viewControllerIndex = pageArray.firstIndex(of: viewController) else { return nil }

        let previousIndex = viewControllerIndex - 1

        //Making sure the index doesn't get bigger than the array of view controllers
        guard previousIndex >= 0, pageArray.count > previousIndex else { return nil }

        view.backgroundColor = pageArray[previousIndex].view.backgroundColor

        return pageArray[previousIndex]
    }

    //Swiping right
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //Get current view controller index
        guard let viewControllerIndex = pageArray.firstIndex(of: viewController) else {return nil}

        let nextIndex = viewControllerIndex + 1

        //Making sure the index doesn't get bigger than the array of view controllers
        guard pageArray.count > nextIndex else { return nil }

        view.backgroundColor = pageArray[nextIndex].view.backgroundColor

        return pageArray[nextIndex]
    }
}
