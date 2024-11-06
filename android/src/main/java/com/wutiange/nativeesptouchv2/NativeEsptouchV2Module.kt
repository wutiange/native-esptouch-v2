package com.wutiange.nativeesptouchv2

import android.util.Log
import com.espressif.iot.esptouch2.provision.EspProvisioner
import com.espressif.iot.esptouch2.provision.EspProvisioningListener
import com.espressif.iot.esptouch2.provision.EspProvisioningRequest
import com.espressif.iot.esptouch2.provision.EspProvisioningResult
import com.espressif.iot.esptouch2.provision.EspSyncListener
import com.espressif.iot.esptouch2.provision.IEspProvisioner
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.BridgeReactContext
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import java.lang.ref.WeakReference


class NativeEsptouchV2Module(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  private fun sendEvent(
    eventName: String,
    params: WritableMap?
  ) {
    reactApplicationContext
      .getJSModule(BridgeReactContext.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }

  private var mProvisioner: EspProvisioner? = null

  override fun getName(): String {
    return NAME
  }

  override fun getConstants(): MutableMap<String, Any>? {
    return hashMapOf(
      SYNC_LISTENER_NAME to SYNC_LISTENER_NAME,
      ESP_PROVISIONING_LISTENER_NAME to ESP_PROVISIONING_LISTENER_NAME
    )
  }

  inner class SyncListener internal constructor(provisioner: EspProvisioner) :
    EspSyncListener {
    private val provisioner = WeakReference(provisioner)

    override fun onStart() {
      Log.d(NAME, "SyncListener onStart")
      Arguments.createMap().apply {
        putString("name", "start")
        this@NativeEsptouchV2Module.sendEvent(SYNC_LISTENER_NAME, this)
      }
    }

    override fun onStop() {
      Log.d(NAME, "SyncListener onStop")
      Arguments.createMap().apply {
        putString("name", "stop")
        this@NativeEsptouchV2Module.sendEvent(SYNC_LISTENER_NAME, this)
      }
    }

    override fun onError(e: Exception) {
      e.printStackTrace()
      val provisioner = provisioner.get()
      provisioner?.stopSync()
      Arguments.createMap().apply {
        putString("name", "error")
        putString("err", e.message)
        this@NativeEsptouchV2Module.sendEvent(SYNC_LISTENER_NAME, this)
      }
    }
  }

  @ReactMethod
  fun espProvisionerInit() {
    mProvisioner = EspProvisioner(reactApplicationContext)
    val syncListener = SyncListener(mProvisioner!!)
    mProvisioner!!.startSync(syncListener)
  }

  @ReactMethod
  fun stopSync() {
    mProvisioner?.stopSync()
  }

  @ReactMethod
  fun close() {
    mProvisioner?.close()
  }

  @ReactMethod
  fun getEspTouchVersion(promise: Promise) {
    promise.resolve(reactApplicationContext.getString(R.string.esptouch2_about_version, IEspProvisioner.ESPTOUCH_VERSION))
  }

  private fun genRequest(options: ReadableMap): EspProvisioningRequest {
    val builder = EspProvisioningRequest.Builder(reactApplicationContext)
    builder.setSSID(options.getString("ssid")?.toByteArray())
    val bssid = options.getString("bssid")?.toByteArray()
    if (bssid != null) {
      builder.setBSSID(bssid)
    }
    builder.setPassword(options.getString("password")?.toByteArray())
    val aesKey = options.getString("aesKey")?.toByteArray()
    if (aesKey != null && aesKey.size != 16) {
      throw EspTouch2Exception(AES_KEY_ERR_CODE, reactApplicationContext.getString(R.string.esptouch2_aes_key_error))
    }
    builder.setAESKey(aesKey)
    val customData = options.getString("customData")?.toByteArray()
    val customDataMaxLen = EspProvisioningRequest.RESERVED_LENGTH_MAX
    if (customData != null && customData.size > customDataMaxLen) {
      throw EspTouch2Exception(CUSTOM_DATA_ERR_CODE, reactApplicationContext.getString(R.string.esptouch2_custom_data_error, customDataMaxLen))
    }
    builder.setReservedData(customData)
    return builder.build()
  }

  var listener: EspProvisioningListener = object : EspProvisioningListener {
    override fun onStart() {
      Arguments.createMap().apply {
        putString("name", "start")
        putNull("data")
        sendEvent(ESP_PROVISIONING_LISTENER_NAME, this)
      }
    }

    override fun onResponse(result: EspProvisioningResult?) {

      val data = Arguments.createMap().apply {
        result?.address?.let {
          putMap("address", Arguments.createMap().apply {
            putString("address", it.address.toString())
            putString("hostName", it.hostName)
            putString("canonicalHostName", it.canonicalHostName)
            putString("hostAddress", it.hostAddress)
            putBoolean("isMulticastAddress", it.isMulticastAddress)
            putBoolean("isAnyLocalAddress", it.isAnyLocalAddress)
            putBoolean("isLoopbackAddress", it.isLoopbackAddress)
            putBoolean("isLinkLocalAddress", it.isLinkLocalAddress)
            putBoolean("isSiteLocalAddress", it.isSiteLocalAddress)

            putBoolean("isMCGlobal", it.isMCGlobal)
            putBoolean("isMCNodeLocal", it.isMCNodeLocal)
            putBoolean("isMCLinkLocal", it.isMCLinkLocal)
            putBoolean("isMCSiteLocal", it.isMCSiteLocal)
            putBoolean("isMCOrgLocal", it.isMCOrgLocal)
          })
        }
        result?.bssid?.let {
          putString("bssid", it)
        }
      }
      Arguments.createMap().apply {
        putString("name", "response")
        putMap("data", data)
        sendEvent(ESP_PROVISIONING_LISTENER_NAME, this)
      }
    }

    override fun onStop() {
      Arguments.createMap().apply {
        putString("name", "stop")
        putNull("data")
        sendEvent(ESP_PROVISIONING_LISTENER_NAME, this)
      }
    }

    override fun onError(e: Exception) {
      Arguments.createMap().apply {
        putString("name", "error")
        putNull("data")
        putString("err", e.message)
        sendEvent(ESP_PROVISIONING_LISTENER_NAME, this)
      }
    }
  }

  @ReactMethod
  fun startProvisioning(options: ReadableMap, promise: Promise) {
    try {
      val request = genRequest(options)
      if (mProvisioner == null) {
        throw EspTouch2Exception(ESP_PROVISIONER_NOT_INIT_ERR_CODE, reactApplicationContext.getString(R.string.esp_provisioner_not_init_err))
      }
      mProvisioner?.startProvisioning(request, listener); // request is nonnull, listener is nullable
      promise.resolve("ok")
    } catch (e: EspTouch2Exception) {
      promise.reject(e.code, e.message)
    } catch (e: Exception) {
      promise.resolve(e)
    }
  }

  @ReactMethod
  fun stopProvisioning() {
    mProvisioner?.stopProvisioning()
  }

  @ReactMethod
  fun isProvisioning(promise: Promise) {
    promise.resolve(mProvisioner?.isProvisioning ?: false)
  }

  companion object {
    const val NAME = "NativeEsptouchV2"
    const val AES_KEY_ERR_CODE = "1"
    const val CUSTOM_DATA_ERR_CODE = "2"
    const val ESP_PROVISIONER_NOT_INIT_ERR_CODE = "3"
    const val SYNC_LISTENER_NAME = "SyncListener"
    const val ESP_PROVISIONING_LISTENER_NAME = "EspProvisioningListener"

  }
}
