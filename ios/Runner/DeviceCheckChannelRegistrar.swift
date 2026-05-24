import AVFAudio
import CoreNFC
import Flutter
import UIKit

enum DeviceCheckChannelRegistrar {
  private static let channelName = "ckck_app/device_checks"

  static func register(on controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "checkEarphones":
        result(checkEarphones())
      case "checkNfcAvailability":
        result(checkNfcAvailability())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func checkEarphones() -> [String: Any] {
    let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
    let isConnected = outputs.contains { output in
      switch output.portType {
      case .headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
        return true
      default:
        return false
      }
    }

    if isConnected {
      return [
        "success": true,
        "message": "이어폰 또는 외부 오디오 장치가 연결되어 있어요."
      ]
    }

    return [
      "success": false,
      "message": "이어폰 또는 블루투스 오디오를 연결한 뒤 다시 확인해 주세요."
    ]
  }

  private static func checkNfcAvailability() -> [String: Any] {
    if #available(iOS 11.0, *) {
      if NFCNDEFReaderSession.readingAvailable {
        return [
          "success": true,
          "message": "이 기기에서 NFC를 사용할 수 있어요."
        ]
      }

      return [
        "success": false,
        "message": "이 기기에서는 현재 NFC를 사용할 수 없어요."
      ]
    }

    return [
      "success": false,
      "message": "이 iPhone 버전에서는 NFC를 지원하지 않아요."
    ]
  }
}
