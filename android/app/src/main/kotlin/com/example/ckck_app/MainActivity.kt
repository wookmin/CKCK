package com.example.ckck_app

import android.content.Context
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.nfc.NfcAdapter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ckck_app/device_checks"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkEarphones" -> result.success(checkEarphones())
                "checkNfcAvailability" -> result.success(checkNfcAvailability())
                else -> result.notImplemented()
            }
        }
    }

    private fun checkEarphones(): Map<String, Any> {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val outputDevices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
        val isConnected = outputDevices.any { device ->
            when (device.type) {
                AudioDeviceInfo.TYPE_WIRED_HEADSET,
                AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
                AudioDeviceInfo.TYPE_BLUETOOTH_A2DP,
                AudioDeviceInfo.TYPE_BLUETOOTH_SCO,
                AudioDeviceInfo.TYPE_USB_HEADSET,
                AudioDeviceInfo.TYPE_HEARING_AID -> true
                else -> false
            }
        }

        return if (isConnected) {
            mapOf(
                "success" to true,
                "message" to "이어폰 또는 외부 오디오 장치가 연결되어 있어요.",
                "mode" to "success_auto"
            )
        } else {
            mapOf(
                "success" to false,
                "message" to "이어폰 또는 블루투스 오디오를 연결한 뒤 다시 확인해 주세요.",
                "mode" to "error"
            )
        }
    }

    private fun checkNfcAvailability(): Map<String, Any> {
        val adapter = NfcAdapter.getDefaultAdapter(this)
        return when {
            adapter == null -> mapOf(
                "success" to false,
                "message" to "이 기기는 NFC를 지원하지 않아요.",
                "mode" to "unsupported"
            )

            !adapter.isEnabled -> mapOf(
                "success" to false,
                "message" to "NFC가 꺼져 있어요. 설정에서 NFC를 켜 주세요.",
                "mode" to "error"
            )

            else -> mapOf(
                "success" to true,
                "message" to "NFC를 사용할 수 있어요.",
                "mode" to "success_auto"
            )
        }
    }
}
