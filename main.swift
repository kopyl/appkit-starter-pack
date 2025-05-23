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
