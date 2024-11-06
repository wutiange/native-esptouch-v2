

@objc(NativeEsptouchV2)
class NativeEsptouchV2: RCTEventEmitter, ESPProvisionerDelegate {
    
    var provisioner: ESPProvisioner?
    static var AES_KEY_ERR_CODE = "1"
    static var CUSTOM_DATA_ERR_CODE = "2"
    static var ESP_PROVISIONER_NOT_INIT_ERR_CODE = "3"
    
    static var SYNC_LISTENER_NAME = "SyncListener"
    static var ESP_PROVISIONING_LISTENER_NAME = "EspProvisioningListener"
    
    override func constantsToExport() -> [AnyHashable : Any]! {
        return [
            Self.SYNC_LISTENER_NAME: Self.SYNC_LISTENER_NAME,
            Self.ESP_PROVISIONING_LISTENER_NAME: Self.ESP_PROVISIONING_LISTENER_NAME
        ]
    }

    // 必须实现 supportedEvents 方法来声明支持的事件名称
    override func supportedEvents() -> [String]! {
        return [
            Self.SYNC_LISTENER_NAME,
            Self.ESP_PROVISIONING_LISTENER_NAME
        ]
    }
    
    @objc
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }


    // 实现协议方法
    func onSyncStart() {
        // 处理同步开始
        let eventBody: [String: Any?] = [
            "name": "start",
            "data": NSNull(),
        ]
        self.sendEvent(withName: Self.SYNC_LISTENER_NAME, body: eventBody)
    }

    func onSyncStop() {
        // 处理同步停止
        let eventBody: [String: Any?] = [
            "name": "stop",
            "data": NSNull(),
        ]
        self.sendEvent(withName: Self.SYNC_LISTENER_NAME, body: eventBody)
    }
    
    func onSyncError(_ exception: NSException) {
        // 打印错误信息
        print("Exception occurred:")
        print("Name: \(exception.name)")
        print("Reason: \(exception.reason ?? "Unknown")")
        if let userInfo = exception.userInfo {
            print("User Info: \(userInfo)")
        }
        print("Call Stack:\n\(exception.callStackSymbols.joined(separator: "\n"))")
        
        // 停止同步
        if let provisioner = self.provisioner {
            provisioner.stopSync()
        }
        
        // 发送错误事件
        let eventBody: [String: Any] = [
            "name": "error",
            "err": exception.reason ?? "Unknown error"
        ]
        
        sendEvent(withName: Self.SYNC_LISTENER_NAME, body: eventBody)
    }



    
    func onProvisioningStart() {
        let eventBody: [String: Any?] = [
            "name": "start",
            "data": NSNull(),
        ]
        self.sendEvent(withName: Self.ESP_PROVISIONING_LISTENER_NAME, body: eventBody)
    }
    
    func onProvisioningStop() {
        let eventBody: [String: Any?] = [
            "name": "stop",
            "data": NSNull(),
        ]
        self.sendEvent(withName: Self.ESP_PROVISIONING_LISTENER_NAME, body: eventBody)
    }
    
    func onProvisoningScanResult(_ result: ESPProvisioningResult) {
        let data: [String: Any] = [
            "address": result.address,
            "bssid": result.bssid
        ]
        
        let eventBody: [String: Any] = [
            "name": "response",
            "data": data
        ]
        
        sendEvent(withName: Self.ESP_PROVISIONING_LISTENER_NAME, body: eventBody)
    }

    
    func onProvisioningError(_ exception: NSException) {
        let eventBody: [String: Any?] = [
            "name": "error",
            "data": NSNull(),
            "err": exception.reason ?? "Unknown error"
        ]
        sendEvent(withName: Self.ESP_PROVISIONING_LISTENER_NAME, body: eventBody)
    }

    @objc
    func espProvisionerInit() {
        DispatchQueue.main.async {
            self.provisioner = ESPProvisioner.share()
            self.startSyncWithDelegate()
        }
    }
    

    @objc
    func stopSync() {
        provisioner?.stopSync()
    }
    
    @objc
    func startSyncWithDelegate() {
        provisioner?.startSync(with: self)
    }

    
    @objc
    func startProvisioning(_ options: NSDictionary,
                          resolver resolve: @escaping RCTPromiseResolveBlock,
                          rejecter reject: @escaping RCTPromiseRejectBlock) {
        do {
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
                    throw EspTouch2Error.generalError(code: NativeEsptouchV2.AES_KEY_ERR_CODE,
                                                    message: String(localized: "esptouch2_aes_key_error"))
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
            resolve(true)
        } catch let error as EspTouch2Error {
            reject(error.code, error.errorDescription ?? "", nil)
        } catch {
            reject("UNKNOWN_ERROR", error.localizedDescription, nil)
        }
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
