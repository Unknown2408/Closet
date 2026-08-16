# Closet App 🧥👖

<p align="center">
  <img src="https://img.shields.io/badge/iOS-16.0+-blue?style=for-the-badge&logo=apple" alt="iOS 16.0+">
  <img src="https://img.shields.io/badge/SwiftUI-Blue?style=for-the-badge&logo=swift" alt="SwiftUI">
</p>

## Overview

**Closet** is a beautifully designed iOS application built entirely with **SwiftUI** that acts as your personal digital wardrobe. It helps you keep track of your clothing inventory, organize them by brands and styles, and intelligently suggests outfits based on color matching rules. 

Whether you're trying to figure out what to wear for the day or simply want to catalog your fashion collection, Closet makes wardrobe management effortless and visually pleasing.

## Features ✨

- **Digital Inventory:** Add, edit, and delete clothes. Specify details like brand, type, style, color, and seasonality.
- **Outfit Creation:** Combine your clothing items into custom outfits and save them for later.
- **Smart Color Matching:** Automatically receive cascading clothing suggestions for your outfits based on advanced color theory and compatibility rules.
- **Dynamic Brand Management:** Add new brands on the fly, tailoring the app to your specific shopping habits.
- **Favorites:** Mark your best outfits and favorite clothes for quick access.
- **Local Persistence:** Your data is securely saved locally on your device, ensuring privacy and fast loading times.
- **Sleek UI:** Smooth transitions, video splash screen (`ClosetIntro`), and a modern dark-mode optimized aesthetic.

## Technologies Used 🛠

- **Swift 5 & SwiftUI:** For a declarative, modern user interface and robust application logic.
- **Observation Framework (`@Observable`):** Utilized for highly efficient state management across the app (`ClosetManager`).
- **Foundation (Codable & FileManager):** For robust, local JSON data persistence of the user's inventory and outfits.
- **AVKit:** For custom splash screen video playback.

## Architecture

The app follows a modern architecture relying on a central `ClosetManager` as the single source of truth. 
It uses the `@Observable` macro to ensure the UI stays perfectly in sync with the underlying data models (`Cloth`, `Outfit`, `ClothingType`, `Style`, `Season`). Data is persisted to the device's Document Directory as JSON.

## Requirements

- **iOS:** 16.0 or newer
- **Xcode:** 14.0 or newer
- **Swift:** 5.7+

## How to Run locally 🚀

1. Clone this repository:
   ```bash
   git clone https://github.com/Unknown2408/Closet.git
   ```
2. Open the project in Xcode:
   ```bash
   cd Closet
   open Closet.xcodeproj
   ```
3. Select your preferred iOS Simulator or connected device.
4. Hit `Cmd + R` or click the **Play** button to build and run the app.

---
*Created by Federico Busciglio.*
