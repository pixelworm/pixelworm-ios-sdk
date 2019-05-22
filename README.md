![Pixelworm logo](https://raw.githubusercontent.com/Pixelworm/pixelworm-ios-sdk/master/pixelworm.png)

# Pixelworm iOS SDK

### Contents
- [Purpose of this SDK](#purpose-of-this-sdk)
- [Installation](#installation)
- [Usage](#usage)

## Purpose of this SDK
Pixelworm SDK exports your excellent views to `Pixelworm`’s database. After exporting your views and your design files to `Pixelworm` you can enjoy suggestions about how to improve your designs.

## Installation

### Cocoapods
To integrate `Pixelworm iOS SDK` into your project you must add following line to your `Podfile`.

```ruby
pod ‘Pixelworm’
```

⚠️ Important: Don’t forget to execute `bash` script below after adding pod lines:

```bash
pod install
```

## Usage
After integrating SDK into your project navigate to your `AppDelegate.swift` file.
- Add `import PixelwormSDK` to the top of the file.
- In `application(_:didFinishLaunchingWithOptions:)` function, add lines below. Make sure you replace `YOUR_API_KEY` and `YOUR_SECRET_KEY` with your application’s keys.

```swift
#if DEBUG

do {
  try Pixelworm.attach(withApiKey: "YOUR_API_KEY", andSecretKey: "YOUR_SECRET_KEY")
} catch let error {
  /*
   * TODO:
   * Handle errors as you wish.
   * Errors will be type of `PixelwormError`.
   */
   
   print("An error occurred while attaching Pixelworm, error: \(error)")
}

#endif
```

- In `applicationWillTerminate(_:)` add lines below.

```swift
#if DEBUG

do {
  try Pixelworm.detach()
} catch let error {
  /*
   * TODO:
   * Handle errors as you wish.
   * Errors will be type of `PixelwormError`.
   */
   
   print("An error occurred while detaching Pixelworm, error: \(error)")
}

#endif
```

- You're good to go. Just launch your application and check `Pixelworm`'s Screen page!

