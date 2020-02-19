![Pixelworm Logo](https://raw.githubusercontent.com/Pixelworm/pixelworm-ios-sdk/master/pixelworm.png)

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/PixelwormSDK.svg)](https://img.shields.io/cocoapods/v/PixelwormSDK.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/PixelwormSDK.svg?style=flat)](https://cocoapods.org/pods/PixelwormSDK)

# Pixelworm iOS SDK

## Contents
- [Purpose of this SDK](#purpose-of-this-sdk)
- [Installation](#installation)
  - [Installing using Cocoapods](#installing-using-cocoapods)
  - [Installing using Carthage](#installing-using-carthage)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Purpose of this SDK
Pixelworm SDK uploads your views into `Pixelworm`’s system.
After uploading your views and your design files to `Pixelworm` you can see suggestions on how to improve your designs.

## Installation

### Installing using Cocoapods
To integrate `Pixelworm iOS SDK` into your project you must add following line to your
`Podfile`. For usage and installation instructions, visit [their website](https://cocoapods.org/).

```ruby
pod 'PixelwormSDK', '~> 1.0.26'
```

### Installing using Carthage

To integrate `Pixelworm iOS SDK` into your project you must add following line to your
`Cartfile`. For usage and installation instructions, visit [their website](https://github.com/Carthage/Carthage).

```ruby
github "pixelworm/pixelworm-ios-sdk" ~> 1.0.26
```

### Usage

After integrating the SDK into your project navigate to your `AppDelegate.swift` file.
- Add `import PixelwormSDK` to the beginning of the file.
- In `application(_:didFinishLaunchingWithOptions:)` function, add the lines below.
Make sure you replace `YOUR_API_KEY` and `YOUR_SECRET_KEY` with your application’s
keys.

```swift
Pixelworm.attach(apiKey: "YOUR_API_KEY", secretKey: "YOUR_SECRET_KEY")
```

- In `applicationWillTerminate(_:)` add the lines below.

```swift
Pixelworm.detach()
```

- You're good to go. Just launch your application and look for `PixelwormSDK`'s output in
your *debug console*. Once you see the success message go check `Pixelworm`'s
Screens page!

## Contributing

Please make sure you've read this document before contributing:

[Contribution Guidelines](CONTRIBUTING.md)

## License

[MIT](LICENSE)
