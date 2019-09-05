![Pixelworm Logo](https://raw.githubusercontent.com/Pixelworm/pixelworm-ios-sdk/master/pixelworm.png)

# Pixelworm iOS SDK

## Contents
- [Purpose of this SDK](#purpose-of-this-sdk)
- [Installation](#installation)
  - [Installing using Cocoapods](#installing-using-cocoapods)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Purpose of this SDK
Pixelworm SDK uploads your excellent views into `Pixelworm`’s system.
After uploading your views and your design files to `Pixelworm` you can see suggestions on how to improve your designs.

## Installation

### Installing using Cocoapods
To integrate `Pixelworm iOS SDK` into your project you must add following line to your
`Podfile`.

```ruby
pod 'PixelwormSDK'
```

⚠️ Important: Don’t forget to execute the `bash` script below after adding pod lines:

```bash
pod install
```

## Usage
After integrating the SDK into your project navigate to your `AppDelegate.swift` file.
- Add `import PixelwormSDK` to the beginning of the file.
- In `application(_:didFinishLaunchingWithOptions:)` function, add the lines below.
Make sure you replace `YOUR_API_KEY` and `YOUR_SECRET_KEY` with your application’s
keys.

```swift
#if DEBUG

do {
  try Pixelworm.attach(
      withApiKey: "YOUR_API_KEY",
      andSecretKey: "YOUR_SECRET_KEY"
  )
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

- In `applicationWillTerminate(_:)` add the lines below.

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

- You're good to go. Just launch your application and look for `PixelwormSDK`'s output in
your *debug console*. Once you see the success message go check `Pixelworm`'s
Screens page!

## Contributing

Please make sure you've read this document before contributing:

[Contribution Guidelines](CONTRIBUTING.md)

## License

[MIT](LICENSE)
