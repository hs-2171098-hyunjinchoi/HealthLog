import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Properties
    let tabBar = UITabBarController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
    }
    
    // MARK: - Setup Methods
    private func setupTabBar() {
        let alarmViewController = UINavigationController(rootViewController: AlarmViewController())
//        let dietViewController = UINavigationController(rootViewController: DietViewController())
        let dashboardViewController = UINavigationController(rootViewController: DashboardViewController())
//        let exerciseViewController = UINavigationController(rootViewController: ExerciseViewController())
        let calendarViewController = UINavigationController(rootViewController: CalendarViewController())
        
        alarmViewController.tabBarItem = UITabBarItem(title: "Alarm", image: UIImage(systemName: "alarm"), tag: 0)
//        dietViewController.tabBarItem = UITabBarItem(title: "Diet", image: UIImage(systemName: "fork.knife"), tag: 1)
        dashboardViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 2)
//        exerciseViewController.tabBarItem = UITabBarItem(title: "Exercise", image: UIImage(systemName: "figure.walk"), tag: 3)
        calendarViewController.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 4)
        
        tabBar.viewControllers = [alarmViewController, dashboardViewController,  calendarViewController]
        
        addChild(tabBar)
        view.addSubview(tabBar.view)
        tabBar.didMove(toParent: self)
    }
}
