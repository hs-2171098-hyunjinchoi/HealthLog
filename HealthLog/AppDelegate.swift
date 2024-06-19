import CoreData
import UIKit
import UserNotifications
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var audioPlayer: AVAudioPlayer?
    
    // 회전 방지
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HealthDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()
        window?.tintColor = UIColor(named: "CustomTintColor")
        
        // UNUserNotificationCenter delegate 설정
        UNUserNotificationCenter.current().delegate = self
        
        // 알림 권한 요청
        requestNotificationAuthorization()
        
        // 알림 카테고리 설정
        setupNotificationCategories()
        
        // 오디오 플레이어 준비
        prepareAudioPlayer()
        return true
    }
    
    // MARK: - Notification Handling
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization request failed: \(error)")
            }
        }
    }

    func setupNotificationCategories() {
        let stopAction = UNNotificationAction(identifier: "STOP_ACTION", title: "Stop", options: [])
        let category = UNNotificationCategory(identifier: "ALARM_CATEGORY", actions: [stopAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        startAlarmSound()
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "STOP_ACTION" {
            stopAlarmSound()
        }
        completionHandler()
    }

    private func prepareAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "ringtone-126505", withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1 // 무한 반복
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }
    
    private func startAlarmSound() {
        audioPlayer?.play()
    }
    
    internal func stopAlarmSound() {
        audioPlayer?.stop()
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
