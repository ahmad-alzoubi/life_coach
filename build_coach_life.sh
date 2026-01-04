#!/bin/bash

# ===================================
# Coach Life App Build Script
# ===================================
# This script automates the Flutter build process for Coach Life App,
# handling environment validation, dependency management, build configuration,
# and App Store preparation with custom fixes for known issues.
# 
# Usage: ./build_coach_life.sh [options]
# 
# Options:
#   --non-interactive    Run in non-interactive mode with default settings
#   --help               Display this help message

# ===== Configuration =====
APP_NAME="Coach Life"
PROJECT_DIR="$(pwd)"
BUILD_DIR="$PROJECT_DIR/build"
IOS_BUILD_DIR="$BUILD_DIR/ios"
ANDROID_BUILD_DIR="$BUILD_DIR/android"
LOG_FILE="$BUILD_DIR/build_log_$(date +%Y%m%d_%H%M%S).log"
CLEANUP_SCRIPT="$PROJECT_DIR/cleanup.sh"
INTERACTIVE=true
MIN_DISK_SPACE=10 # GB

# Default settings (used in non-interactive mode)
BUILD_IOS=true
BUILD_ANDROID=false
BUILD_TYPE="release"
CLEAN_BUILD=true
CREATE_IPA=true
IOS_DISTRIBUTION_TYPE="app-store"
VERSION_UPDATE=false
BUILD_NUMBER_UPDATE=false
UPLOAD_TO_APPSTORE=false

# ===== Helper Functions =====

# Logging functions
log_info() {
    echo -e "\033[0;34m[INFO] $1\033[0m"
    echo "[INFO] $(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS] $1\033[0m"
    echo "[SUCCESS] $(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log_warning() {
    echo -e "\033[0;33m[WARNING] $1\033[0m"
    echo "[WARNING] $(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "\033[0;31m[ERROR] $1\033[0m"
    echo "[ERROR] $(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

# Setup logging
setup_logging() {
    mkdir -p "$BUILD_DIR"
    touch "$LOG_FILE"
    log_info "Build started at $(date)"
    log_info "Project directory: $PROJECT_DIR"
}

# Environment check functions
check_environment() {
    log_info "Checking environment..."
    
    # Check disk space
    check_disk_space
    
    # Check Flutter installation
    check_flutter_installation
    
    # Check platform-specific requirements
    if [ "$BUILD_IOS" = true ]; then
        if [[ "$OSTYPE" != "darwin"* ]]; then
            log_error "iOS builds require macOS. Current OS: $OSTYPE"
            exit 1
        fi
        check_xcode_installation
        check_cocoapods_installation
    fi
    
    # Check Firebase requirements
    check_flutterfire_installation
    
    log_success "Environment check completed successfully"
}

check_disk_space() {
    log_info "Checking available disk space..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        AVAILABLE_SPACE=$(df -g . | awk 'NR==2 {print $4}')
    else
        # Linux
        AVAILABLE_SPACE=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    fi
    
    if [ "$AVAILABLE_SPACE" -lt "$MIN_DISK_SPACE" ]; then
        log_warning "Low disk space: ${AVAILABLE_SPACE}GB available, ${MIN_DISK_SPACE}GB recommended"
        if [ "$INTERACTIVE" = true ]; then
            if ! prompt_yes_no "Disk space is low. Continue anyway?"; then
                log_error "Build aborted due to low disk space"
                exit 1
            fi
        fi
    else
        log_info "Disk space check passed: ${AVAILABLE_SPACE}GB available"
    fi
}

check_flutter_installation() {
    log_info "Checking Flutter installation..."
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter not found. Please install Flutter and add it to your PATH"
        exit 1
    fi
    
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    log_info "Flutter version: $FLUTTER_VERSION"
}

check_xcode_installation() {
    log_info "Checking Xcode installation..."
    
    if ! command -v xcodebuild &> /dev/null; then
        log_error "Xcode not found. Please install Xcode"
        exit 1
    fi
    
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    log_info "Xcode version: $XCODE_VERSION"
}

check_cocoapods_installation() {
    log_info "Checking CocoaPods installation..."
    
    if ! command -v pod &> /dev/null; then
        log_error "CocoaPods not found. Please install CocoaPods"
        exit 1
    fi
    
    POD_VERSION=$(pod --version)
    log_info "CocoaPods version: $POD_VERSION"
}

check_flutterfire_installation() {
    log_info "Checking FlutterFire CLI installation..."
    
    if ! command -v flutterfire &> /dev/null; then
        log_warning "FlutterFire CLI not found. Some Firebase features may not work correctly"
        if [ "$INTERACTIVE" = true ]; then
            if prompt_yes_no "Would you like to install FlutterFire CLI?"; then
                log_info "Installing FlutterFire CLI..."
                dart pub global activate flutterfire_cli
                if ! command -v flutterfire &> /dev/null; then
                    log_warning "FlutterFire CLI installation may have succeeded but it's not in your PATH"
                    log_info "You may need to add the following to your shell profile:"
                    log_info "  export PATH=\"\$PATH:\$HOME/.pub-cache/bin\""
                else
                    log_success "FlutterFire CLI installed successfully"
                fi
            fi
        fi
    else
        log_info "FlutterFire CLI is installed"
    fi
}

# User input functions
prompt_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

select_option() {
    local options=("$@")
    local selected=0
    local count=${#options[@]}
    
    # Display options
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[$i]}"
    done
    
    # Get user selection
    while true; do
        read -p "Select an option (1-$count): " selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "$count" ]; then
            selected=$((selection-1))
            break
        else
            echo "Invalid selection. Please enter a number between 1 and $count."
        fi
    done
    
    echo "${options[$selected]}"
}

prompt_platform() {
    log_info "Select platforms to build for:"
    echo "1. iOS only"
    echo "2. Android only"
    echo "3. Both iOS and Android"
    
    while true; do
        read -p "Select an option (1-3): " platform_choice
        case $platform_choice in
            1)
                BUILD_IOS=true
                BUILD_ANDROID=false
                break
                ;;
            2)
                BUILD_IOS=false
                BUILD_ANDROID=true
                break
                ;;
            3)
                BUILD_IOS=true
                BUILD_ANDROID=true
                break
                ;;
            *)
                echo "Invalid selection. Please enter a number between 1 and 3."
                ;;
        esac
    done
    
    if [ "$BUILD_IOS" = true ] && [ "$BUILD_ANDROID" = true ]; then
        log_info "Building for both iOS and Android"
    elif [ "$BUILD_IOS" = true ]; then
        log_info "Building for iOS only"
    else
        log_info "Building for Android only"
    fi
}

