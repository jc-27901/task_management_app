# Task Management App

A feature-rich Flutter task management application showcasing modern architecture and best practices. This app demonstrates the implementation of MVVM architecture, state management with Riverpod, local data persistence using both SQLite and Hive, and responsive design principles.

## Features

- **Task Management**
  - Create, read, update, and delete tasks
  - Mark tasks as complete/incomplete
  - Set task priorities and due dates
  - Categorize tasks with custom labels
  - Add task descriptions and attachments

- **Technical Features**
  - MVVM Architecture for clean separation of concerns
  - Riverpod for state management
  - SQLite for structured data storage
  - Hive for high-performance key-value storage
  - Responsive design that works across all screen sizes
  - Offline-first architecture
  - Dark/Light theme support

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

## Getting Started

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/task_management_app.git
cd task_management_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the database migrations**
```bash
flutter pub run build_runner build
```

4. **Run the app**
```bash
flutter run
```
