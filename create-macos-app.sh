#!/usr/bin/env bash
# create-macos-app.sh - Creates a macOS AppKit application from template

set -e

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 'app name'"
  echo "Example: $0 'My Amazing App'"
  exit 1
fi

APP_NAME="$1"

# Get organization identifier from user defaults or prompt user
ORG_IDENTIFIER=$(defaults read kopyl.appkit-starter-pack organization-identifier 2>/dev/null || echo "")

if [ -z "$ORG_IDENTIFIER" ]; then
  echo "Organization identifier not found in user defaults."
  echo -n "Enter your organization identifier (e.g., com.yourcompany, yourname): "
  read ORG_IDENTIFIER
  
  if [ -z "$ORG_IDENTIFIER" ]; then
    echo "Error: Organization identifier cannot be empty"
    exit 1
  fi
  
  # Save to user defaults
  defaults write kopyl.appkit-starter-pack organization-identifier "$ORG_IDENTIFIER"
  echo "Organization identifier '$ORG_IDENTIFIER' saved to user defaults."
else
  echo "Using saved organization identifier: $ORG_IDENTIFIER"
fi

# Sanitize app name - remove special characters and replace spaces with dashes, but keep original case
SANITIZED_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9 _-]//g' | sed 's/[[:space:]]\+/-/g')
# Create bundle identifier safe name (lowercase, no spaces, only alphanumeric, hyphens, and dots)
BUNDLE_ID_NAME=$(echo "$SANITIZED_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')

if [ -z "$SANITIZED_NAME" ]; then
  echo "Error: App name resulted in empty string after sanitization"
  exit 1
fi

echo "Creating macOS app: $APP_NAME"
echo "Sanitized name: $SANITIZED_NAME"

# Create main directory structure
mkdir -p "$SANITIZED_NAME"
mkdir -p "$SANITIZED_NAME/$SANITIZED_NAME.xcodeproj/xcshareddata/xcschemes"
mkdir -p "$SANITIZED_NAME/$SANITIZED_NAME/Assets.xcassets/AccentColor.colorset"
mkdir -p "$SANITIZED_NAME/$SANITIZED_NAME/Assets.xcassets/AppIcon.appiconset"

# Create app.swift in the root directory
cat > "$SANITIZED_NAME/app.swift" << 'EOF'
import Cocoa

class Application: NSApplication {
    func addQuiteMenuItem() {
        self.mainMenu = NSMenu()
        
        let appMenuItem = NSMenuItem()
        self.mainMenu?.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        appMenu.addItem(NSMenuItem(title: "Quit \(ProcessInfo.processInfo.processName)",
           action: #selector(terminate(_:)),
           keyEquivalent: "q")
        )
    }
    
    override init() {
        super.init()
        self.addQuiteMenuItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
EOF

# Create main.swift in the root directory
cat > "$SANITIZED_NAME/main.swift" << 'EOF'
import Cocoa

class WindowConfig {
    static let width: CGFloat = 480
    static let height: CGFloat = 300
}

class MainWindowView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        frame = NSRect(x: 0, y: 0, width: WindowConfig.width, height: WindowConfig.height)
        
        addHelloWorldTextField()
    }
    
    func addHelloWorldTextField() {
        let textField = NSTextField(labelWithString: "Hello, World!")
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        textField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

class MainWindowViewController: NSViewController {
    override func loadView() {
        view  = MainWindowView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
    }
    
}

var mainWindow: NSWindow?

func createMainWindow() {
    mainWindow = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: WindowConfig.width, height: WindowConfig.height),
        styleMask: [.titled, .closable, .miniaturizable, .resizable],
        backing: .buffered, defer: false
    )
    mainWindow?.center()
    mainWindow?.titleVisibility = .hidden
    
    mainWindow?.contentViewController = MainWindowViewController()
    
    let _ = NSWindowController(window: mainWindow)
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createMainWindow()
        
        mainWindow?.makeKeyAndOrderFront(nil)
    }
}

let app = Application.shared
let delegate = AppDelegate()
app.delegate = delegate

