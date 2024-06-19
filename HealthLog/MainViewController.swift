import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Properties
    let tabBar = UITabBarController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = .tintColor
        
        setupTabBar()
    }
    
    // MARK: - Setup Methods
    private func setupTabBar() {
        let alarmViewController = UINavigationController(rootViewController: AlarmViewController())
        let dietAnalysisViewController = UINavigationController(rootViewController: DietAnalysisViewController())
        let dashboardViewController = UINavigationController(rootViewController: DashboardViewController())
        let exerciseAnalysisViewController = UINavigationController(rootViewController: ExerciseAnalysisViewController())
        let calendarViewController = UINavigationController(rootViewController: CalendarViewController())
        
        alarmViewController.tabBarItem = UITabBarItem(title: "Alarm", image: UIImage(systemName: "alarm"), tag: 0)
        dietAnalysisViewController.tabBarItem = UITabBarItem(title: "Diet", image: UIImage(systemName: "fork.knife"), tag: 1)
        dashboardViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 2)
        exerciseAnalysisViewController.tabBarItem = UITabBarItem(title: "Exercise", image: UIImage(systemName: "figure.walk"), tag: 3)
        calendarViewController.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 4)
        
        tabBar.viewControllers = [alarmViewController,dietAnalysisViewController,  dashboardViewController, exerciseAnalysisViewController, calendarViewController]
        
        tabBar.selectedIndex = 2
        
        addChild(tabBar)
        view.addSubview(tabBar.view)
        tabBar.didMove(toParent: self)
    }
}
