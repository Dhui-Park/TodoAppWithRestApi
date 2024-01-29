//
//  MainVC.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import UIKit
import RxSwift
import RxCocoa


class MainVC: UIViewController {
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var pageInfoLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todos: [Todo] = []
    
    var todosVM: TodosVM = TodosVM()
    
    // bottom indicator view
    lazy var bottomIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .systemGreen
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0, width: self.myTableView.bounds.width, height: 44)
        return indicator
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.tintColor = .systemGreen.withAlphaComponent(0.6)
        refreshControl.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
           
        return refreshControl
    }()
    
    // 검색 결과를 찾을 수 없을 때의 뷰
    lazy var searchDataNotFoundView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.bounds.width, height: 300))
        
        let label = UILabel()
        label.text = "검색 결과를 찾을 수 없습니다 🗑️"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    var searchTermInputWorkItem: DispatchWorkItem? = nil
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        self.view.backgroundColor = .systemGreen
        
        /// tableView 설정
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.tableFooterView = bottomIndicator
        self.myTableView.refreshControl = refreshControl
        
        
        // 서치바 설정
        self.searchBar.searchTextField.addTarget(self, action: #selector(searchTermChanged(_:)), for: .editingChanged)
        
        todosVM.errorMsgInfoObservable
            .observe(on: MainScheduler.instance)
            .debug("aaaaaaaa")
            .subscribe(onNext: { err in
                self.presentErrorAlert(title: err)
            })
            .disposed(by: disposeBag)
        
        
        todosVM.errorMsgInfoSecondObservable
            .observe(on: MainScheduler.instance)
            .debug("aaaaaaaa2")
            .subscribe(onNext: { err in
//                self.presentErrorAlert(title: err)
            })
            .disposed(by: disposeBag)
        
        // ViewModel 이벤트 받기 - View&ViewModel 묶기
        self.todosVM.notifyTodosChanged = { [weak self] updatedTodos in
            guard let self = self else { return }
            self.todos = updatedTodos
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }
        
        // ViewModel 이벤트 받기 - Page 변경
        self.todosVM.notifyCurrentPageChanged = { [weak self] currentPage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.pageInfoLabel.text = "MainVC / page: \(currentPage)"
            }
        }
        
        // ViewModel 이벤트 받기 - 로딩중 여부
        self.todosVM.notifyLoadingStateChanged = { [weak self] isLoading in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.myTableView.tableFooterView = isLoading ? self.bottomIndicator : nil
            }
        }
        
        // ViewModel 이벤트 받기 - 당겨서 리프레시 완료
        self.todosVM.notifyRefreshEnded = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
        
        // ViewModel 이벤트 받기 - 검색결과 없음 여부
        self.todosVM.notifySearchDataNotFound = { [weak self] notFound in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.myTableView.backgroundView = notFound ? self.searchDataNotFoundView : nil
            }
        }
        
        
    }// viewDidLoad()
    
    fileprivate func presentErrorAlert(title: String) {
        let alert = UIAlertController(title: title, message: "This is an alert.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addATodoBtnClicked(_ sender: UIButton) {
        
        todosVM.testAddATodo()
        
//        presentErrorAlert(title: <#T##String#>)
        
        
    }
    
}

//MARK: - Actions
extension MainVC {
    
    /// Refresh 처리
    /// - Parameter sender: UIRefreshControl
    @objc fileprivate func handleRefresh(_ sender: UIRefreshControl) {
        print(#fileID, #function, #line, "- ")
        
        // ViewModel에게 시키기
        self.todosVM.fetchRefresh()
    }
    
    /// 검색어가 입력되었다
    /// - Parameter sender: <#sender description#>
    @objc fileprivate func searchTermChanged(_ sender: UITextField) {
//        print(#fileID, #function, #line, "- sender: \(sender.text)")
        
        // 검색어가 입력되면 기존 작업 취소
        searchTermInputWorkItem?.cancel()
        
        let dispatchWorkItem = DispatchWorkItem(block: {
            // 백그라운드 - 사용자 입력 userInteractive
            DispatchQueue.global(qos: .userInteractive).async {
                DispatchQueue.main.async { [weak self] in
                    guard let userInput: String = sender.text,
                          let self = self else { return }
                    print(#fileID, #function, #line, "- 검색 API 호출하기 userInput: \(userInput)")
                    self.todosVM.todos = []
                    // ViewModel 검색어 갱신
                    self.todosVM.searchTerm = userInput
                }
            }
        })
        
        // 기존 작업 취소하기 위해 메모리 주소 일치시켜줌
        self.searchTermInputWorkItem = dispatchWorkItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: dispatchWorkItem)
    }
    
}

extension MainVC: UITableViewDelegate {
    
    
    /// scroll이 되었다는 이벤트를 알려준다
    /// - Parameter scrollView: UIScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(#fileID, #function, #line, "- ")
        
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset
        
        if distanceFromBottom - 200 < height {
            print("바닥에 도달했다!")
            self.todosVM.fetchMore()
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


