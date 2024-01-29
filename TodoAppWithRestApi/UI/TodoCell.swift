//
//  TodoCell.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import Foundation
import UIKit

class TodoCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var selectionSwitch: UISwitch!
    
    var cellData: Todo? = nil
    
    var onDeleteActionEvent: ((Int) -> Void)? = nil
    
    
    /// 셀 데이터 적용
    /// - Parameter cellData: Todo
    func updateUI(_ cellData: Todo) {
        guard let id: Int = cellData.id,
              let title: String = cellData.title else {
            print("id, title이 없습니다.")
            return
        }
        self.cellData = cellData
        
        self.titleLabel.text = "아이디: \(id)"
        self.contentLabel.text = title
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
    }
    
    @IBAction func onEditBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    @IBAction func onDeleteBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
        guard let id = cellData?.id else { return }
        
        self.onDeleteActionEvent?(id)
        
    }
    
    
    
}
