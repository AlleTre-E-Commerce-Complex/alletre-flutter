# Alletre App

## Development Setup

### Prerequisites

1. **JDK Setup**
   - Download and install JDK 11 from [Oracle's website](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)
   - Set up JAVA_HOME environment variable:
     
     For macOS/Linux:
     ```bash
     export JAVA_HOME=/path/to/your/jdk
     export PATH=$JAVA_HOME/bin:$PATH
     ```
     
     For Windows:
     ```
     Set JAVA_HOME=C:\path\to\your\jdk
     Add %JAVA_HOME%\bin to your PATH
     ```

2. **Flutter Setup**
   - Follow the [Flutter installation guide](https://flutter.dev/docs/get-started/install)
   - Run `flutter doctor` to verify your setup

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/fahad7tt/alletre.git
   cd alletre
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Development Guidelines

- Ensure you have the correct JDK version (11) installed
- Do not commit JDK or other large binary files to the repository
- Use the provided .gitignore file to prevent accidental commits of large files
