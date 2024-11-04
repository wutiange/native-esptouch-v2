

@objc(NativeEsptouchV2)
class NativeEsptouchV2: NSObject, ESPProvisionerDelegate {
    
    var provisioner: ESPProvisioner?
    static var AES_KEY_ERR_CODE = "1"
    static var CUSTOM_DATA_ERR_CODE = "2"
    static var ESP_PROVISIONER_NOT_INIT_ERR_CODE = "3"

    // 实现协议方法
    func onSyncStart() {
      // 处理同步开始
    }

    func onSyncStop() {
      // 处理同步停止
    }
    
    func onSyncError(_ exception: NSException) {
        
    }
    
    func onProvisioningStart() {
        
    }
    
    func onProvisioningStop() {
        
    }
    
    func onProvisoningScanResult(_ result: ESPProvisioningResult) {
        
    }
    
    func onProvisioningError(_ exception: NSException) {
        
    }

    @objc
    func espProvisionerInit() {
      provisioner = ESPProvisioner.share()
    }
    

    @objc
    func stopSync() {
        provisioner?.stopSync()
    }
    
    @objc
    func startSyncWithDelegate() {
        provisioner?.startSync(with: self)
    }

    
    func startProvisioning(_ options: [AnyHashable: Any]) throws {
        let request = ESPProvisioningRequest()
        
        if let ssid = options["ssid"] as? String, let ssidData = ssid.data(using: .utf8) {
            request.ssid = ssidData
        }
        
        if let bssid = options["bssid"] as? String, let bssidData = bssid.data(using: .utf8) {
            request.bssid = bssidData
        }
        
        if let password = options["password"] as? String, let passwordData = password.data(using: .utf8) {
            request.password = passwordData
        }
        
        if let aesKey = options["aesKey"] as? String {
                if aesKey.count != 16 {
                    throw EspTouch2Error.generalError(code: NativeEsptouchV2.AES_KEY_ERR_CODE, message: String(localized: "esptouch2_aes_key_error"))
                }
                request.aesKey = aesKey
            }
        
        if let customData = options["customData"] as? String, let customDataBytes = customData.data(using: .utf8) {
            if customDataBytes.count > 64 {
                throw EspTouch2Error.generalError(
                    code: NativeEsptouchV2.CUSTOM_DATA_ERR_CODE,
                    message: String(format: NSLocalizedString("esptouch2_custom_data_error", comment: ""), 64))
            }
            request.reservedData = customDataBytes
        }
        if (provisioner == nil) {
            throw EspTouch2Error.generalError(
                code: NativeEsptouchV2.ESP_PROVISIONER_NOT_INIT_ERR_CODE,
                message: String(localized: "esp_provisioner_not_init_err"))
        }
        provisioner?.startProvisioning(request, with: self)
    }

    enum EspTouch2Error: Error {
        case generalError(code: String, message: String)
        
        var code: String {
            switch self {
            case .generalError(let code, _):
                return code
            }
        }
        
        var errorDescription: String? {
            switch self {
            case .generalError(_, let message):
                return message
            }
        }
    }


    
    @objc
    func stopProvisioning() {
        provisioner?.stopProvisioning()
    }
    
    @objc
    func isProvisioning(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        resolve(provisioner?.isProvisioning() ?? false)
    }
    
    @objc
    func isSyncing(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        resolve(provisioner?.isSyncing() ?? false)
    }
}
