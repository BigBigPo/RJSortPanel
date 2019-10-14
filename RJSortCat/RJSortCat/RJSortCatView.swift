//
//  RJSortCatView.swift
//  RJSortCat
//
//  Created by 许仁杰 on 2019/10/10.
//  Copyright © 2019 Po. All rights reserved.
//

import UIKit
import RxRelay
import RxSwift
class RJSortCatView: UIView {
    var disposeBag = DisposeBag()
    var dataArray:BehaviorRelay<[Int]> = BehaviorRelay(value: [Int]())
    
    var layers = [CALayer]()
    var exchangeLayer1:CALayer?
    var exchangeLayer2:CALayer?
    var replaceLayers:[CALayer] = [CALayer]()
    
    private var itemWidth:CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        bindEvent()
    }
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        
    }
    
    //MARK: EVENT
    func resetUI() {
        itemWidth = frame.width / CGFloat(dataArray.value.count)
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        layers.removeAll()
        guard dataArray.value.count != 0 else {
            return
        }
        
        for index in (0 ..< self.dataArray.value.count) {
            let value = dataArray.value[index]
            let layer = createLayer(index: index, value: value)
            self.layer.addSublayer(layer)
            
            layers.append(layer)
        }
    }
    //MARK: FUNCTIONS
    func exchangeItemsWithIndex(index1:Int, index2:Int) {
        exchangeLayer1?.backgroundColor = UIColor.lightGray.cgColor
        exchangeLayer2?.backgroundColor = UIColor.lightGray.cgColor
        guard index1 != index2 else {
            return
        }
        
        let layer1 = layers[index1]
        let layer2 = layers[index2]
            
        layer1.backgroundColor = UIColor.red.cgColor
        layer2.backgroundColor = UIColor.red.cgColor
        
        let x = layer1.frame.origin.x
        layer1.frame = CGRect(origin: CGPoint(x: layer2.frame.origin.x,
                                              y: layer1.frame.origin.y),
                              size: layer1.frame.size)
        layer2.frame = CGRect(origin: CGPoint(x: x,
                                              y: layer2.frame.origin.y),
                              size: layer2.frame.size)
        
        layers[index2] = layer1
        layers[index1] = layer2
        exchangeLayer1 = layer1
        exchangeLayer2 = layer2
    }
    
    func refreshSubValues(newValues:[Any], indexs:[Int]) {
        guard newValues.count == indexs.count else {
            return
        }
        
        if let values = newValues as? [Int] {
            for index in 0..<indexs.count {
                let layer = createLayer(index: indexs[index], value: values[index])
                layer.backgroundColor = UIColor.red.cgColor
                self.layer.addSublayer(layer)
                
                let oldlayer = layers[indexs[index]]
                oldlayer.removeFromSuperlayer()
                layers[indexs[index]] = layer
                
                layer.backgroundColor = UIColor.lightGray.cgColor
            }
        }
    }

    //MARK: DELEGATE
    
    //MARK: GETTER
    private func createLayer(index:Int, value:Int) -> CALayer{
        let blankHeight = CGFloat(100 - value) / 100.0 * frame.height
         
        let layer = CALayer()
        layer.frame = CGRect(x: itemWidth * CGFloat(index),
                            y: blankHeight,
                            width: itemWidth,
                            height: frame.height - blankHeight)
        layer.backgroundColor = UIColor.lightGray.cgColor
        return layer
    }
    //MARK: SETTER
    
    //MARK: CONFIG
    func bindEvent() {
        dataArray.subscribe(onNext: { [weak self](data) in
            self?.resetUI()
        }).disposed(by: disposeBag)
    }
}