prompt_build_type() {
    log_info "Select build type:"
    BUILD_TYPE=$(select_option "debug" "profile" "release")
    log_info "Selected build type: $BUILD_TYPE"
}

prompt_ios_distribution_type() {
    log_info "Select iOS distribution type:"
    IOS_DISTRIBUTION_TYPE=$(select_option "app-store" "ad-hoc" "enterprise" "development")
    log_info "Selected iOS distribution type: $IOS_DISTRIBUTION_TYPE"
    
    # Ask about IPA creation
    if prompt_yes_no "Create IPA file?"; then
        CREATE_IPA=true
        log_info "Will create IPA file"
    else
        CREATE_IPA=false
        log_info "Will not create IPA file"
    fi
}

prompt_version_info() {
    # Get current version from pubspec.yaml
    CURRENT_VERSION=$(grep -E "^version:" pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
    CURRENT_BUILD_NUMBER=$(grep -E "^version:" pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)
    
    log_info "Current version: $CURRENT_VERSION+$CURRENT_BUILD_NUMBER"
    
    if prompt_yes_no "Update version number?"; then
        VERSION_UPDATE=true
        read -p "Enter new version number (current: $CURRENT_VERSION): " NEW_VERSION
        if [ -z "$NEW_VERSION" ]; then
            NEW_VERSION=$CURRENT_VERSION
            log_info "Using current version: $NEW_VERSION"
        else
            log_info "New version: $NEW_VERSION"
        fi
    else
        VERSION_UPDATE=false
        NEW_VERSION=$CURRENT_VERSION
        log_info "Keeping current version: $NEW_VERSION"
    fi
    
    if prompt_yes_no "Update build number?"; then
        BUILD_NUMBER_UPDATE=true
        read -p "Enter new build number (current: $CURRENT_BUILD_NUMBER): " NEW_BUILD_NUMBER
        if [ -z "$NEW_BUILD_NUMBER" ]; then
            NEW_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
            log_info "Incrementing build number to: $NEW_BUILD_NUMBER"
        else
            log_info "New build number: $NEW_BUILD_NUMBER"
        fi
    else
        BUILD_NUMBER_UPDATE=false
        NEW_BUILD_NUMBER=$CURRENT_BUILD_NUMBER
        log_info "Keeping current build number: $NEW_BUILD_NUMBER"
    fi
    
    # Update pubspec.yaml if needed
    if [ "$VERSION_UPDATE" = true ] || [ "$BUILD_NUMBER_UPDATE" = true ]; then
        log_info "Updating pubspec.yaml with version: $NEW_VERSION+$NEW_BUILD_NUMBER"
        sed -i.bak "s/^version: .*/version: $NEW_VERSION+$NEW_BUILD_NUMBER/" pubspec.yaml
        rm pubspec.yaml.bak
    fi
}

prompt_clean_build() {
    if prompt_yes_no "Perform clean build? (Recommended)"; then
        CLEAN_BUILD=true
        log_info "Will perform clean build"
    else
        CLEAN_BUILD=false
        log_info "Will not perform clean build"
    fi
}

confirm_selections() {
    echo ""
    log_info "Build Configuration Summary:"
    echo "- Platforms: $([ "$BUILD_IOS" = true ] && echo "iOS" || echo "")$([ "$BUILD_IOS" = true ] && [ "$BUILD_ANDROID" = true ] && echo " and " || echo "")$([ "$BUILD_ANDROID" = true ] && echo "Android" || echo "")"
    echo "- Build Type: $BUILD_TYPE"
    echo "- Clean Build: $([ "$CLEAN_BUILD" = true ] && echo "Yes" || echo "No")"
    echo "- Version: $NEW_VERSION+$NEW_BUILD_NUMBER"
    
    if [ "$BUILD_IOS" = true ]; then
        echo "- iOS Distribution: $IOS_DISTRIBUTION_TYPE"
        echo "- Create IPA: $([ "$CREATE_IPA" = true ] && echo "Yes" || echo "No")"
    fi
    
    if ! prompt_yes_no "Proceed with these settings?"; then
        log_info "Build cancelled by user"
        exit 0
    fi
}

# Build process functions
clean_project() {
    log_info "Cleaning project..."
    
    # Clean Flutter
    flutter clean >> "$LOG_FILE" 2>&1
    
    # Clean iOS specific
    if [ "$BUILD_IOS" = true ] && [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Cleaning iOS build artifacts..."
        
        # Clean DerivedData
        clean_derived_data
        
        # Clean Pods
        if [ -d "ios/Pods" ]; then
            log_info "Removing Pods directory..."
            rm -rf ios/Pods ios/Podfile.lock
        fi
    fi
    
    # Clean Android specific
    if [ "$BUILD_ANDROID" = true ]; then
        log_info "Cleaning Android build artifacts..."
        if [ -d "android/.gradle" ]; then
            rm -rf android/.gradle
        fi
        if [ -d "android/app/build" ]; then
            rm -rf android/app/build
        fi
    fi
    
    log_success "Project cleaned successfully"
}

clean_derived_data() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Cleaning Xcode DerivedData..."
        DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
        
        # Find and remove only the directories related to this project
        find "$DERIVED_DATA_PATH" -name "*Runner*" -type d -exec rm -rf {} \; 2>/dev/null || true
        
        log_info "Xcode DerivedData cleaned"
    fi
}

get_dependencies() {
    log_info "Getting dependencies..."
    
    # Flutter pub get
    flutter pub get >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        log_error "Failed to get Flutter dependencies"
        exit 1
    fi
    
    # iOS pod install
    if [ "$BUILD_IOS" = true ] && [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Installing CocoaPods dependencies..."
        (cd ios && pod install --repo-update) >> "$LOG_FILE" 2>&1
        if [ $? -ne 0 ]; then
            log_error "Failed to install CocoaPods dependencies"
            fix_pod_issues
            log_info "Retrying pod install..."
            (cd ios && pod install --repo-update) >> "$LOG_FILE" 2>&1
            if [ $? -ne 0 ]; then
                log_error "Failed to install CocoaPods dependencies after retry"
                exit 1
            fi
        fi
    fi
    
    log_success "Dependencies installed successfully"
}

setup_firebase() {
    if command -v flutterfire &> /dev/null; then
        log_info "Configuring Firebase..."
        flutterfire configure >> "$LOG_FILE" 2>&1
        if [ $? -ne 0 ]; then
            log_warning "Failed to configure Firebase. This may cause issues with Firebase services."
        else
            log_success "Firebase configured successfully"
        fi
    else
        log_warning "FlutterFire CLI not found. Skipping Firebase configuration."
    fi
}

build_ios() {
    if [ "$BUILD_IOS" = true ]; then
        log_info "Building iOS app ($BUILD_TYPE)..."
        
        # Build Flutter iOS app
        flutter build ios --$BUILD_TYPE >> "$LOG_FILE" 2>&1
        
        # Check for build errors
        if [ $? -ne 0 ]; then
            log_error "iOS build failed"
            handle_ios_build_errors
        else
            log_success "iOS build completed successfully"
        fi
    fi
}

build_android() {
    if [ "$BUILD_ANDROID" = true ]; then
        log_info "Building Android app ($BUILD_TYPE)..."
        
        # Build Flutter Android app
        if [ "$BUILD_TYPE" = "release" ]; then
            flutter build apk --$BUILD_TYPE >> "$LOG_FILE" 2>&1
        else
            flutter build apk --$BUILD_TYPE >> "$LOG_FILE" 2>&1
        fi
        
        # Check for build errors
        if [ $? -ne 0 ]; then
            log_error "Android build failed"
            exit 1
        else
            log_success "Android build completed successfully"
            log_info "APK location: $PROJECT_DIR/build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
        fi
    fi
}

create_ipa() {
    if [ "$BUILD_IOS" = true ] && [ "$CREATE_IPA" = true ] && [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Creating IPA file for $IOS_DISTRIBUTION_TYPE distribution..."
        
        # Create build directory if it doesn't exist
        mkdir -p "$IOS_BUILD_DIR/ipa"
        
        # Archive the app
        log_info "Archiving app..."
        xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release archive -archivePath "$IOS_BUILD_DIR/Runner.xcarchive" >> "$LOG_FILE" 2>&1
        
        if [ $? -ne 0 ]; then
            log_error "Failed to archive app"
            return 1
        fi
        
        # Create export options plist
        create_export_options_plist
        
        # Export the archive to IPA
        log_info "Exporting archive to IPA..."
        xcodebuild -exportArchive -archivePath "$IOS_BUILD_DIR/Runner.xcarchive" -exportOptionsPlist "$IOS_BUILD_DIR/ExportOptions.plist" -exportPath "$IOS_BUILD_DIR/ipa" >> "$LOG_FILE" 2>&1
        
        if [ $? -ne 0 ]; then
            log_error "Failed to export IPA"
            return 1
        fi
        
        # Rename IPA to match app name
        mv "$IOS_BUILD_DIR/ipa/Runner.ipa" "$IOS_BUILD_DIR/ipa/coach_life.ipa" 2>/dev/null || true
        
        log_success "IPA created successfully at $IOS_BUILD_DIR/ipa/coach_life.ipa"
        
        # Fix IPA for App Store
        fix_ipa_for_app_store
        
        return 0
    fi
}

create_export_options_plist() {
    log_info "Creating export options plist..."
    
    # Determine method based on distribution type
    local method=""
    case "$IOS_DISTRIBUTION_TYPE" in
        "app-store")
            method="app-store"
            ;;
        "ad-hoc")
            method="ad-hoc"
            ;;
        "enterprise")
            method="enterprise"
            ;;
        "development")
            method="development"
            ;;
        *)
            method="app-store"
            ;;
    esac
    
    # Create ExportOptions.plist
    cat > "$IOS_BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$method</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
