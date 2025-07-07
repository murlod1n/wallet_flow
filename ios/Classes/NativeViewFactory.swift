import Flutter
import UIKit
import PassKit

/// Factory for creating `NativeView` instances.
///
/// This class is responsible for creating instances of `NativeView`, which wraps the native iOS `PKAddPassButton`.
/// It conforms to `FlutterPlatformViewFactory` to integrate with the Flutter plugin system.
class NativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var methodChannel: FlutterMethodChannel

    /// Initializes the factory with a binary messenger.
    ///
    /// - Parameter messenger: The `FlutterBinaryMessenger` used for communication between Flutter and native code.
    ///
    /// A `FlutterMethodChannel` is also initialized here to facilitate method calls from the native side
    /// back to the Dart side, specifically for the "Add to Wallet" button tap event.
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        self.methodChannel = FlutterMethodChannel(name: WalletFlowConstants.channelName, binaryMessenger: messenger)
        super.init()
    }

        /// Creates a new `NativeView`.
        ///
        /// This method is called by Flutter when it needs to create an instance of the platform view.
        ///
        /// - Parameters:
        ///   - frame: The frame rectangle for the view, measured in points.
        ///   - viewId: The unique identifier for this view.
        ///   - args: Arguments passed from the Flutter side when creating the view.
        /// - Returns: An instance of `NativeView` that implements `FlutterPlatformView`.
        func create(
            withFrame frame: CGRect,
            viewIdentifier viewId: Int64,
            arguments args: Any?
        ) -> FlutterPlatformView {
            print("Creating NativeView with args: \(args)")
            return NativeView(
                frame: frame,
                viewIdentifier: viewId,
                arguments: args,
                binaryMessenger: messenger,
                methodChannel: methodChannel)
        }


}

/// A `FlutterPlatformView` that wraps a native iOS `PKAddPassButton`.
///
/// This class manages the lifecycle of the native view and handles interactions,
/// such as the "Add to Wallet" button tap, by communicating back to Flutter via a method channel.
class NativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var methodChannel: FlutterMethodChannel?

    /// Initializes the `NativeView`.
    ///
    /// This constructor sets up the underlying `UIView` and stores the method channel for later use.
    /// It then calls `createNativeView` to construct and configure the `PKAddPassButton`.
    ///
    /// - Parameters:
    ///   - frame: The frame rectangle for the view.
    ///   - viewId: The unique identifier for this view.
    ///   - args: Arguments passed from the Flutter side.
    ///   - messenger: The binary messenger for communication (optional, but typically provided).
    ///   - methodChannel: The method channel for invoking methods on the Dart side.
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        methodChannel: FlutterMethodChannel?
    ) {
        self._view = UIView()
        self.methodChannel = methodChannel
        super.init()

        createNativeView(view: _view)
    }

    /// Returns the underlying native `UIView`.
    ///
    /// This method is required by `FlutterPlatformView`.
    /// - Returns: The `UIView` instance that this `NativeView` manages.
    func view() -> UIView {
        return _view
    }

    /// Handles the tap event of the "Add to Wallet" button.
    ///
    /// When the button is tapped, this method is invoked, then uses the `methodChannel`
    //  to send a message back to the Flutter side,
    /// indicating that the button was pressed.
    @objc func addPassButtonTapped() {
        methodChannel?.invokeMethod(WalletFlowConstants.walletButtonCallbackChannelId, arguments: nil)
    }

    /// Creates and configures the native `PKAddPassButton`.
    ///
    /// - Parameter _view: The `UIView` that will contain the `PKAddPassButton`.
    func createNativeView(view _view: UIView){
        let addPassButton = PKAddPassButton(addPassButtonStyle: .black)

        addPassButton.translatesAutoresizingMaskIntoConstraints = false
        addPassButton.addTarget(self, action: #selector(addPassButtonTapped), for: .touchUpInside)
        _view.addSubview(addPassButton)

        NSLayoutConstraint.activate([
            addPassButton.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            addPassButton.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
            addPassButton.topAnchor.constraint(equalTo: _view.topAnchor),
            addPassButton.bottomAnchor.constraint(equalTo: _view.bottomAnchor),
        ])
    }
}
