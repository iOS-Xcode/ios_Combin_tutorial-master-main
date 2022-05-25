//
//  ViewController.swift
//  dynamic_table_view
//
//  Created by Jeff Jeong on 2020/09/01.
//  Copyright © 2020 Tuentuenna. All rights reserved.
//

import UIKit
import Combine

let MY_TABLE_VIEW_CELL_ID = "myTableViewCell"

class ViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var prependButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var appendButton: UIBarButtonItem!
    
    @IBAction func barButtonAction(_ sender: UIBarButtonItem) {
        print(#function, #line)
        switch sender {
        case prependButton:
            print("앞에추가")
            self.viewModel.prependData()
        case resetButton:
            print("리셋")
            self.viewModel.resetData()
        case appendButton:
            print("뒤에추가")
            self.viewModel.appendData()
        default: break
        }
    }
    
    var viewModel: ViewModel = ViewModel()
    
    //데이타를 메모리에서 날림.
    var disposalbleBag = Set<AnyCancellable>()
    
    var tempArray : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController - viewDidLoad() called")
        
        // 쎌 리소스 파일 가져오기
        let myTableViewCellNib = UINib(nibName: String(describing: MyTableViewCell.self), bundle: nil)
        
        self.myTableView.register(myTableViewCellNib, forCellReuseIdentifier: MY_TABLE_VIEW_CELL_ID)
        
        self.myTableView.rowHeight = UITableView.automaticDimension
        
        self.myTableView.estimatedRowHeight = 120
        
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        
        //뷰모델의 데이터 상태를 연동시킨다.
        self.setBindings()
    }

}

//MARK: - 뷰모델 관련
extension ViewController {
    ///뷰모델의 데이터를 뷰컨의 리스트 데이터와 연동
    fileprivate func setBindings(){
        print("ViewController - setBindings()")
        
        //sink 는 구독, 이벤트 받는다. list에 대한 바인딩
        self.viewModel.$tempArray.sink{ (updatedList : [String]) in
            print("ViewController - updatedList.count: \(updatedList.count)")
            self.tempArray = updatedList
//            self.myTableView.reloadData()
        }.store(in: &disposalbleBag)
        
        //action에 대한 바인딩
        self.viewModel.dateUpdatedAction.sink{ (addingType : ViewModel.AddingType) in
            print("ViewController - dataUpdatedAction.count: \(addingType)")
            switch addingType {
//            case .append:
//                self.myTableView.reloadData()
            case .prepend:
                self.myTableView.reloadDataAndKeepOffset()
            default:
                self.myTableView.reloadData()
            
            }
        }.store(in: &disposalbleBag)
    }
}
//MARK: - 테이블뷰 관련 메서드
extension ViewController {

}
extension ViewController: UITableViewDelegate {

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tempArray.count
    }

    // 쎌에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = myTableView.dequeueReusableCell(withIdentifier: MY_TABLE_VIEW_CELL_ID, for: indexPath) as! MyTableViewCell
        cell.contentLabel.text = tempArray[indexPath.row]

        return cell
    }

}
//테이블뷰 으로 옵셋 유지하는 메서드 만들기
//뒤에 추가 후 앞의 추가할 때 앞의 추가화면의 마지막 셀이 보이 도록 한다.
extension UITableView {
    //Offset 떨어짐
    func reloadDataAndKeepOffset() {
        //스코롤링 멈추기
        setContentOffset(contentOffset, animated: false)
        
        //데이타 추가전 컨텐츠 사이즈
        let beforeContentSize = contentSize
        reloadData()
        //랜더링 다시
        layoutIfNeeded()
        //데이터 추가후 컨텐츠 사이즈
        let afterContentSize = contentSize
        print("contentOffset",contentOffset)
        print("afterContentSize",afterContentSize)
        //데이타가 변경되고 리로드 되고 나서 컨텐트 옵셋 계산 및 설정
        let calculateNewOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height)
        )
        //변경된 옵셋 설정
        setContentOffset(calculateNewOffset, animated: false)
        
    }
}
