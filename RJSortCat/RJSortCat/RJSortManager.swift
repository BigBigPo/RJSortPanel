//
//  RJSortCat.swift
//  SortCat
//
//  Created by 许仁杰 on 2019/10/10.
//  Copyright © 2019 Po. All rights reserved.
//

import Foundation

enum RJSortType:String,CaseIterable {
    case Bubble
    case InsertDirect
    case InsertDichotomous
    case Shell
    case Quick
    case Merge
    
    static func ConfigSortWithType(type:RJSortType) -> RJSortProtocol {
        switch type {
        case .Bubble:
            return RJBubbleSort()
        case .InsertDirect:
            return RJInsertSortWithDirect()
        case .InsertDichotomous:
            return RJInsertSortWithDichotomous()
        case .Shell:
            return RJInsertSortWithShell()
        case .Merge:
            return RJMergeSort()
        case .Quick: fallthrough
        default:
            return RJQuickSort()
        }
    }
}

protocol RJSortProtocol {
    var sortSpeed:Float? {get set}         // 0...1
    var updateBlock:(([Any], Bool, (Int, Int)?, ([Any], [Int])?) -> Void)? {get set}
    
    func runSort<Type:Comparable>(array data:[Type]) -> [Type]
}

extension RJSortProtocol {
    mutating func runSort<Type:Comparable>(array data:[Type],
                                           progress progressBlock:(([Any], Bool,_ exchangeIndex :(index1:Int,index2:Int)?, _ refreshValues:(newValues:[Any], indexs:[Int])?) -> Void)?) {
        self.updateBlock = progressBlock
        let data = self.runSort(array: data)
        progressBlock?(data, true, nil, nil)
    }
    
    func sortProgressUpdate<Type:Comparable>(array data:[Type], exchangeIndex:(index1:Int, index2:Int)?, refreshValues:(newValues:[Any], startIndex:[Int])?) {
        var time = TimeInterval(0.03)
        if let speed = self.sortSpeed {
            guard speed != 0 else { return }
            if 0 < speed && speed < 1 {
                time = TimeInterval((1.01 - speed) * 0.01)
            }
        }
        
        Thread.sleep(forTimeInterval: time)
        self.updateBlock?(data, false, exchangeIndex, refreshValues)
    }
}

struct RJBubbleSort:RJSortProtocol {
    
    var sortSpeed: Float?
    var updateBlock: (([Any], Bool, (Int, Int)?, ([Any], [Int])?) -> Void)?
    
    func runSort<Type>(array data: [Type]) -> [Type] where Type : Comparable {
        var temp = data
        for index in 0 ..< temp.count {
            for innerIndex in 0 ..< (temp.count - index - 1) {
                if temp[innerIndex] > temp[innerIndex + 1] {
                    temp.swapAt(innerIndex, innerIndex + 1)
                    sortProgressUpdate(array: temp, exchangeIndex: (innerIndex, innerIndex + 1), refreshValues: nil)
                }
            }
        }
        return temp
    }
}

struct RJChooseSort:RJSortProtocol {
    var sortSpeed: Float?
    var updateBlock: (([Any], Bool, (Int, Int)?, ([Any], [Int])?) -> Void)?
    
    func runSort<Type>(array data: [Type]) -> [Type] where Type : Comparable {
        var temp = data
        var minIndex = 0
        
        for startIndex in 0 ..< temp.count {
            minIndex = startIndex
            // search min value
            for index in (startIndex + 1) ..< temp.count {
                if temp[index] < temp[minIndex] {
                    minIndex = index
                }
            }
            // exchange min value this loop
            if minIndex != startIndex {
                temp.swapAt(minIndex, startIndex)
                sortProgressUpdate(array: temp,
                                   exchangeIndex: (minIndex, startIndex),
                                   refreshValues: nil)
            }
        }
        return temp
    }
}

struct RJInsertSortWithDirect:RJSortProtocol {
    var sortSpeed: Float?
    var updateBlock: (([Any], Bool, (Int, Int)?, ([Any], [Int])?) -> Void)?
    
