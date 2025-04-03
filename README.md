# Home Pilot App for Graduation Thesis aaaaa
A Mobile Application in Swift for Energy Consumption Tracking

This project presents an iOS application that tracks and analyzes energy usage by dividing different home devices into three main areas. These are electricity, water, and natural gas. Home Pilot App built with **Swift + UIKit**, powered by **Firebase Authentication**, **Core Data** and **Swift Charts**.

---

## 📸 Screenshots

### Home Screen
<img width="361" alt="Ekran Resmi 2025-04-03 20 22 53" src="https://github.com/user-attachments/assets/02201313-f863-479e-bfb6-9d82295bace0" />

### Charts Screen
<img width="208" alt="Ekran Resmi 2025-04-03 20 50 25" src="https://github.com/user-attachments/assets/9e0da768-725f-45fe-b6bf-c0d3318205cc" />
<img width="424" alt="Ekran Resmi 2025-04-03 20 50 51" src="https://github.com/user-attachments/assets/1c223ea8-0536-4839-a1f2-78646638ac3f" />

### Device Screen
<img width="775" alt="Ekran Resmi 2025-04-03 20 46 28" src="https://github.com/user-attachments/assets/bc640637-83d3-4f58-9dc8-09e1e3aa09f9" />

---

## 🧾 Documentation

📄 [Click here to access the full thesis and get detailed information about the project.](https://drive.google.com/file/d/1e5l1uUiDTU2wsMvCk38ygnz_gWE_ctCk/view?usp=sharing)

---

## 📦 Features

- 🔐 Secure Login: Integration with Firebase Authentication and Google Sign-In.
- 📊 Interactive Charts: Weekly/monthly energy consumption visualization using Swift Charts.
- ⚡ Device-Based Tracking: Consumption calculation for individual devices across electricity, water, and natural gas.
- 💾 Data Storage with Core Data: Local storage of user and device data.
- 🔄 Time Filtering: Option to view data by week, month, or all time in charts.
- 📱 Dynamic Interface: Auto-scrolling cards and user-friendly segmented control.
- 📤 Real-Time Updates: Instant data refresh using NotificationCenter.
- 🧩 Modular Architecture: Sustainable code structure with MVC design and Singleton pattern.

---

## 📚 Technologies Used

- Swift, UIKit
- Core Data
- Firebase Authentication + Google Sign-In
- Swift Charts
- MVC Design Pattern

---

## 🗂️ Project Structure
```bash
HomePilotApp/
├── AppDelegate.swift               # App lifecycle & Firebase initialization
├── SceneDelegate.swift            # Scene session management
├── Main.storyboard                # UI design with 6 screens
├── GoogleService-Info.plist       # Firebase configuration file
├── Models/                        # Data logic layer
│   ├── Device.swift
│   ├── DeviceMetric.swift
│   ├── DeviceUsageResult.swift
│   └── User.swift
├── Views/                         # Reusable UI components
│   ├── SourceCardCell.swift
│   ├── DeviceCardCell.swift
│   ├── DynamicMetricView.swift
│   └── MarkerView.swift
├── Controllers/                   # View controllers for each screen
│   ├── HomeViewController.swift
│   ├── DeviceViewController.swift
│   ├── ChartsViewController.swift
│   ├── LoginViewController.swift
│   ├── SignUpViewController.swift
│   └── TabBarController.swift
├── CoreData/                      # Data persistence
│   ├── HomePilotApp.xcdatamodeld
│   └── CoreDataManager.swift
└── Extensions/
    └── Notification.Name+Ext.swift

```
---

## 🛠️ Installation

1. To clone and start the project:
   
```bash
git clone https://github.com/helinguler/GraduationThesis-HomePilotApp.git
cd GraduationThesis-HomePilotApp
open HomePilotApp.xcodeproj
```

2. Add your own GoogleService-Info.plist file to the project for Firebase integration.

3. Check package dependencies and build the project:
Firebase  
Swift Charts

---

## 👩🏻‍💻 Developer

**Helin Güler**  
- [LinkedIn Profilim](https://www.linkedin.com/in/helin-guler)  
- [GitHub Profilim](https://github.com/helinguler)

