# Optile iOS SDK

⚠️ Framework is on development stage.

## Installation

### CocoaPods
CocoaPods is one of dependency managers. For usage and installation instructions, visit [their website](https://cocoapods.org). To integrate the framework into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Optile', :git => 'https://github.com/optile/ios-sdk', :branch => 'develop'
```

## Example
We prepared an example application where you could try our framework. To launch it complete these steps:

1. Install local dependency using:
  ```bash
cd Example
pod install
```

2. Open `Example/Example.xcworkspace` file in XCode.

## Customizing the UI

You may customize the appearance of payment screens by using `Theme.shared` singleton:

```swift
Theme.shared.errorTextColor = .orange
```

Default values are stored in `Theme.standart` object.

|Property|Description|
|-|-|
|`font`|Global font that will be used in all views, size will changed automatically|
|`textColor`|Primary text color|
|`detailTextColor`|Secondary text color, used for detailed description in list's cell|
|`buttonTextColor`|Buttons text color|
|`errorTextColor`|Text color for error messages|
|`backgroundColor`|Background color of view controllers|
|`tableBorder`|Table border's line color|
|`tableCellSeparator`|Table line separators color|
|`tintColor`|Tint color used for interactive elements, it used also as a background color for buttons|
