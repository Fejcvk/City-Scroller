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
    
    var grabOffsetVector:CGVector = CGVector.zero
    var moonView: UIView?
    var originalOffset: CGFloat = 0
    
    
    init() {
        super.init(frame:.zero)
        self.addSubview(buildingContainerView)
        isPagingEnabled = true
        
        self.moonView = createMoon()
        self.addSubview(self.moonView!)
        self.sendSubviewToBack(self.moonView!)
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
        
        contentSize = CGSize(width: size.width * 3, height: BuildingView.maxBuildingHeight)
        //royal blue
        backgroundColor = UIColor(red:65.0/255, green:105.0/255, blue:225.0/255, alpha:1.0)
        indicatorStyle = .white
        buildingContainerView.frame = CGRect(origin: .zero, size: contentSize)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let superResult = super.hitTest(point, with: event)
        if moonView!.frame.contains(point){
            return moonView!
        }
        return superResult
    }
    
    private func createMoon() -> UIView {
        let side = 100
        let size = CGSize(width: side, height: side)
        let circle = UIView(frame: CGRect(origin: .zero, size: size))
        circle.backgroundColor = .white
        circle.layer.cornerRadius = CGFloat(side) * 0.5
        
        let moveGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        circle.addGestureRecognizer(moveGesture)
        
        return circle
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        guard let movedCircle = gesture.view else { return }
        
        switch gesture.state {
        case .began:
            let grabPoint = gesture.location(in: self)
            let circleCenter = movedCircle.center
            let grabOffset = CGVector(dx: grabPoint.x - circleCenter.x, dy: grabPoint.y - circleCenter.y)
            self.grabOffsetVector = grabOffset
            self.sendSubviewToBack(movedCircle)
            UIView.animate(withDuration: 0.2) {
                movedCircle.alpha = 0.5
                movedCircle.transform = .init(scaleX: 1.2, y: 1.2)
            }
        case .changed:
            let grabOffset = self.grabOffsetVector
            let touchLocation = gesture.location(in: self)
            movedCircle.center = CGPoint(x: touchLocation.x - grabOffset.dx, y: touchLocation.y - grabOffset.dy)
            originalOffset = abs(movedCircle.frame.origin.x - self.bounds.maxX)
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2) {
                movedCircle.alpha = 1
                movedCircle.transform = .identity
            }
        default:
            break
        }
    }
    
}
