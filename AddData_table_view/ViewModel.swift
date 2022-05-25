//
//  ViewModel.swift
//  AddData_table_view
//
//  Created by Seokhyun Kim on 2022-05-25.
//  Copyright © 2022 Tuentuenna. All rights reserved.
//

import Foundation
import Combine

//뷰모델 - 뷰와 관련된 모델 - 즉 데이터 상태를 가지고 있음
class ViewModel: ObservableObject {
    var appendingCount: Int = 0
    var prependingCount: Int = 0
    var prependingArray = ["1 앞에 추가","2 앞에 추가","3 앞에 추가","4 앞에 추가","5 앞에 추가"]
    var addingArray = ["1 뒤에 추가","2 뒤에 추가","3 뒤에 추가","4 뒤에 추가","5 뒤에 추가"]
    
    enum AddingType {
        case append, prepend, reset
    }
    
    //데이터 변경 감시
    @Published var tempArray : [String] = []
    
    //데이타 타입과 에러 타입을 보냄
    var dateUpdatedAction = PassthroughSubject<AddingType, Never>()
    init() {
        print("ViewModel - init()")
    }
}

//MARK: - 리스트 관련
extension ViewModel {
     func prependData() {
        print(#fileID, #function, #line)
        
        prependingCount = prependingCount + 1
        let tempPrependingArray = prependingArray.map{ $0.appending(String(prependingCount)) }
        self.tempArray.insert(contentsOf: tempPrependingArray, at: 0)
         self.dateUpdatedAction.send(.prepend)
        //self.myTableView.reloadData()
        //self.myTableView.reloadDataAndKeepOffset()
    }
     func appendData() {
        print(#fileID, #function, #line)
        appendingCount = appendingCount + 1

        let tempAddingArray = addingArray.map{ $0.appending(String(appendingCount)) }

        self.tempArray += tempAddingArray
         self.dateUpdatedAction.send(.append)
        //self.myTableView.reloadData()

    }
     func resetData() {
        print(#fileID, #function, #line)
        appendingCount = 0
        prependingCount = 0
        tempArray = []
         self.dateUpdatedAction.send(.reset)
        //self.myTableView.reloadData()
    }
}