    func runSort<Type>(array data: [Type]) -> [Type] where Type : Comparable {
        var temp = data
        for flagIndex in 1 ..< temp.count {
            if temp[flagIndex] >= temp[flagIndex - 1] {
                continue
            }
            
            let value = temp[flagIndex]
            var index = flagIndex - 1
            while index > -1 && temp[index] > value {
                temp[index + 1] = temp[index]
                sortProgressUpdate(array: temp,
                                   exchangeIndex: (index, index + 1),
                                   refreshValues: nil)
                index -= 1
            }
            temp[index+1] = value
        }
        return temp
    }
}

struct RJInsertSortWithDichotomous:RJSortProtocol {
    var sortSpeed: Float?
    var updateBlock: (([Any], Bool, (Int, Int)?, ([Any], [Int])?) -> Void)?
    
    func runSort<Type>(array data: [Type]) -> [Type] where Type : Comparable {
        var temp = data
        for flagIndex in 1..<temp.count {
            let value = temp[flagIndex]
            if value > temp[flagIndex - 1] {
                continue
            }
            
            // Dichotomous-Search
            var left = 0
            var right = flagIndex
            while right >= left {
                let center = (right - left) / 2
                
                guard center != 0 else { break }
                
                if (temp[left + center - 1] >= value) {         // 注意判断语句中的 -1，否则取值位置错误
                    right = left + center
                } else {
                    left = left + center
                }
            }

            for index in (left..<flagIndex).reversed() {
                temp[index + 1] = temp[index]
                sortProgressUpdate(array: temp,
                                   exchangeIndex: (index + 1, index),
                                   refreshValues: nil)
            }
            temp[left] = value
        }
        return temp
    }
}

struct RJInsertSortWithShell:RJSortProtocol {
    var sortSpeed: Float?
    var updateBlock: (([Any], Bool, (Int, Int)?, ([Any], [Int])?) -> Void)?
    
    func runSort<Type>(array data: [Type]) -> [Type] where Type : Comparable {
        var temp = data
        var flagLength = temp.count
        while flagLength > 1 {
            flagLength /= 2
            
            for index in 0 ..< (temp.count - flagLength) {
                for innerIndex in 0 ..< (index + flagLength) {
                    let checkIndex = innerIndex + flagLength
                    if checkIndex >= temp.count {
                        break
                    }
                    
                    if temp[innerIndex] > temp[checkIndex] {
                        temp.swapAt(innerIndex, checkIndex)
                        sortProgressUpdate(array: temp, exchangeIndex: (innerIndex, checkIndex), refreshValues: nil)
                    }
                }
            }
        }
        return temp
    }
}

struct RJQuickSort:RJSortProtocol {
    
    var sortSpeed: Float?
    var updateBlock: (([Any], Bool, (Int, Int)?, ([Any], [Int])?) -> Void)?
    
    func runSort<Type>(array data: [Type]) -> [Type] where Type : Comparable {
        var temp = data
        func innerSort(left:Int, right:Int){
            if left >= right { return }
            
            let value = temp[left]
            var flagLeft = left
            var flagRight = right
            
            while flagLeft < flagRight {
                while flagLeft < flagRight {
                    if temp[flagRight] < value {
                        temp[flagLeft] = temp[flagRight]
                        sortProgressUpdate(array: temp,
                                           exchangeIndex: (flagLeft, flagRight),
                                           refreshValues: nil)
                        break
                    }
                    flagRight -= 1
                }
                while flagLeft < flagRight {
                    if temp[flagLeft] > value {
                        temp[flagRight] = temp[flagLeft]
                        sortProgressUpdate(array: temp,
                                           exchangeIndex: (flagLeft, flagRight),
                                           refreshValues: nil)
                        break
                    }
                    flagLeft += 1
                }
            }
            
            temp[flagLeft] = value
            innerSort(left: left, right: flagLeft - 1)
            innerSort(left: flagRight + 1, right: right)
        }
        
        innerSort(left: 0, right: temp.count - 1)
        
        return temp
    }
}

