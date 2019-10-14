//
//  ViewController.swift
//  RJSortCat
//
//  Created by 许仁杰 on 2019/10/10.
//  Copyright © 2019 Po. All rights reserved.
//

import UIKit
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var dataPicker: UIPickerView!
    @IBOutlet weak var runButton: UIButton!
    @IBOutlet weak var dataPanelLabel: UILabel!
    @IBOutlet weak var sortShowView: RJSortCatView!
    
    var sortHelper:RJSortProtocol = RJSortType.ConfigSortWithType(type: RJSortType.allCases[0])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configBind()
    }
    
    func configBind() {
        dataPicker.delegate = self
        dataPicker.dataSource = self
    }
    
    //MARK: EVENT
    @IBAction func pressRunButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.isUserInteractionEnabled = false
        
        runTest()
    }
    
    //MARK: FUNCTIONS
    func runTest() {
        let valuesAndString = configAllNumbers()
        let values = valuesAndString.values
        var strings = valuesAndString.strings
        
        dataPanelLabel.text = strings.joined(separator: ", ")
        sortShowView.dataArray.accept(values)
        self.sortHelper.sortSpeed = 0.8
        DispatchQueue.global().async {
            self.sortHelper.runSort(array: values) { [weak self] (data, finish, exchangeIndexs, replaceValues) in
                DispatchQueue.main.async {
                    guard finish != true else {
                        self?.sortShowView.dataArray.accept(data as! [Int])
                        self?.runButton.isUserInteractionEnabled = true
                        self?.runButton.isSelected = false
                        return
                    }
                    
                    if let exchange = exchangeIndexs {
                        strings.swapAt(exchange.index1, exchange.index2)
                        self?.sortShowView.exchangeItemsWithIndex(index1: exchange.index1, index2: exchange.index2)
                    } else if let replace = replaceValues {
                        for index in 0 ..< replace.indexs.count {
                            strings[replace.indexs[index]] = "\(replace.newValues[index])"
                        }
                        self?.sortShowView.refreshSubValues(newValues: replace.newValues, indexs: replace.indexs)
                    }
                    self?.dataPanelLabel.text = strings.joined(separator: ", ")
                }
            }
        }
    }
    
    //MARK: DELEGATE
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sortHelper = RJSortType.ConfigSortWithType(type: RJSortType.allCases[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RJSortType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return RJSortType.allCases[row].rawValue
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    //MARK: GETTER
    
    //MARK: SETTER
    
    //MARK: CONFIG
    func configAllNumbers() -> (values:[Int], strings:[String]) {
        var valueList = [Int]()
        var stringList = [String]()
        while valueList.count < 100 {
            let value = arc4random_uniform(100)
            valueList.append(Int(value))
            stringList.append("\(value)")
        }
        return (valueList, stringList)
    }
    
    
}