EOF

    log_info "Export options plist created with method: $method"
}

fix_ipa_for_app_store() {
    if [ "$BUILD_IOS" = true ] && [ "$CREATE_IPA" = true ] && [ "$IOS_DISTRIBUTION_TYPE" = "app-store" ]; then
        log_info "Applying fixes for App Store submission..."
        
        # Define IPA path
        IPA_PATH="$IOS_BUILD_DIR/ipa/coach_life.ipa"
        
        # Run cleanup script if it exists
        if [ -f "$CLEANUP_SCRIPT" ]; then
            log_info "Running cleanup script to fix ._Symbols issue"
            bash "$CLEANUP_SCRIPT"
        else
            # Implement inline fix for ._Symbols issue
            log_info "Cleanup script not found, applying inline fix for ._Symbols issue"
            fix_symbols_issue "$IPA_PATH"
        fi
        
        log_success "App Store fixes applied successfully"
    fi
}

fix_symbols_issue() {
    local ipa_path="$1"
    if [ -z "$ipa_path" ]; then
        ipa_path="$IOS_BUILD_DIR/ipa/coach_life.ipa"
    fi
    
    if [ -f "$ipa_path" ]; then
        log_info "Checking for unwanted files like ._Symbols in $ipa_path"
        if unzip -l "$ipa_path" | grep -q "._Symbols"; then
            log_info "Found ._Symbols directory, removing it..."
            zip -d "$ipa_path" "._Symbols/" >> "$LOG_FILE" 2>&1
            log_success "._Symbols directory removed from IPA"
        else
            log_info "No ._Symbols directory found in IPA"
        fi
    else
        log_warning "IPA not found at $ipa_path"
    fi
}

