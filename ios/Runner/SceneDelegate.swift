import Flutter
import AVFAudio
import CoreNFC
import UIKit
import Darwin

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      registerDeviceCheckChannel(on: controller)
    }
  }

  private func registerDeviceCheckChannel(on controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "ckck_app/device_checks",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "checkEarphones":
        result(self.checkEarphones())
      case "checkNfcAvailability":
        result(self.checkNfcAvailability())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func checkEarphones() -> [String: Any] {
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

  private func checkNfcAvailability() -> [String: Any] {
    let modelGroup = classifyNfcModel()

    switch modelGroup {
    case .legacyManual:
      return [
        "success": false,
        "message": "이 모델은 제어 센터에서 NFC를 수동으로 켜야 해요.",
        "mode": "requires_manual_enable"
      ]
    case .autoEnabled:
      return [
        "success": true,
        "message": "이 모델은 별도 설정 없이 NFC 사용이 가능해요.",
        "mode": "success_auto"
      ]
    case .unsupportedOrUnknown:
      return [
        "success": false,
        "message": "이 기기에서는 현재 NFC를 사용할 수 없어요.",
        "mode": "unsupported"
      ]
    }
  }

  private func classifyNfcModel() -> NfcModelGroup {
    let identifier = currentDeviceIdentifier()

    guard identifier.hasPrefix("iPhone") else {
      return .unsupportedOrUnknown
    }

    let parts = identifier.split(separator: ",")
    guard let modelPart = parts.first else {
      return .unsupportedOrUnknown
    }

    let majorString = modelPart.replacingOccurrences(of: "iPhone", with: "")
    guard let major = Int(majorString) else {
      return .unsupportedOrUnknown
    }

    if major == 9 || major == 10 {
      return .legacyManual
    }

    if major >= 11 {
      return .autoEnabled
    }

    return .unsupportedOrUnknown
  }

  private func currentDeviceIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)

    let mirror = Mirror(reflecting: systemInfo.machine)
    return mirror.children.reduce(into: "") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else {
        return
      }
      identifier.append(String(UnicodeScalar(UInt8(value))))
    }
  }
}

private enum NfcModelGroup {
  case legacyManual
  case autoEnabled
  case unsupportedOrUnknown
}
