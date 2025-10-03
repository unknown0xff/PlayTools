import Foundation
import UIKit

let settings = PlaySettings.shared

@objc public final class PlaySettings: NSObject {
    @objc public static let shared = PlaySettings()

    let bundleIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
    let settingsUrl: URL
    var settingsData: AppSettingsData

    override init() {
        settingsUrl = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Containers/io.playcover.PlayCover")
            .appendingPathComponent("App Settings")
            .appendingPathComponent("\(bundleIdentifier).plist")
        do {
            let data = try Data(contentsOf: settingsUrl)
            settingsData = try PropertyListDecoder().decode(AppSettingsData.self, from: data)
        } catch {
            settingsData = AppSettingsData()
            print("[PlayTools] PlaySettings decode failed.\n%@")
        }
    }

    lazy var discordActivity = settingsData.discordActivity

    lazy var keymapping = settingsData.keymapping

    lazy var notch = settingsData.notch

    lazy var sensitivity = settingsData.sensitivity / 100

    @objc lazy var bypass = settingsData.bypass

    @objc lazy var windowSizeHeight = CGFloat(settingsData.windowHeight)

    @objc lazy var windowSizeWidth = CGFloat(settingsData.windowWidth)

    @objc lazy var inverseScreenValues = settingsData.inverseScreenValues

    @objc lazy var adaptiveDisplay = settingsData.resolution == 0 ? false : true

    @objc lazy var deviceModel = settingsData.iosDeviceModel as NSString

    @objc lazy var oemID: NSString = {
        switch settingsData.iosDeviceModel {
        case "iPad6,7":
            return "J98aAP"
        case "iPad8,6":
            return "J320xAP"
        case "iPad13,8":
            return "J522AP"
        case "iPad14,5":
            return "A2436"
        case "iPad16,6":
            return "A2925"
        case "iPhone14,3":
            return "A2645"
        case "iPhone15,3":
            return "A2896"
        case "iPhone16,2":
            return "A2849"
        case "iPhone17,2":
            return "A3084"
        default:
            return "J320xAP"
        }
    }()

    @objc lazy var playChain = settingsData.playChain

    @objc lazy var playChainDebugging = settingsData.playChainDebugging

    @objc lazy var windowFixMethod = settingsData.windowFixMethod

    @objc lazy var customScaler = settingsData.customScaler

    @objc lazy var rootWorkDir = settingsData.rootWorkDir

    @objc lazy var noKMOnInput = settingsData.noKMOnInput

    @objc lazy var enableScrollWheel = settingsData.enableScrollWheel

    @objc lazy var hideTitleBar = settingsData.hideTitleBar

    @objc lazy var checkMicPermissionSync = settingsData.checkMicPermissionSync

    @objc lazy var limitMotionUpdateFrequency = settingsData.limitMotionUpdateFrequency

    @objc public func getProxychainsSettings() -> String {

        // no proxy
        if settingsData.proxy.isEmpty {
            return ""
        }

        let proxy: String

        if settingsData.proxy.contains(":") {
            proxy = settingsData.proxy.replacingOccurrences(of: ":", with: " ")
        } else {
            proxy = settingsData.proxy + " 12324 dbadmin dbackiejj123"
        }

        let default_config = """
strict_chain
#quiet_mode
proxy_dns
#proxy_dns_daemon 127.0.0.1:1053
#remote_dns_subnet 127
#remote_dns_subnet 10
remote_dns_subnet 224
# Some timeouts in milliseconds
tcp_read_time_out 15000
tcp_connect_time_out 8000
#chain_len = 2
[ProxyList]
socks5 \(proxy)
"""
        return default_config
    }
}

struct AppSettingsData: Codable {
    var keymapping = true
    var sensitivity: Float = 50

    var disableTimeout = false
    var iosDeviceModel = "iPad13,8"
    var windowWidth = 1920
    var windowHeight = 1080
    var customScaler = 2.0
    var resolution = 2
    var aspectRatio = 1
    var notch = false
    var bypass = false
    var discordActivity = DiscordActivity()
    var version = "2.0.0"
    var playChain = false
    var playChainDebugging = false
    var inverseScreenValues = false
    var windowFixMethod = 0
    var rootWorkDir = true
    var noKMOnInput = false
    var enableScrollWheel = true
    var hideTitleBar = false
    var checkMicPermissionSync = false
    var limitMotionUpdateFrequency = false

    var proxy = ""
}