handle_ios_build_errors() {
    # Check for disk I/O errors
    if grep -q "disk I/O error" "$LOG_FILE"; then
        log_info "Detected disk I/O error, attempting to fix..."
        handle_disk_io_errors
        
        log_info "Retrying iOS build..."
        flutter build ios --$BUILD_TYPE >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            log_success "iOS build completed successfully after fixing disk I/O error"
            return 0
        fi
    fi
    
    # Check for other common errors
    if grep -q "Error running pod install" "$LOG_FILE"; then
        log_info "Detected pod installation issues, attempting to fix..."
        fix_pod_issues
        
        log_info "Retrying iOS build..."
        flutter build ios --$BUILD_TYPE >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            log_success "iOS build completed successfully after fixing pod issues"
            return 0
        fi
    fi
    
    # If we get here, we couldn't fix the build errors
    log_error "Could not automatically fix build issues. Manual intervention required."
    exit 1
}

handle_disk_io_errors() {
    log_info "Handling disk I/O errors..."
    
    # Clean Xcode DerivedData
    clean_derived_data
    
    # Clean Xcode caches
    log_info "Cleaning Xcode caches..."
    rm -rf "$HOME/Library/Caches/com.apple.dt.Xcode" 2>/dev/null || true
    
    # Reset Xcode package cache
    log_info "Resetting Xcode package cache..."
    xcrun simctl delete unavailable 2>/dev/null || true
    
    # Fix permissions
    log_info "Fixing permissions for DerivedData folder..."
    if [ -d "$HOME/Library/Developer/Xcode/DerivedData" ]; then
        chmod -R 755 "$HOME/Library/Developer/Xcode/DerivedData" 2>/dev/null || true
    fi
    
    log_info "Disk I/O error handling completed"
}

