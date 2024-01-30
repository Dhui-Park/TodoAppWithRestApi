//
//  MainVC.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa


class MainVC: UIViewController {
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var pageInfoLabel: UILabel!
    
    @IBOutlet weak var selectedTodosInfoLabel: UILabel!
    
    @IBOutlet weak var deleteSelectedTodosBtn: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todos: [Todo] = []
    
    var todosVM: TodosVM_Rx = TodosVM_Rx()
    
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
    
    // 가져올 데이터가 없을 때의 뷰
    lazy var bottomNoMoreDataView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.bounds.width, height: 60))
        
        let label = UILabel()
        label.text = "더 이상 가져올 데이터가 없습니다 🙀"
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
//        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.tableFooterView = bottomIndicator
        self.myTableView.refreshControl = refreshControl
        
        
        // 서치바 설정
        
        searchBar.searchTextField.rx.text.orEmpty
            .debug("🌙")
            .bind(onNext: self.todosVM.searchTerm.accept(_:))
            .disposed(by: disposeBag)
        
//        self.searchBar.searchTextField.addTarget(self, action: #selector(searchTermChanged(_:)), for: .editingChanged)
        
        self.deleteSelectedTodosBtn.addTarget(self, action: #selector(onDeleteSelectedTodosBtnClicked(_:)), for: .touchUpInside)
        
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

        
        
        
        // ViewModel 이벤트 받기 - View&ViewModel 묶기 - RxSwift
        self.todosVM
            .todos
            .bind(to: self.myTableView.rx.items(cellIdentifier: TodoCell.reuseIdentifier, cellType: TodoCell.self)) { [weak self] index, cellData, cell in
                
                guard let self = self else { return }
                
                // data 셀에 넣어주기
                cell.updateUI(cellData, selectedTodoIds: self.todosVM.selectedTodoIds)
                
                cell.onDeleteActionEvent = self.onDeleteItemAction
                
                cell.onEditActionEvent = self.onEditItemAction
                
                cell.onSelectedActionEvent = self.onSelectionItemAction
                
            }
            .disposed(by: disposeBag)
        
        // ViewModel 이벤트 받기 - Page 변경
        self.todosVM
            .currentPage
            .map { "MainVC - page: \($0)" }
            .observe(on: MainScheduler.instance)
            .bind(to: self.pageInfoLabel.rx.text)
            .disposed(by: disposeBag)
        
        
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
        
        // ViewModel 이벤트 받기 - 다음 페이지 여부
        self.todosVM
            .notifyHasNextPage
            .observe(on: MainScheduler.instance)
            .map { !$0 ? self.bottomNoMoreDataView : nil } // Observable<UIView?>
            .debug("⭐️ notifyHasNextPage")
            .bind(to: self.myTableView.rx.tableFooterView)
            .disposed(by: disposeBag)
        
        // ViewModel 이벤트 받기 - 할일 추가 완료 이벤트
        self.todosVM.notifyTodoAdded = { [weak self] in
            guard let self = self else { return }
            print(#fileID, #function, #line, "- ")
            DispatchQueue.main.async {
                self.myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        
        // ViewModel 이벤트 받기 - 에러 발생 이벤트
        self.todosVM.notifyErrorOccured = { [weak self] errMsg in
            guard let self = self else { return }
            print(#fileID, #function, #line, "- ")
            DispatchQueue.main.async {
                self.showErrAlert(errMsg: errMsg)
            }
        }
        
        // ViewModel 이벤트 받기 - 선택된 할일들 변경 이벤트
        self.todosVM.notifySelectedTodoIdsChanged = { [weak self] selectedTodoIds in
            guard let self = self else { return }
            print(#fileID, #function, #line, "- ")
            DispatchQueue.main.async {
                let idsInfoString = selectedTodoIds.map { "\($0)" }.joined(separator: ", ")

                self.selectedTodosInfoLabel.text = "선택된 할일: [" + idsInfoString + "]"
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
        
//        todosVM.testAddATodo()
        showAddTodoAlert()
//        presentErrorAlert(title: <#T##String#>)
        
        
    }
    
}

//MARK: - 얼럿
extension MainVC {
    
    /// 할일 추가 얼럿 띄우기
    fileprivate func showAddTodoAlert() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "추가할 할 일을 입력해주세요.", message: nil, preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "빡코딩하기"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "닫기", style: .destructive))
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak alert] (_) in
            if let userInput = alert?.textFields?[0].text {
                print("userInput: \(userInput)")
                self.todosVM.addATodo(userInput)
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 할일 추가시 에러 얼럿 띄우기
    fileprivate func showErrAlert(errMsg: String) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "에러", message: errMsg, preferredStyle: .alert)

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 할일 삭제 얼럿 띄우기
    fileprivate func showDeleteTodoAlert(_ id: Int) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "삭제", message: "id: \(id)를 삭제하시겠습니까?", preferredStyle: .alert)

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "삭제", style: .default, handler: { _ in
            // 뷰모델에서 해당 할일 삭제
            self.todosVM.deleteATodo(id: id)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 할일 수정 얼럿 띄우기
    fileprivate func showEditTodoAlert(_ id: Int, _ existingTitle: String) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "id: \(id) 수정", message: nil, preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = existingTitle
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "닫기", style: .destructive))
        
        alert.addAction(UIAlertAction(title: "수정", style: .default, handler: { [weak alert] (_) in
            if let userInput = alert?.textFields?[0].text {
                print("userInput: \(userInput)")
                self.todosVM.editATodo(id, userInput)
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
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
    
    
    /// 쎌의 삭제버튼 눌렀을때
    /// - Parameter id: 삭제할 아이템의 아이디
    fileprivate func onDeleteItemAction(_ id: Int) {
        print(#fileID, #function, #line, "- id: \(id)")
        self.showDeleteTodoAlert(id)
    }
    
    /// 쏄의 수정버튼 눌렀을때
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - editedTitle: 수정할 타이틀
    fileprivate func onEditItemAction(_ id: Int, _ editedTitle: String) {
        print(#fileID, #function, #line, "- id: \(id), editedTitle: \(editedTitle)")
        self.showEditTodoAlert(id, editedTitle)
    }
    
    
    /// 쎌의 선택 여부
    /// - Parameters:
    ///   - id: 선택한 쏄의 아이디
    ///   - isOn: 선택 여부
    fileprivate func onSelectionItemAction(_ id: Int, _ isOn: Bool) {
        print(#fileID, #function, #line, "- id: \(id), isOn: \(isOn)")
        #warning("TODO: - 선택된 요소 변경")
        self.todosVM.handleTodoSelection(id, isOn)
    }
    
    @objc fileprivate func onDeleteSelectedTodosBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        self.todosVM.deleteSelectedTodos()
    }
    
    /// 검색어가 입력되었다
    /// - Parameter sender: UITextField
//    @objc fileprivate func searchTermChanged(_ sender: UITextField) {
////        print(#fileID, #function, #line, "- sender: \(sender.text)")
//        
//        // 검색어가 입력되면 기존 작업 취소
//        searchTermInputWorkItem?.cancel()
//        
//        let dispatchWorkItem = DispatchWorkItem(block: {
//            // 백그라운드 - 사용자 입력 userInteractive
//            DispatchQueue.global(qos: .userInteractive).async {
//                DispatchQueue.main.async { [weak self] in
//                    guard let userInput: String = sender.text,
//                          let self = self else { return }
//                    print(#fileID, #function, #line, "- 검색 API 호출하기 userInput: \(userInput)")
//                    self.todosVM.todos.accept([])
//                    // ViewModel 검색어 갱신
//                    self.todosVM.searchTerm = userInput
//                }
//            }
//        })
//        
//        // 기존 작업 취소하기 위해 메모리 주소 일치시켜줌
//        self.searchTermInputWorkItem = dispatchWorkItem
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: dispatchWorkItem)
//    }
//    
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



