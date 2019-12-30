Pod::Spec.new do |spec|
    spec.name         = "PixelwormSDK"
    spec.version      = "1.0.23"
    spec.summary      = "Pixelworm iOS SDK to export screens"

    spec.description  = <<-DESC
    Pixelworm iOS SDK that can be used to export view controllers to Pixelworm application in real-time.
    DESC

    spec.homepage     = "https://github.com/pixelworm/pixelworm-ios-sdk"
    spec.author       = { "Doğu Emre DEMİRÇİVİ" => "emre@pixelworm.io" }

    spec.ios.deployment_target = "10.0"
    spec.swift_version = "5"

    spec.license      = { :type => "MIT", :file => "LICENSE" }

    spec.source        = { :git => "https://github.com/pixelworm/pixelworm-ios-sdk.git", :tag => "#{spec.version}" }
    spec.source_files  = "PixelwormSDK/**/*.swift"
end