fix_pod_issues() {
    log_info "Fixing CocoaPods issues..."
    
    # Remove Pods directory and Podfile.lock
    if [ -d "ios/Pods" ]; then
        rm -rf ios/Pods ios/Podfile.lock
    fi
    
    # Deintegrate pods
    (cd ios && pod deintegrate) >> "$LOG_FILE" 2>&1 || true
    
    # Setup pods
    (cd ios && pod setup) >> "$LOG_FILE" 2>&1
    
    # Clean CocoaPods cache
    pod cache clean --all >> "$LOG_FILE" 2>&1 || true
    
    log_info "CocoaPods issues fixed"
}

upload_to_app_store() {
    if [ "$BUILD_IOS" = true ] && [ "$CREATE_IPA" = true ] && [ "$IOS_DISTRIBUTION_TYPE" = "app-store" ]; then
        log_info "Preparing to upload to App Store Connect..."
        
        # Check if altool or xcrun notarytool is available
        if command -v xcrun &> /dev/null; then
            log_info "Using xcrun to upload IPA..."
            
            # Prompt for Apple ID and password
            read -p "Enter your Apple ID: " APPLE_ID
            read -s -p "Enter your app-specific password: " APP_PASSWORD
            echo ""
            
            # Upload IPA
            log_info "Uploading IPA to App Store Connect (this may take a while)..."
            xcrun altool --upload-app --type ios --file "$IOS_BUILD_DIR/ipa/coach_life.ipa" --username "$APPLE_ID" --password "$APP_PASSWORD" >> "$LOG_FILE" 2>&1
            
            if [ $? -eq 0 ]; then
                log_success "IPA uploaded successfully to App Store Connect"
            else
                log_error "Failed to upload IPA to App Store Connect"
                log_info "Please check the log file for details: $LOG_FILE"
            fi
        else
            log_error "xcrun not found. Cannot upload to App Store Connect"
            log_info "Please upload the IPA manually using Transporter or Xcode"
        fi
    fi
}

# User input handling
prompt_user_inputs() {
    # Platform selection
    prompt_platform
    
    # Build type
    prompt_build_type
    
    # Version information
    prompt_version_info
    
    # iOS-specific options
    if [ "$BUILD_IOS" = true ]; then
        prompt_ios_distribution_type
    fi
    
    # Clean build option
    prompt_clean_build
    
    # Confirm selections
    confirm_selections
}

