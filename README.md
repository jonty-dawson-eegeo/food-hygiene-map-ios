<a href="http://www.eegeo.com/">
    <img src="http://cdn2.eegeo.com/wp-content/uploads/2016/03/eegeo_logo_quite_big.png" alt="eeGeo Logo" title="eegeo" align="right" height="80px" />
</a>

# Food Hygiene map

This app makes use of the [eeGeo iOS API](https://github.com/eegeo/ios-api) to display food hygiene rating data from the [UK Food Standards Agency](http://ratings.food.gov.uk/open-data/). 

The app was created as part of an internal app-jam, based on a duplication of the [eeGeo iOS API Example app](https://github.com/eegeo/ios-api-example), 

- [Setup](#setup)
- [Usage](#usage)

## Setup 

The eeGeo iOS API is installed via [CocoaPods](https://cocoapods.org/pods/eegeo).

1. Install CocoaPods as described in the [CocoaPods guide](https://guides.cocoapods.org/using/getting-started.html#getting-started).
2. Clone this repo: `git clone git@github.com:eegeo/food-hygiene-map-ios.git`.
3. Install the eeGeo pod, and other app dependencies by running `pod install` from the repo root.
4. Obtain an [eeGeo API key](https://www.eegeo.com/developers/apikeys) and place it in the [eeGeoApiExample-Info.plist](https://github.com/eegeo/food-hygiene-map-ios/blob/master/ExampleApp/eeGeoApiExample-Info.plist#L6) file.
5. Open, build, and run **eeGeoApiExample.xcworkspace** in Xcode.

Further eeGeo iOS api setup details can be found on the [eeGeo iOS API Example app readme](https://github.com/eegeo/ios-api-example/blob/master/README.md).

## Usage

* Tap on a pin to see hygiene rating details
* Tap Refresh to fetch results for premises located within a 1 mile radius of the current map centre location 
* Tap Home to centre the map at [eeGeo's](http://www.eegeo.com) development studio in Dundee, Scotland
* Tap Flatten to toggle [environmental flattening and map theme change](http://www.eegeo.com/developers/documentation/mobileexampleapp/#flatten).

![Screenshot](https://github.com/jonty-dawson-eegeo/food-hygiene-map-ios/blob/master/food_hygiene_screenshot.png)
