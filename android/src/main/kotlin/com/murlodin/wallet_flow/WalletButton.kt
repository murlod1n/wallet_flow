package com.murlodin.wallet_flow

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView
import android.view.LayoutInflater
import java.util.Locale
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

private const val LOCALE_PARAM_KEY = "locale"
private  const val METHOD_ADD_CARD_TO_GOOGLE_WALLET_CALLBACK = "wallet_flow/add_card_to_google_wallet_callback"

internal class NativeWalletButton(context: Context, id: Int, creationParams: Map<*, *>?, messenger: BinaryMessenger) : PlatformView {

    private val view: View
    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)

    init {
        val locale = creationParams?.get(LOCALE_PARAM_KEY) as? String ?: Locale.getDefault().language
        val config = context.resources.configuration
        val localizedContext = context.createConfigurationContext(config.apply {
            setLocale(Locale(locale))
        })
        val inflater = LayoutInflater.from(localizedContext)
        view = inflater.inflate(R.layout.add_to_googlewallet_button, null)

        view.setOnClickListener {
            methodChannel.invokeMethod(METHOD_ADD_CARD_TO_GOOGLE_WALLET_CALLBACK, null)
        }
    }

    override fun getView(): View = view
    override fun dispose() {}

}