app.run()

@available(macOS 14.0, *)
#Preview {
    MainWindowViewController()
}
EOF

# Create entitlements file (using underscore format like the original)
ENTITLEMENTS_NAME=$(echo "$SANITIZED_NAME" | sed 's/-/_/g')
cat > "$SANITIZED_NAME/$SANITIZED_NAME/${ENTITLEMENTS_NAME}.entitlements" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.files.user-selected.read-only</key>
	<true/>
</dict>
</plist>
EOF

# Create Assets.xcassets/Contents.json
cat > "$SANITIZED_NAME/$SANITIZED_NAME/Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create AccentColor.colorset/Contents.json
cat > "$SANITIZED_NAME/$SANITIZED_NAME/Assets.xcassets/AccentColor.colorset/Contents.json" << 'EOF'
{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create AppIcon.appiconset/Contents.json
cat > "$SANITIZED_NAME/$SANITIZED_NAME/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create project.pbxproj with dynamic content
cat > "$SANITIZED_NAME/$SANITIZED_NAME.xcodeproj/project.pbxproj" << EOF
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 77;
	objects = {

/* Begin PBXBuildFile section */
		482FEA1D2DC8FD9A000396C3 /* app.swift in Sources */ = {isa = PBXBuildFile; fileRef = 482FEA1C2DC8FD9A000396C3 /* app.swift */; };
		482FEA1F2DC8FD9A000396C3 /* main.swift in Sources */ = {isa = PBXBuildFile; fileRef = 482FEA1E2DC8FD9A000396C3 /* main.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		482FEA192DC8FD9A000396C3 /* $SANITIZED_NAME.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "$SANITIZED_NAME.app"; sourceTree = BUILT_PRODUCTS_DIR; };
		482FEA1C2DC8FD9A000396C3 /* app.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = app.swift; sourceTree = "<group>"; };
		482FEA1E2DC8FD9A000396C3 /* main.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = main.swift; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFileSystemSynchronizedRootGroup section */
		482FEA1B2DC8FD9A000396C3 /* $SANITIZED_NAME */ = {
			isa = PBXFileSystemSynchronizedRootGroup;
			path = "$SANITIZED_NAME";
			sourceTree = "<group>";
		};
/* End PBXFileSystemSynchronizedRootGroup section */

/* Begin PBXFrameworksBuildPhase section */
		482FEA162DC8FD9A000396C3 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		482FEA102DC8FD9A000396C3 = {
			isa = PBXGroup;
			children = (
				482FEA1C2DC8FD9A000396C3 /* app.swift */,
				482FEA1E2DC8FD9A000396C3 /* main.swift */,
				482FEA1B2DC8FD9A000396C3 /* $SANITIZED_NAME */,
				482FEA1A2DC8FD9A000396C3 /* Products */,
			);
			sourceTree = "<group>";
		};
		482FEA1A2DC8FD9A000396C3 /* Products */ = {
			isa = PBXGroup;
			children = (
				482FEA192DC8FD9A000396C3 /* $SANITIZED_NAME.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		482FEA182DC8FD9A000396C3 /* $SANITIZED_NAME */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 482FEA252DC8FD9C000396C3 /* Build configuration list for PBXNativeTarget "$SANITIZED_NAME" */;
			buildPhases = (
				482FEA152DC8FD9A000396C3 /* Sources */,
				482FEA162DC8FD9A000396C3 /* Frameworks */,
				482FEA172DC8FD9A000396C3 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			fileSystemSynchronizedGroups = (
				482FEA1B2DC8FD9A000396C3 /* $SANITIZED_NAME */,
			);
			name = "$SANITIZED_NAME";
			packageProductDependencies = (
			);
			productName = "$SANITIZED_NAME";
			productReference = 482FEA192DC8FD9A000396C3 /* $SANITIZED_NAME.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		482FEA112DC8FD9A000396C3 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1630;
				LastUpgradeCheck = 1630;
				TargetAttributes = {
					482FEA182DC8FD9A000396C3 = {
						CreatedOnToolsVersion = 16.3;
					};
				};
			};
			buildConfigurationList = 482FEA142DC8FD9A000396C3 /* Build configuration list for PBXProject "$SANITIZED_NAME" */;
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 482FEA102DC8FD9A000396C3;
			minimizedProjectReferenceProxies = 1;
			preferredProjectObjectVersion = 77;
			productRefGroup = 482FEA1A2DC8FD9A000396C3 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				482FEA182DC8FD9A000396C3 /* $SANITIZED_NAME */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		482FEA172DC8FD9A000396C3 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		482FEA152DC8FD9A000396C3 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				482FEA1F2DC8FD9A000396C3 /* main.swift in Sources */,
				482FEA1D2DC8FD9A000396C3 /* app.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		482FEA232DC8FD9C000396C3 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				DEVELOPMENT_TEAM = 9QNMAN8CT6;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"\$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 12.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG \$(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		482FEA242DC8FD9C000396C3 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				DEVELOPMENT_TEAM = 9QNMAN8CT6;
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 12.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
			};
			name = Release;
		};
		482FEA262DC8FD9C000396C3 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = "$SANITIZED_NAME/${ENTITLEMENTS_NAME}.entitlements";
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 9QNMAN8CT6;
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"\$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = "$ORG_IDENTIFIER.$BUNDLE_ID_NAME";
				PRODUCT_NAME = "\$(TARGET_NAME)";
				REGISTER_APP_GROUPS = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		482FEA272DC8FD9C000396C3 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = "$SANITIZED_NAME/${ENTITLEMENTS_NAME}.entitlements";
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 9QNMAN8CT6;
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"\$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = "$ORG_IDENTIFIER.$BUNDLE_ID_NAME";
				PRODUCT_NAME = "\$(TARGET_NAME)";
				REGISTER_APP_GROUPS = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		482FEA142DC8FD9A000396C3 /* Build configuration list for PBXProject "$SANITIZED_NAME" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				482FEA232DC8FD9C000396C3 /* Debug */,
				482FEA242DC8FD9C000396C3 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		482FEA252DC8FD9C000396C3 /* Build configuration list for PBXNativeTarget "$SANITIZED_NAME" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				482FEA262DC8FD9C000396C3 /* Debug */,
				482FEA272DC8FD9C000396C3 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 482FEA112DC8FD9A000396C3 /* Project object */;
}
EOF

# Create scheme file
cat > "$SANITIZED_NAME/$SANITIZED_NAME.xcodeproj/xcshareddata/xcschemes/$SANITIZED_NAME.xcscheme" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1640"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES"
      buildArchitectures = "Automatic">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "482FEA182DC8FD9A000396C3"
               BuildableName = "$SANITIZED_NAME.app"
               BlueprintName = "$SANITIZED_NAME"
               ReferencedContainer = "container:$SANITIZED_NAME.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = ""
      selectedLauncherIdentifier = "Xcode.IDEFoundation.Launcher.PosixSpawn"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "482FEA182DC8FD9A000396C3"
            BuildableName = "$SANITIZED_NAME.app"
            BlueprintName = "$SANITIZED_NAME"
            ReferencedContainer = "container:$SANITIZED_NAME.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "482FEA182DC8FD9A000396C3"
            BuildableName = "$SANITIZED_NAME.app"
            BlueprintName = "$SANITIZED_NAME"
            ReferencedContainer = "container:$SANITIZED_NAME.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
EOF

echo "✅ macOS app '$SANITIZED_NAME' created successfully!"
echo "📁 Project structure:"
echo "   $SANITIZED_NAME/"
echo "   ├── app.swift"
echo "   ├── main.swift"
echo "   ├── $SANITIZED_NAME.xcodeproj/"
echo "   └── $SANITIZED_NAME/"
echo "       ├── ${ENTITLEMENTS_NAME}.entitlements"
echo "       └── Assets.xcassets/"
echo ""
echo "🚀 To open in Xcode: open $SANITIZED_NAME/$SANITIZED_NAME.xcodeproj"