struct RJMergeSort:RJSortProtocol {
    var sortSpeed: Float?
    var updateBlock: (([Any], Bool, (Int, Int)?, ([Any], [Int])?) -> Void)?
    
    func runSort<Type>(array data: [Type]) -> [Type] where Type : Comparable {
        var temp = data
        var flagIndex = 1
        var subArray = [Type]()
        while flagIndex < temp.count {
            for index in 0 ..< (temp.count / flagIndex) {

                let firstIndex = index * flagIndex * 2
                let secondIndex = index * flagIndex * 2 + flagIndex
                
                // 获取前列
                if firstIndex >= temp.count
                    || firstIndex + flagIndex >= temp.count
                    || secondIndex >= temp.count {
                    continue
                }
                let firstList = Array(temp[firstIndex..<(firstIndex + flagIndex)])
                
                // 获取后列
                var secondList:[Type]
                if secondIndex + flagIndex >= temp.count {
                    secondList = Array(temp[secondIndex..<temp.count])
                } else {
                    secondList = Array(temp[secondIndex..<(secondIndex + flagIndex)])
                }
                
                // 进行归并排序
                subArray = innerMergeSort(firstLine: firstList,
                                          secondLine: secondList)
                
                // 将此次归并结果保存用以后续迭代
                
                for subIndex in 0 ..< subArray.count {
                    temp[firstIndex + subIndex] = subArray[subIndex]
                }
                
                let indexs = [Int](firstIndex..<(firstIndex + subArray.count))
                sortProgressUpdate(array: temp,
                                   exchangeIndex: nil,
                                   refreshValues: (subArray, indexs))
            }

            flagIndex *= 2
        }
        return temp
    }
    /// 归并查询(无临时缓存)
    private func innerMergeSortNoCatch<T:Comparable>(startIndex:Int, firstLine:[T], secondLine:[T]) -> [T] {
        if firstLine.count == 0 && secondLine.count == 0 {
            return [T]()
        } else {
            guard firstLine.count != 0 else { return secondLine }
            guard secondLine.count != 0 else { return firstLine }
        }

        var firstIndex = 0
        var secondIndex = 0

        var catchArray = [T]()

        while firstIndex != firstLine.count || secondIndex != secondLine.count {
            if firstIndex == firstLine.count {
                let array = secondLine[secondIndex..<secondLine.count]
                catchArray.append(contentsOf: array)
                return catchArray
            }

            if secondIndex == secondLine.count {
                let array = firstLine[firstIndex..<firstLine.count]
                catchArray.append(contentsOf: array)
                return catchArray
            }

            if firstLine[firstIndex] < secondLine[secondIndex] {
                catchArray.append(firstLine[firstIndex])
                firstIndex += 1
            } else {
                catchArray.append(secondLine[secondIndex])
                secondIndex += 1
            }
        }

        return catchArray
    }
    
    /// 归并查询
    /// - Parameter firstLine: 列表1
    /// - Parameter secondLine: 列表2
    private func innerMergeSort<T:Comparable>(firstLine:[T], secondLine:[T]) -> [T] {
        if firstLine.count == 0 && secondLine.count == 0 {
            return [T]()
        } else {
            guard firstLine.count != 0 else { return secondLine }
            guard secondLine.count != 0 else { return firstLine }
        }

        var firstIndex = 0
        var secondIndex = 0

        var catchArray = [T]()

        while firstIndex != firstLine.count || secondIndex != secondLine.count {
            if firstIndex == firstLine.count {
                let array = secondLine[secondIndex..<secondLine.count]
                catchArray.append(contentsOf: array)
                return catchArray
            }

            if secondIndex == secondLine.count {
                let array = firstLine[firstIndex..<firstLine.count]
                catchArray.append(contentsOf: array)
                return catchArray
            }

            if firstLine[firstIndex] < secondLine[secondIndex] {
                catchArray.append(firstLine[firstIndex])
                firstIndex += 1
            } else {
                catchArray.append(secondLine[secondIndex])
                secondIndex += 1
            }
        }

        return catchArray
    }
}
