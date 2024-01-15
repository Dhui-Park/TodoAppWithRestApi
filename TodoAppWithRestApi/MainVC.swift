//
//  MainVC.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import UIKit

class MainVC: UIViewController {
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    var todosVM: TodosVM = TodosVM()
    
    var dummyDataList: [String] = ["aaaaaaa", "bbbbbbb", "ccccccc", "ddddddd", "eeeeeeee", "fffffff", "aaaaaaa", "bbbbbbb", "ccccccc", "ddddddd", "eeeeeeee", "fffffff","aaaaaaa", "bbbbbbb", "ccccccc", "ddddddd", "eeeeeeee", "fffffff","aaaaaaa", "bbbbbbb", "ccccccc", "ddddddd", "eeeeeeee", "fffffff"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        self.view.backgroundColor = .systemYellow
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        
        self.myTableView.dataSource = self
    }
    
}

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dummyDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else { return UITableViewCell() }
        
        
        return cell
    }
    
}

extension UIViewController: StoryBoarded { }
/// Storyboard 가져오기
protocol StoryBoarded {
    static func instantiate(_ storyboardName: String?) -> Self
}

extension StoryBoarded {
    
    static func instantiate(_ storyboardName: String? = nil) -> Self {
        
        let name = storyboardName ?? String(describing: self)
        
        let storyboard = UIStoryboard(name: name, bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
    }
}


extension UITableViewCell: Nibbed { }
/// Nib File 가져오기
protocol Nibbed {
    static var uinib: UINib { get }
}

extension Nibbed {
    static var uinib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}


/// reuseIdentifier 가져오기
protocol ReuseIdentifiable {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifiable { }
