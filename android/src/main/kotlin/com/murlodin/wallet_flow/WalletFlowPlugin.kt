package com.murlodin.wallet_flow

import android.app.Activity
import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK
import android.content.Intent
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.pay.Pay
import com.google.android.gms.pay.PayApiAvailabilityStatus
import com.google.android.gms.pay.PayClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.MethodChannel.Result

internal const val METHOD_CHANNEL_NAME = "wallet_flow"
private const val BUTTON_VIEW_CHANNEL_NAME = "wallet_flow/google_wallet_button"
private const val CHECK_AVAILABLE_METHOD = "wallet_flow/check_available"
private const val ADD_TO_WALLET_METHOD = "wallet_flow/add_card_to_google_wallet"
private const val GOOGLE_REQUEST_CODE = 1000




/** WalletFlowPlugin */
class WalletFlowPlugin : FlutterPlugin, ActivityAware, MethodCallHandler,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private lateinit var walletClient: PayClient
    private var activity: Activity? = null
    private var currentResult: Result? = null


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            BUTTON_VIEW_CHANNEL_NAME,
            WalletButtonFactory(flutterPluginBinding.binaryMessenger)
        )
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        currentResult = result

        when (call.method) {

            CHECK_AVAILABLE_METHOD -> checkAvailable()
            ADD_TO_WALLET_METHOD -> walletClient.savePassesJwt(
                call.argument<String>("token")!!,
                activity!!,
                GOOGLE_REQUEST_CODE
            )

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun checkAvailable() {
        walletClient
            .getPayApiAvailabilityStatus(PayClient.RequestType.SAVE_PASSES)
            .addOnSuccessListener { status ->
                setSuccessResult(status == PayApiAvailabilityStatus.AVAILABLE)
            }
            .addOnFailureListener { exception ->
                setErrorResult(CommonStatusCodes.ERROR.toString(), exception.message)
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == GOOGLE_REQUEST_CODE) {
            when (resultCode) {
                RESULT_OK -> setSuccessResult(true)
                RESULT_CANCELED -> setSuccessResult(false)
                PayClient.SavePassesResult.SAVE_ERROR ->
                    data?.let { intentData ->
                        val error = intentData.getStringExtra(PayClient.EXTRA_API_ERROR_MESSAGE)
                        setErrorResult(resultCode.toString(), error)
                    }

                else -> setErrorResult(
                    CommonStatusCodes.INTERNAL_ERROR.toString(),
                    "Unknown error saving pass"
                )
            }
            return true
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        walletClient = Pay.getClient(activity!!)
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    private fun setErrorResult(code: String, message: String?) {
        currentResult?.error(code, message, null)
        currentResult = null
    }

    private fun setSuccessResult(result: Boolean) {
        currentResult?.success(result)
        currentResult = null
    }

}
