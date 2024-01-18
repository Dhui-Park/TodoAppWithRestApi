//
//  MainVC.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import UIKit

class MainVC: UIViewController {
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    var todos: [Todo] = []
    
    var todosVM: TodosVM = TodosVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        self.view.backgroundColor = .systemYellow
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        
        self.myTableView.dataSource = self
        
        // ViewModel 이벤트 받기 - View&ViewModel 묶기
        self.todosVM.notifyTodosChanged = { updatedTodos in
            self.todos = updatedTodos
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }
        
    }
    
}

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else { return UITableViewCell() }
        
        let cellData = self.todos[indexPath.row]
        
        // data 셀에 넣어주기
        cell.updateUI(cellData)
        
        return cell
    }
    
}


