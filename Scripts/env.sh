# Shared toolchain settings. The macros SwiftUI now ships with (@State, @Bindable…)
# need a full Xcode toolchain; Command Line Tools alone cannot expand them.
if [ -d "/Applications/Xcode-beta.app/Contents/Developer" ]; then
  export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"
elif [ -d "/Applications/Xcode.app/Contents/Developer" ]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi
