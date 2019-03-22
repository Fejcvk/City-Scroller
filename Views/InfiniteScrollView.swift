//
//  File.swift
//  
//
//  Created by Tomek on 21/03/2019.
//

import UIKit

class InfiniteScrollView: UIScrollView {
    
    let buildingContainerView = UIView()
    private var visibleBuildings: [BuildingView] = []
    
    init() {
        super.init(frame: .zero)
        self.addSubview(buildingContainerView)
        isPagingEnabled = true
    }
    
    override var frame: CGRect {
        didSet {
            setup(size: bounds.size)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recenterIfNecessary()
        
        let visibleBounds = convert(bounds, to: buildingContainerView)
        tileBuildings(from: visibleBounds.minX, to: visibleBounds.maxX)
    }
    
    private func placeNewBuildingOnTheRight(newOrigin: CGFloat) -> BuildingView {
        let building = BuildingView.randomBuilding()
        building.frame.origin.x = newOrigin
        print("Placed at ", building.frame.origin.x)
        building.frame.origin.y = contentSize.height - building.frame.height
        visibleBuildings.append(building)
        buildingContainerView.addSubview(building)
        return building
    }
    
    private func placeNewBuildingOnTheLeft(oldOrigin: CGFloat) -> BuildingView {
        let building = BuildingView.randomBuilding()
        building.frame.origin.x = oldOrigin - building.frame.width
        print("Placed at ", building.frame.origin.x)
        building.frame.origin.y = contentSize.height - building.frame.height
        visibleBuildings.insert(building, at: 0)
        buildingContainerView.addSubview(building)
        return building
    }
    
    
    private func recenterIfNecessary() {
        let currentOffset = contentOffset
        let contentWidth = contentSize.width
        let centerOffsetX = (contentWidth - bounds.width) / 2.0
        let distanceFromCenter = abs(currentOffset.x - centerOffsetX)

        if distanceFromCenter >= bounds.width {
            let moveBy = floor((currentOffset.x - centerOffsetX) / bounds.width) * bounds.width
            contentOffset.x -= moveBy
            for building in visibleBuildings {
                var center = buildingContainerView.convert(building.center, to: self)
                center.x -= moveBy
                building.center = convert(center, to: buildingContainerView)
            }
        }
    }
    
    private func tileBuildings(from minX: CGFloat, to maxX: CGFloat) {
        if visibleBuildings.count == 0 { _ = placeNewBuildingOnTheRight(newOrigin: 0.0) }
        
        var lastVisibleBuilding = visibleBuildings.last!
        var newRightOrigin = CGFloat(lastVisibleBuilding.frame.origin.x + lastVisibleBuilding.frame.width)
        while newRightOrigin < maxX {
            lastVisibleBuilding = placeNewBuildingOnTheRight(newOrigin: newRightOrigin)
            newRightOrigin += lastVisibleBuilding.frame.width
        }
        var firstVisibleBuilding = visibleBuildings.first!
        var newLeftOrigin = firstVisibleBuilding.frame.origin.x
        
        while newLeftOrigin > minX {
            firstVisibleBuilding = placeNewBuildingOnTheLeft(oldOrigin: firstVisibleBuilding.frame.origin.x)
            newLeftOrigin = firstVisibleBuilding.frame.origin.x
        }

        var indicesToRemove: [Int] = []
        for (index, building) in visibleBuildings.enumerated() {
            if building.frame.maxX <= minX || building.frame.minX >= maxX {
                indicesToRemove.append(index)
                building.removeFromSuperview()
            }
        }
        for index in indicesToRemove.reversed() {
            visibleBuildings.remove(at: index)
        }
    }
    
    
    
    func setup(size: CGSize) {
        
        contentSize = CGSize(width: size.width * 3, height: size.height)
        //royal blue
        backgroundColor = UIColor(red:65.0/255, green:105.0/255, blue:225.0/255, alpha:1.0)
        indicatorStyle = .white
        buildingContainerView.frame = CGRect(origin: .zero, size: contentSize)
    }
}
