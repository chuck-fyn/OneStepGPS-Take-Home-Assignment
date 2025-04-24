# OneStepGPS iOS Take-Home Project
This OneStepGPS iOS app is a simple fleet tracker built to the project specifications for OneStepGPS's take home assignment. It allows users to see access device information for the associated fleet, and view that information in three different screen. First in a list view for quick information, second in a map view for a visual representation of the devices location, and third in a dedicated detail view.

The app also allows for sorting preferences to be saved, as well as how often the user would like the data to be refershed, and which devices the user would like to hide. 

## Installation Instructions
1. Clone the Repository
2. Open in Xcode
3. Run the Project in a simulator or on an iOS device

## Closing Thoughts
This was a fun excercise in working with map views in iOS and creating multiples views for displaying different aspects of the same data models. I focused on creating a clean and performant application that was intutive and easy to use for the end user. The JSON data was incredibly rich, and had many similar properties, so I decided to not get too lost in the weeds choosing the correct attributes to highlight in the app, and instead focused on a well polished UI. An example of this would be the lasty updated date in the detail view. The value I pulled seems to be always be a day behind even if we are getting current speed and drive status from the device. I chose to ignore discrepencies in the data like this, but would be happy to make any changes and highlight specifc data attributes if you would like to see those changes. 
