# Asteroid XR Simuation

## This is a Final Year Project for Computer Science (Infrastructure) TU857

# What is it?
The aim of this project is to create a MR (Mixed Reality) visual tool for the purpose of 
conveying asteroid information by visualising asteroids passing the Earth. The intent is to 
provide people with knowledge of what is around this planet through an XR headset such as 
the __Meta Quest 3__.

This is a unique idea as it will provide an MR experience of the Earth having numerous 
asteroids orbiting it while harnessing the passthrough abilities of the __Meta Quest 3__ headset to 
make the Earth/Asteroids appear around you in the real world. Additionally, interaction using 
the headset controllers allows for viewing and searching of asteroids.

This uses open data provided by NASAs APIs to simulate asteroids, such as NeoWs, 
Horizons System and Small-Body Database Lookup. This will be accomplished using only a 
game engine called Godot that is using the GDScript language. 


# Installation
## 1. Installation via the Pre-Built APK Provided
- Download the *Asteroid-XR-Simulation.apk* 
- Install and use ADB from Meta ([Use ADB with Meta Quest](https://developers.meta.com/horizon/documentation/native/android/ts-adb/))
- Connect the Meta Quest 3 Headset to your Computer
- Run the ADB command to install to the headset:
- ```adb install Asteroid-XR-Simulation.apk```

## 2. Run from the Godot Editor
- Clone this Repo
- This project requires CA certificates to function
- Download *cacert.pem* ([CA certificates extracted from Mozilla](https://curl.se/docs/caextract.html))
- Place *cacert.pem* into the asteroid-xr-simulation/ directory
- Connect the Meta Quest 3 to the Computer using the standard process
- From Godot, Run the Project