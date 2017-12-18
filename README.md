# SwipeViewController

[![CI Status](http://img.shields.io/travis/fortmarek/SwipeViewController.svg?style=flat)](https://travis-ci.org/fortmarek/SwipeViewController)
[![Version](https://img.shields.io/cocoapods/v/SwipeViewController.svg?style=flat)](http://cocoapods.org/pods/SwipeViewController)
[![License](https://img.shields.io/cocoapods/l/SwipeViewController.svg?style=flat)](http://cocoapods.org/pods/SwipeViewController)
[![Platform](https://img.shields.io/cocoapods/p/SwipeViewController.svg?style=flat)](http://cocoapods.org/pods/SwipeViewController)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## What is SwipeViewController?

SwipeViewController enables you to modify the navigation bar and implement 'Swipe Buttons' that can user switch pages with and also the user can easily see which page he is on.
SwipeViewController is a modification of Objective-C project RKSwipeBetweenViewControllers. I have not only converted the syntax to Swift but added some more functionality and some other minor changes.

![demo](http://imgur.com/SDIkf4b.gif)

## Installation
### For both options

You can init SwipeViewController simply like this:
```swift 
let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
let navigationController = YourViewControllerName(rootViewController: pageController)
```

### CocoaPods

SwipeViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwipeViewController'
```

### Carthage

If you use Carthage, add this to your Cartfile:

```ruby
github "fortmarek/SwipeViewController"
```

### Manually

Include the Pod/Classes/SwipeViewController.swift and the Pod/Classes/InterfaceController.swift files into your project.

## Usage

First make your ViewController a subclass of SwipeViewController 

```swift 
import SwipeViewController

class ViewController: SwipeViewController {}
```

All the other setup and customization function have to be in viewDidLoad()

### Page Array
You first need to set the array of view controllers that you want to display, in order to do that you need to use this function:
```swift 
let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
let page_one = stb.instantiateViewControllerWithIdentifier(“page1”) as UIViewController
let page_two = stb.instantiateViewControllerWithIdentifier(“page2”) as UIViewController
let page_three = stb.instantiateViewControllerWithIdentifier(“page3”) as UIViewController

setViewControllerArray([page_one, page_two, page_three])
```
Or you can add pages by one and not as a whole array: 

```swift 
let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
let page_one = stb.instantiateViewControllerWithIdentifier(“page1”) as UIViewController

addViewController(page_one)
```

To set the titles of the buttons, you just need to change the title of each page:
```swift 
page_one.title = "Recent"
```
To specify which view controller should be selected first:
```swift 
setFirstViewController(1)
```
It should also be said that the first view controller index starts at zero, just like arrays.

### NavigationBar

To change color of the NavigationBar:

```swift 
setNavigationColor(UIColor.blueColor())
```

You can also include barButtonItems, simply create UIBarButtonItem as you would normally do and then use it like this:

```swift 
let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: nil)
setNavigationWithItem(UIColor.whiteColor(), leftItem: barButtonItem, rightItem: nil)
```

### SwipeButtons

There are two different modes - either every button has the same space on each side not depending on the label size (good for odd numbers)
```swift 
equalSpaces = true
```

or the spaces on each differ depending on the label size (good for even numbers, the label is always centered). 
```swift 
equalSpaces = false
```

You can either customize buttons with this function:
```swift 
setButtons(UIFont.systemFontOfSize(18), color: .black)
```
Or if you want to change the color of the buttons depending on which page the user is on:

```swift 
setButtonsWithSelectedColor(UIFont.systemFontOfSize(18), color: .black, selectedColor: .white)
```

To change the offsets on the side and on the bottom:

```swift 
setButtonsOffset(40, bottomOffset: 5)
```

Instead of titles as labels you can use images. First init the button using SwipeButtonWithImage struct:

```swift
let buttonOne = SwipeButtonWithImage(image: UIImage(named: "Hearts"), selectedImage: UIImage(named: "YellowHearts"), size: CGSize(width: 40, height: 40))
setButtonsWithImages([buttonOne, buttonTwo, buttonThree])
```

### SelectionBar

To customize selection bar, use this function:

```swift 
setSelectionBar(80, height: 3, color: .black)
```

### Additional customization

If you want to customize it even more, you can go right to the the SwipeViewController class file but be careful.


## Author

fortmarek, marekfort@me.com

## License

SwipeViewController is available under the MIT license. See the LICENSE file for more info.
