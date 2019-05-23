# Table of Contents

- [AAImagePicker](#section-id-4)
  - [Description](#section-id-10)
  - [Demonstration](#section-id-16)
  - [Requirements](#section-id-26)
- [Installation](#section-id-32)
  - [CocoaPods](#section-id-37)
  - [Carthage](#section-id-63)
  - [Manual Installation](#section-id-82)
- [Getting Started](#section-id-87)
  - [Get authorized to use AAImagePicker!](#section-id-90)
  - [Create instance of image picker](#section-id-104)
  - [Show image picker options](#section-id-112)
  - [Define options](#section-id-132)
  - [Use AAResizer to get the resized image](#section-id-150)
- [Contributions & License](#section-id-156)


<div id='section-id-4'/>

# AAImagePicker

[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods](https://img.shields.io/cocoapods/v/AAImagePicker.svg)](http://cocoadocs.org/docsets/AAImagePicker) [![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Carthage/Carthage) [![Build Status](https://travis-ci.org/EngrAhsanAli/AAImagePicker.svg?branch=master)](https://travis-ci.org/EngrAhsanAli/AAImagePicker) 
![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg) [![CocoaPods](https://img.shields.io/cocoapods/p/AAImagePicker.svg)]()


<div id='section-id-10'/>

## Description


AAImagePicker is a simple & easy-to-use image picker designed to present both camera and photo library options and get the UIImage easily.


<div id='section-id-16'/>

## Demonstration



![](https://github.com/EngrAhsanAli/AAImagePicker/blob/master/Screenshots/demo.gif)


To run the example project, clone the repo, and run `pod install` from the Example directory first.


<div id='section-id-26'/>

## Requirements

- iOS 8.0+
- Xcode 8.0+


<div id='section-id-32'/>

# Installation

`AAImagePicker` can be installed using CocoaPods, Carthage, or manually.


<div id='section-id-37'/>

## CocoaPods

`AAImagePicker` is available through [CocoaPods](http://cocoapods.org). To install CocoaPods, run:

`$ gem install cocoapods`

Then create a Podfile with the following contents:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
pod 'AAImagePicker'
end

```

Finally, run the following command to install it:
```
$ pod install
```



<div id='section-id-63'/>

## Carthage

To install Carthage, run (using Homebrew):
```
$ brew update
$ brew install carthage
```
Then add the following line to your Cartfile:

```
github "EngrAhsanAli/AAImagePicker" "master"
```

Then import the library in all files where you use it:
```swift
import AAImagePicker
```


<div id='section-id-82'/>

## Manual Installation

If you prefer not to use either of the above mentioned dependency managers, you can integrate `AAImagePicker` into your project manually by adding the files contained in the Classes folder to your project.


<div id='section-id-87'/>

# Getting Started
----------

<div id='section-id-90'/>

##Get authorized to use AAImagePicker!

You need to add the following in your `Info.plist` file.

```
<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>$(PRODUCT_NAME) photo use</string>

<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) camera use</string>
```

<div id='section-id-104'/>

## Create instance of image picker

Create an instance by just calling the following line in your view controller.

```swift
let imagePicker = AAImagePicker()
```

<div id='section-id-112'/>

## Show image picker options

Show image picker options by just calling the following method

```swift
imagePicker.present { (image) in
// Get your image       
}
```
> Note that this method has optional parameter `AAImagePickerOptions`

Here's the method signature:

```swift
open func present(_ options: AAImagePickerOptions? = nil, _ completion: @escaping ((UIImage) -> Void))

```



<div id='section-id-132'/>

## Define options

You can define options in your code and pass the options to `present` function.

```swift
actionSheetTitle: String = "Choose Option"
actionSheetMessage: String = "Select an option to pick an image"
optionCamera = "Camera"
optionLibrary = "Photo Library"
optionCancel = "Cancel"
allowsEditing = false
rotateCameraImage: CGFloat = 0
resizeValue: CGFloat = 500
resizeType: AAResizer = .none
```

> Note that `resizeValue` will depend on the method from `resizeType`.

<div id='section-id-150'/>

## Use AAResizer to get the resized image

By defualt, it has `.none` but you can change it if you want.
Resizing options are `.width` and `.scale` .
You can pass `resizeType` to `AAImagePickerOptions` and set the value by setting `resizeValue`.

<div id='section-id-156'/>

# Contributions & License

`AAImagePicker` is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.

Pull requests are welcome! The best contributions will consist of substitutions or configurations for classes/methods known to block the main thread during a typical app lifecycle.

I would love to know if you are using `AAImagePicker` in your app, send an email to [Engr. Ahsan Ali](mailto:hafiz.m.ahsan.ali@gmail.com)

