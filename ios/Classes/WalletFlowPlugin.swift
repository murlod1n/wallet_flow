import Flutter
import PassKit
import UIKit

/// Constants used within the WalletFlowPlugin.
internal enum WalletFlowConstants {
    /// Method name for checking if Apple Wallet is available.
    static let checkAvailableMethodName = "wallet_flow/check_available"
    /// Main channel name for WalletFlowPlugin.
    static let channelName = "wallet_flow"
    /// Channel ID for the Apple Wallet button.
    static let walletButtonChannelId = "wallet_flow/apple_wallet_button"
    /// Channel ID for the callback when wallet button clicked.
    static let walletButtonCallbackChannelId = "wallet_flow/add_сard_to_apple_wallet_callback"
    /// Method name for adding a card to Apple Wallet.
    static let methodAddCardToAppleWallet = "wallet_flow/add_сard_to_apple_wallet"

    /// Key for the pass data in method arguments.
    static let passDataKey = "passData"

    /// Error code for invalid arguments.
    static let errorInvalidArguments = "INVALID_ARGUMENTS"
    /// Error code when Apple Wallet is unavailable.
    static let errorUnavailable = "UNAVAILABLE"
    /// Error code for invalid pass data.
    static let errorInvalidPassData = "INVALID_PASS_DATA"
    /// Error code when no UIViewController is found.
    static let errorNoUIViewController = "NO_UI_VIEW_CONTROLLER"
    /// Error code when PKAddPassesViewController creation fails.
    static let errorPassVCCreationFailed = "PASSVC_CREATION_FAILED"
    /// Error code when PKPass creation fails.
    static let errorPassCreationFailed = "PASS_CREATION_FAILED"
}

/// `WalletFlowPlugin` is the main class for the Flutter plugin that interacts with Apple Wallet.
///
/// This plugin handles method calls from Flutter to:
/// - Check if Apple Wallet is available.
/// - Add a pass (card) to Apple Wallet.
/// It also registers a native view factory for the Apple Wallet button.
public class WalletFlowPlugin: NSObject, FlutterPlugin {

    private var flutterResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: WalletFlowConstants.channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = WalletFlowPlugin()
        let factory = NativeViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: WalletFlowConstants.walletButtonChannelId)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    /// Handles method calls received from the Flutter side.
    ///
    /// - Parameters:
    ///   - call: The `FlutterMethodCall` containing the method name and arguments.
    ///   - result: A `FlutterResult` callback to send the result of the method call back to Flutter.
    /// This method routes calls to specific handlers based on the `call.method`.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.flutterResult = result
        switch call.method {
        case WalletFlowConstants.methodAddCardToAppleWallet:
            guard let base64Pass = extractPassData(from: call) else {
                sendPassDataError(result: result, message: "Missing or empty pass data")
                return
            }
            addPassToWallet(base64Pass: base64Pass, result: result)
        case WalletFlowConstants.checkAvailableMethodName:
            result(isAppleWalletAvailable())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Checks if Apple Wallet is available on the device.
    ///
    /// - Returns: `true` if Apple Wallet can add passes, `false` otherwise.
    private func isAppleWalletAvailable() -> Bool {
        return PKAddPassesViewController.canAddPasses()
    }

    /// Adds a pass to Apple Wallet using the provided base64 encoded pass data.
    ///
    /// - Parameters:
    ///   - base64Pass: A String containing the base64 encoded pass data.
    ///   - result: A `FlutterResult` callback to send the outcome of the operation.
    /// This function handles decoding the pass data, creating a `PKPass` object,
    /// and presenting the `PKAddPassesViewController` to the user.
    private func addPassToWallet(base64Pass: String, result: @escaping FlutterResult) {
        guard isAppleWalletAvailable() else {
            sendError(result: result, code: WalletFlowConstants.errorUnavailable, message: "Apple Wallet not available on this device")
            return
        }

        guard let passData = Data(base64Encoded: base64Pass) else {
            sendPassDataError(result: result, message: "Pass data is invalid")
            return
        }
        do {
            let pass = try PKPass(data: passData)
            guard let passVC = PKAddPassesViewController(pass: pass) else {
                sendError(
                    result: result, code: WalletFlowConstants.errorPassVCCreationFailed,
                    message: "Failed to create PKAddPassesViewController")
                return
            }

            guard let rootViewController = UIApplication.shared.activeWindow?.rootViewController
            else {
                result(
                    FlutterError(
                        code: WalletFlowConstants.errorNoUIViewController, message: "No active UIWindow found",
                        details: nil))
                return
            }
            passVC.delegate = self
            rootViewController.present(passVC, animated: true, completion: nil)
        } catch {
            sendError(
                result: result, code: WalletFlowConstants.errorPassCreationFailed,
                message: "Failed to create PKPass: \(error.localizedDescription)",
                details: ["underlyingError": error.localizedDescription])
        }
    }

    /// Extracts the base64 encoded pass data from the `FlutterMethodCall` arguments.
    ///
    /// - Parameter call: The `FlutterMethodCall` from Flutter.
    /// - Returns: An optional String containing the base64 pass data if present and valid, otherwise `nil`.
    /// It looks for a key `WalletFlowConstants.passDataKey` in the arguments.
    private func extractPassData(from call: FlutterMethodCall) -> String? {
        guard let args = call.arguments as? [String: Any],
              let base64Pass = args[WalletFlowConstants.passDataKey] as? String,
              !base64Pass.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }
        return base64Pass
    }

    /// Sends an error back to Flutter.
    ///
    /// - Parameters:
    ///   - result: The `FlutterResult` callback.
    ///   - code: The error code string.
    ///   - message: The error message string.
    ///   - details: Optional additional details about the error.
    private func sendError(result: FlutterResult, code: String, message: String, details: Any? = nil) {
        result(FlutterError(code: code, message: message, details: details))
    }

    /// Sends a specific error related to invalid pass data back to Flutter.
    /// - Parameters:
    ///   - result: The `FlutterResult` callback.
    ///   - message: The error message string.
    private func sendPassDataError(result: FlutterResult, message: String) {
        sendError(
            result: result, code: WalletFlowConstants.errorInvalidPassData,
            message: message)
    }

}

// MARK: - UIApplication Extension
/// Extension to `UIApplication` to provide a convenient way to get the currently active window.
/// This is used to find the root view controller for presenting the Apple Wallet pass addition UI.
/// It handles different approaches for iOS versions before and after iOS 15.
extension UIApplication {
    fileprivate var activeWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first(where: { $0.activationState == .foregroundActive })?
                .windows
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.windows.first(where: \.isKeyWindow)
        }
    }
}

// MARK: - PKAddPassesViewControllerDelegate
/// Conformance to `PKAddPassesViewControllerDelegate` to handle the result of the pass addition process.
extension WalletFlowPlugin: PKAddPassesViewControllerDelegate {
    /// Called when the `PKAddPassesViewController` finishes.
    ///
    /// - Parameter controller: The `PKAddPassesViewController` that finished.
    /// This method dismisses the view controller and sends a `true` result back to Flutter
    /// indicating the process was completed (not necessarily that the pass was added, just that the UI flow finished).
    public func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        controller.dismiss(animated: true, completion: nil)
        self.flutterResult?(true)
        self.flutterResult = nil
    }


}
