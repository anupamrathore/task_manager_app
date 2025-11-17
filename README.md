# task_manager_app

A simple cross-platform Flutter application with user authentication, CRUD tasks (create task, modify task & delete task) and backend using Back4App (BaaS).

## Overview

The Task Manager App is a lightweight yet full-stack mobile application built with Flutter.
It allows users to:

- *Register & log in securely*

- *Create, read, update, and delete personal tasks*

- *Store all data on Back4App using Parse Server*

- *Access their tasks across devices*

- The app is built for Android (via Android Studio), Chrome (web), and other Flutter-supported platforms.

  **Features**
  - *Authentication*
    - User Registration
    - Secure Login
    - Persistent Login (auto-login using Parse session token)
    - Logout functionality

  - *Task Management*
    - Add new tasks (title + description)
    - Edit existing tasks
    - Mark tasks as completed
    - Delete tasks
    - Only logged-in users can manage their own tasks

  - *Backend Integration (Back4App / Parse)*
    - All users and tasks stored in cloud
    - Uses Parse REST API via parse_server_sdk_flutter
    - Each task is linked to the logged-in user via a owner pointer

**Tech Stack**
  - Layer	Technology
  - UI/Frontend	Flutter (Material UI)
  - Backend	Back4App (Parse Server)
  - Auth	Parse Sessions & _User table
  - Database	Back4App Cloud DB (_User, Task)
  - Language	Dart


**Project Folder Structure**
<img width="299" height="285" alt="image" src="https://github.com/user-attachments/assets/8fd8b505-57be-4818-8ace-dc6d43c38416" />


 **Setup & Installation**
- Clone the Repository
  git clone https://github.com/<your-username>/task_manager_app.git
  cd task_manager_app

- Install Dependencies
  flutter pub get

- Configure Back4App Keys
  - Create lib/services/parse_init.dart (already part of the app) and update:
  - const String appId = "<YOUR_APP_ID>";
  - const String clientKey = "<YOUR_CLIENT_KEY>";
  - const String parseServerUrl = "https://parseapi.back4app.com/";

**Run the App**
  - Android Device / Emulator
  - flutter run -d <device-id>
  - Web (Chrome): flutter run -d chrome

**Back4App Database Structure**
 - _User Table

   - Handled automatically by Parse.
       - Each user has:
          username
          password (hashed)
          sessionToken

Task Table (created automatically)
Field	Type	Description
objectId	String	Auto
title	String	Task title
description	String	Task details
completed	Boolean	True/False
owner	Pointer<_User>	User who created task
