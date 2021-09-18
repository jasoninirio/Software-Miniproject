<!-- Project Shields -->
![GitHub contributors](https://img.shields.io/github/contributors/jasoninirio/Software-Miniproject)
[![GitHub issues](https://img.shields.io/github/issues/jasoninirio/Software-Miniproject)](https://github.com/jasoninirio/Software-Miniproject/issues)
[![GitHub license](https://img.shields.io/github/license/jasoninirio/Software-Miniproject)](https://github.com/jasoninirio/Software-Miniproject/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/jasoninirio/Software-Miniproject)](https://github.com/jasoninirio/Software-Miniproject/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/jasoninirio/Software-Miniproject)](https://github.com/jasoninirio/Software-Miniproject/network)

<!-- Project Logo + Table of Contents -->
<br />
<p align="center">
  <a href="https://github.com/jasoninirio/Software-Miniproject">
    <img src="images/logo_full.png" alt="Logo" width="300" height="93">
  </a>

  <h3 align="center">healthi</h3>

  <p align="center">
    An App for EC463 built using Flutter and Firebase, using FDA's Food Data API to show food information!
    <br />
    <a href="https://github.com/jasoninirio/Software-Miniproject"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/jasoninirio/Software-Miniproject">View Demo</a>
    ·
    <a href="https://github.com/jasoninirio/Software-Miniproject/issues">Report Bug</a>
  </p>
</p>

## About The Project / Overview
This project implements an app called *healthi* that allows users to determine the amount of calories in a food item by scanning its barcode and add scanned food items to recipes. The first time the user launches the app, they will be prompted to sign in via their Google account. This will create a profile for the user, and they will be able to store their own personal recipes as well as keep track of all of the items they have scanned. The app’s interface consists of three pages: the home page will allow the user to browse their history of previously scanned food items (center page), the profile page displays the user's existing recipes as well as an option create new recipes (right page), and the camera page provides the user with a barcode scanner to scan a food item and add it to an existing recipe (left page).

<p align="center">
  <img src="/images/camera.jpg" height = "500">
  <img src="/images/history.jpg" height = "500">
  <img src="/images/recipes.jpg" height = "500">
</p>

This app was developed using Flutter by Google. In addition, it utilizes Firebase (also by Google) to allow users to create their own profiles and store personalized recipes. The information for scanned food items are obtained from the FoodData Central API through REST access. 


### Built With

* [Firebase](https://firebase.google.com/)
* [Flutter](https://flutter.dev/)
* [REST API](https://restfulapi.net/)
* [FDA FoodData API](https://fdc.nal.usda.gov/api-guide.html)

## Resources and Dependencies
[Applying Firebase to Flutter](https://firebase.google.com/docs/flutter/setup?platform=ios)  
[PageView Flutter Widget](https://medium.com/flutter-community/flutter-pageview-widget-e0f6c8092636)  
[Barcode Scanner](https://pub.dev/packages/flutter_barcode_scanner)  
[Calories Calculator](https://www.checkyourhealth.org/eat-healthy/cal_calculator.php)  
[Cloud Firestore](https://firebase.google.com/docs/firestore/quickstart?authuser=1)  