# Parse command line arguments
parse_arguments() {
    for arg in "$@"; do
        case $arg in
            --non-interactive)
                INTERACTIVE=false
                log_info "Running in non-interactive mode with default settings"
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_warning "Unknown argument: $arg"
                ;;
        esac
    done
}

# Show help message
show_help() {
    echo "Coach Life App Build Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --non-interactive    Run in non-interactive mode with default settings"
    echo "  --help               Display this help message"
    echo ""
    echo "Default settings (non-interactive mode):"
    echo "  - Build for iOS only"
    echo "  - Release build"
    echo "  - Clean build enabled"
    echo "  - Create IPA for App Store distribution"
    echo "  - No version or build number updates"
    echo "  - No automatic upload to App Store"
}

# Show welcome message
show_welcome_message() {
    echo "========================================"
    echo "  Coach Life App Build Script"
    echo "========================================"
    echo "This script will guide you through the process of building the Coach Life app"
    echo "for iOS and/or Android platforms, with options for creating distribution packages."
    echo ""
    echo "Log file: $LOG_FILE"
    echo "========================================"
    echo ""
}

# Show build summary
show_build_summary() {
    echo ""
    echo "========================================"
    echo "  Build Summary"
    echo "========================================"
    
    if [ "$BUILD_IOS" = true ]; then
        if [ -d "$IOS_BUILD_DIR" ]; then
            echo "iOS Build: SUCCESS"
            if [ "$CREATE_IPA" = true ] && [ -f "$IOS_BUILD_DIR/ipa/coach_life.ipa" ]; then
                echo "IPA Location: $IOS_BUILD_DIR/ipa/coach_life.ipa"
            fi
        else
            echo "iOS Build: FAILED"
        fi
    fi
    
    if [ "$BUILD_ANDROID" = true ]; then
        if [ -f "$PROJECT_DIR/build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk" ]; then
            echo "Android Build: SUCCESS"
            echo "APK Location: $PROJECT_DIR/build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
        else
            echo "Android Build: FAILED"
        fi
    fi
    
    echo ""
    echo "Build Log: $LOG_FILE"
    echo "========================================"
}

# Perform post-build actions
perform_post_build_actions() {
    # Validate build artifacts
    validate_build_artifacts
    
    # Offer App Store upload if applicable
    if [ "$BUILD_IOS" = true ] && [ "$CREATE_IPA" = true ] && [ "$IOS_DISTRIBUTION_TYPE" = "app-store" ] && [ "$INTERACTIVE" = true ]; then
        if prompt_yes_no "Would you like to upload the IPA to App Store Connect?"; then
            UPLOAD_TO_APPSTORE=true
            upload_to_app_store
        fi
    fi
}

# Validate build artifacts
validate_build_artifacts() {
    log_info "Validating build artifacts..."
    
    if [ "$BUILD_IOS" = true ] && [ "$CREATE_IPA" = true ]; then
        if [ ! -f "$IOS_BUILD_DIR/ipa/coach_life.ipa" ]; then
            log_warning "IPA file not found at expected location: $IOS_BUILD_DIR/ipa/coach_life.ipa"
        else
            log_success "IPA file validated: $IOS_BUILD_DIR/ipa/coach_life.ipa"
        fi
    fi
    
    if [ "$BUILD_ANDROID" = true ]; then
        if [ ! -f "$PROJECT_DIR/build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk" ]; then
            log_warning "APK file not found at expected location: $PROJECT_DIR/build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
        else
            log_success "APK file validated: $PROJECT_DIR/build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
        fi
    fi
}

# Main workflow
main() {
    # Parse arguments
    parse_arguments "$@"
    
    # Setup logging
    setup_logging
    
    # Display welcome message
    show_welcome_message
    
    # Check environment
    check_environment
    
    # Get user inputs (if interactive)
    if [ "$INTERACTIVE" = true ]; then
        prompt_user_inputs
    fi
    
    # Clean project if requested
    if [ "$CLEAN_BUILD" = true ]; then
        clean_project
    fi
    
    # Get dependencies
    get_dependencies
    
    # Setup Firebase
    setup_firebase
    
    # Build for selected platforms
    if [ "$BUILD_IOS" = true ]; then
        build_ios
        if [ "$CREATE_IPA" = true ]; then
            create_ipa
        fi
    fi
    
    if [ "$BUILD_ANDROID" = true ]; then
        build_android
    fi
    
    # Post-build actions
    perform_post_build_actions
    
    # Show build summary
    show_build_summary
    
    log_info "Build process completed at $(date)"
}

# Execute main function
main "$@"
