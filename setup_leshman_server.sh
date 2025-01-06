#!/bin/bash

# Define the binary name and download URL
BINARY_NAME="leshman-demo-server.jar"
URL="https://ci.eclipse.org/leshan/job/leshan-ci/job/master/lastSuccessfulBuild/artifact/leshan-demo-server.jar"

# Function to install or update Java to the required version
install_java() {
    echo "Checking for Java installation..."
    REQUIRED_VERSION="17"

    # Check if Java is installed and its version
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
        if [ "$JAVA_VERSION" -lt "$REQUIRED_VERSION" ]; then
            echo "Java version $JAVA_VERSION detected. Upgrading to Java $REQUIRED_VERSION..."
            install_java_17
        else
            echo "Java $JAVA_VERSION is already installed."
        fi
    else
        echo "Java is not installed. Installing Java $REQUIRED_VERSION..."
        install_java_17
    fi
}

install_java_17() {
    if [ -x "$(command -v apt)" ]; then
        sudo apt update
        sudo apt install openjdk-17-jre -y
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install java-17-openjdk -y
    else
        echo "Unsupported package manager. Please install Java 17 manually."
        exit 1
    fi

    # Verify installation
    if ! java -version 2>&1 | grep -q "17"; then
        echo "Failed to install Java 17. Please install it manually."
        exit 1
    fi
    echo "Java 17 installed successfully."
}

# Install or update Java
install_java

# Check if the binary exists in the current folder
if [ ! -f "./$BINARY_NAME" ]; then
    echo "$BINARY_NAME not found in the current folder. Downloading..."
    wget "$URL" -O "$BINARY_NAME"

    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Failed to download $BINARY_NAME. Please check the URL and your internet connection."
        exit 1
    fi

    # Make the binary executable
    chmod +x "$BINARY_NAME"
    echo "$BINARY_NAME downloaded and made executable."
else
    echo "$BINARY_NAME already exists. Skipping download."
fi

# Run the server
java -jar "$BINARY_NAME"

# Check if the server started successfully
if [ $? -ne 0 ]; then
    echo "Failed to run $BINARY_NAME. Please check for errors."
    exit 1
else
    echo "$BINARY_NAME is running."
fi

