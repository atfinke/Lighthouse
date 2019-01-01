//
//  ViewController.swift
//  Lighthouse-UIKit
//
//  Created by Andrew Finke on 12/13/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(tapped(gr:)))
        gr.numberOfTapsRequired = 1
        gr.numberOfTouchesRequired = 1
        view.addGestureRecognizer(gr)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func loadView() {
        view = LighthousesView()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: view) else { fatalError() }
        (view as! LighthousesView).illuminate(location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: view) else { fatalError() }
        (view as! LighthousesView).illuminate(location)
    }
    
    @objc
    func tapped(gr: UITapGestureRecognizer) {
        
        let location = gr.location(in: view)
        (view as! LighthousesView).boom(location)
    }
    
}

struct Design {
    static let lighthouseSize: CGFloat = 2.5
    static let lighthouseSpacing: CGFloat = 3.0
}

class LighthousesView: UIView {
    var lighthouses = [[Lighthouse]]()
    var lighthouseUUID = [UUID: Lighthouse]()
    
    let director = LighthousesShowManager()
    
    init() {
        super.init(frame: .zero)
        
        director.startLighthouseDirections = { directions in
            for (duration, directions) in directions {
                
                
                
                UIView.animate(withDuration: duration, delay: 0.0, options: .beginFromCurrentState, animations: {
                    
                    for direction in directions {
                        let lighthouse = self.lighthouseUUID[direction.lighthouseUUID]!
                        direction.direction?(lighthouse)
                    }
                    
                    
                }) { _ in
                }
            }
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let xCount = Int(bounds.width / (Design.lighthouseSize + Design.lighthouseSpacing))
        let yCount = Int(bounds.height / (Design.lighthouseSize + Design.lighthouseSpacing))
        
        if lighthouses.isEmpty {
            for y in 0..<yCount {
                lighthouses.append([])
                for x in 0..<xCount {
                    let lighthouse = Lighthouse()
                    lighthouseUUID[lighthouse.uuid] = lighthouse
                    //                    lighthouse.resetState = { lh in
                    //                        lh.alpha = 0.0
                    //                        lh.innerView.backgroundColor =  .white
                    //                    }
                    //                    lighthouse.onState = { lh in
                    //                        lh.alpha = 1.0
                    //                    }
                    //                    lighthouse.offState = { lh in
                    //                        lh.alpha = 0.0
                    //                    }
                    addSubview(lighthouse)
                    lighthouses[y].append(lighthouse)
                }
            }
        }
        
        let xChunkSize = bounds.width / CGFloat(xCount)
        let yChunkSize = bounds.height / CGFloat(yCount)
        
        for y in 0..<yCount {
            for x in 0..<xCount {
                let lighthouse = lighthouses[y][x]
                lighthouse.frame = CGRect(x: xChunkSize * CGFloat(x) + Design.lighthouseSpacing / 2,
                                          y: yChunkSize * CGFloat(y) + Design.lighthouseSpacing / 2,
                                          width: Design.lighthouseSize,
                                          height: Design.lighthouseSize)
            }
        }
        
        
    }
    
    func boom(_ location: CGPoint) {
        var lightThemUp = [Lighthouse]()
        
        let xCount = Int(bounds.width / (Design.lighthouseSize + Design.lighthouseSpacing))
        let yCount = Int(bounds.height / (Design.lighthouseSize + Design.lighthouseSpacing))
        
        
        
        var minDiff: CGFloat = 200.0
        var minPoint = CGPoint.zero
        
        for y in 0..<yCount {
            for x in 0..<xCount {
                let lighthouse = lighthouses[y][x]
                let diff = sqrt(pow(lighthouse.frame.origin.x - location.x,2) + pow(lighthouse.frame.origin.y - location.y,2))
                if diff < 260 {
                    lightThemUp.append(lighthouse)
                }
                if diff < minDiff {
                    minDiff = diff
                    minPoint = lighthouse.center
                }
            }
        }
        
        
        //        lightThemUp = [lighthouses[0][0], lighthouses[0][3]]
        
        
        
        var directions = [LighthouseStageDirection]()
        
        for lh in lightThemUp {
            
            let offset = sqrt(pow(lh.frame.origin.x - minPoint.x,2) + pow(lh.frame.origin.y - minPoint.y,2)) / 260
            //  print(offset)
            let onDate = Date(timeIntervalSinceNow: TimeInterval(offset))
            let offDate = Date(timeIntervalSinceNow: TimeInterval(offset + 0.25))
            
            let onDirection = LighthouseStageDirection(lighthouseUUID: lh.uuid,
                                                       date: onDate,
                                                       duration: 0.25) { (lh) in
                                                        lh.innerView.alpha = 1.0 - offset
                                                        
                                                        //                                                        lh.innerView.backgroundColor = UIColor(hue: CGFloat.random(in: 0..<1.0),
                                                        //                                                                                               saturation: CGFloat.random(in: 0.5..<1.0),
                                                        //                                                                                               brightness: CGFloat.random(in: 0.5..<1.0),
                                                        //                                                                                               alpha: 0.5)
            }
            directions.append(onDirection)
            
            
            let offDirection = LighthouseStageDirection(lighthouseUUID: lh.uuid,
                                                        date: offDate,
                                                        duration: 0.25) { (lh) in
                                                            lh.innerView.alpha = 0.0
                                                            //                                                        lh.innerView.backgroundColor = .blue
            }
            
            directions.append(offDirection)
            //            print("adding")
        }
        
        director.add(directions: directions)
    }
    
    func illuminate(_ location: CGPoint) {
        
        return
        var lightThemUp = [Lighthouse]()
        
        let xCount = Int(bounds.width / (Design.lighthouseSize + Design.lighthouseSpacing))
        let yCount = Int(bounds.height / (Design.lighthouseSize + Design.lighthouseSpacing))
        
        for y in 0..<yCount {
            for x in 0..<xCount {
                let lighthouse = lighthouses[y][x]
                if sqrt(pow(lighthouse.frame.origin.x - location.x,2) + pow(lighthouse.frame.origin.y - location.y,2)) < 60 {
                    lightThemUp.append(lighthouse)
                }
            }
        }
        
        //        lightThemUp = [lighthouses[0][0], lighthouses[0][3]]
        
        let onDate = Date(timeIntervalSinceNow: 0)
        let offDate = Date(timeIntervalSinceNow: 3)
        let r1Date = Date(timeIntervalSinceNow: Double.random(in: 1..<1.75))
        let r2Date = Date(timeIntervalSinceNow: Double.random(in: 2.125..<2.5))
        var directions = [LighthouseStageDirection]()
        for lh in lightThemUp {
            let onDirection = LighthouseStageDirection(lighthouseUUID: lh.uuid,
                                                       date: onDate,
                                                       duration: 1) { (lh) in
                                                        lh.innerView.alpha = 1.0
                                                        lh.innerView.backgroundColor = UIColor(hue: CGFloat.random(in: 0..<1.0),
                                                                                               saturation: CGFloat.random(in: 0.5..<1.0),
                                                                                               brightness: CGFloat.random(in: 0.5..<1.0),
                                                                                               alpha: 0.5)
            }
            directions.append(onDirection)
            
            let r1Direction = LighthouseStageDirection(lighthouseUUID: lh.uuid,
                                                       date: Date(timeIntervalSinceNow: Double.random(in: 1..<1.75)),
                                                       duration: 0.5) { (lh) in
                                                        lh.innerView.alpha = CGFloat.random(in: 0.25..<1)
                                                        //                                                        lh.innerView.backgroundColor = .blue
            }
            directions.append(r1Direction)
            
            let r2Direction = LighthouseStageDirection(lighthouseUUID: lh.uuid,
                                                       date: Date(timeIntervalSinceNow: Double.random(in: 2.125..<2.5)),
                                                       duration: 1) { (lh) in
                                                        lh.innerView.alpha = 1.0
                                                        //                                                        lh.innerView.backgroundColor = .blue
            }
            directions.append(r2Direction)
            
            let offDirection = LighthouseStageDirection(lighthouseUUID: lh.uuid,
                                                        date: offDate,
                                                        duration: 1) { (lh) in
                                                            lh.innerView.alpha = 0.0
                                                            //                                                        lh.innerView.backgroundColor = .blue
            }
            directions.append(offDirection)
            //            print("adding")
        }
        director.add(directions: directions)
        //        for lh in ligththemup {
        //            lh.onState = { lh in
        //                lh.alpha = 1.0
        //                lh.innerView.backgroundColor =  UIColor(hue: CGFloat.random(in: 0..<1.0),
        //                                                        saturation: CGFloat.random(in: 0.5..<1.0),
        //                                                        brightness: CGFloat.random(in: 0.5..<1.0),
        //                                                        alpha: 1)
        //            }
        //            lh.state = .on
        //                        UIView.animate(withDuration: TimeInterval.random(in: 0.4..<1.0), delay: 0.0, options: [.beginFromCurrentState], animations: {
        //                            lh.layoutIfNeeded()
        //                        }) { _ in
        //                            lh.state = .off
        //                            let random = TimeInterval.random(in: 0..<2.0)
        //                            UIView.animate(withDuration: TimeInterval.random(in: 0.8..<2.0), delay: 0.5, options: .beginFromCurrentState, animations: {
        //                                lh.layoutIfNeeded()
        //                            }) { _ in
        //                                if lh.state != .on {
        //                                    lh.state = .reset
        //                                    lh.layoutIfNeeded()
        //                                }
        //                            }
        //                        }
        //        }
    }
}

struct LighthouseStageDirection {
    let lighthouseUUID: UUID
    
    let date: Date
    let duration: Double
    
    var direction: ((Lighthouse) -> ())?
}

struct LighthouseStageSequence {
    let date: Date
    let directions: [LighthouseStageDirection]
}

class LighthousesShowManager {
    
    var startLighthouseDirections: (([TimeInterval: [LighthouseStageDirection]]) -> ())?
    
    var stageDirections = [LighthouseStageDirection]()
    
    var nextDirectionsCheckTimer: Timer?
    var nextDirectionsCheckDate: Date?
    
    var isCheckingDirections = false
    
    func add(directions: [LighthouseStageDirection]) {
        stageDirections.append(contentsOf: directions)
        
        for direction in directions {
            if let nextDate = nextDirectionsCheckDate, nextDate < direction.date {
                return
            }
            let offset = direction.date.timeIntervalSinceNow
            nextDirectionsCheckDate = direction.date
            nextDirectionsCheckTimer?.invalidate()
            nextDirectionsCheckTimer = Timer.scheduledTimer(timeInterval: offset,
                                                            target: self,
                                                            selector: #selector(checkDirections),
                                                            userInfo: nil,
                                                            repeats: false)
        }
        
        //        print("Adding: \(direction.uuid) for lh: \(direction.lighthouseUUID)")
    }
    
    @objc
    func checkDirections() {
        self.nextDirectionsCheckTimer?.invalidate()
        self.nextDirectionsCheckTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                             target: self,
                                                             selector: #selector(self.checkDirections),
                                                             userInfo: nil,
                                                             repeats: false)
        
        guard !isCheckingDirections else { return }
        isCheckingDirections = true
        let now = Date()
        
        DispatchQueue.global().async {
            var requestsToFufill = [TimeInterval: [LighthouseStageDirection]]()
            var requestsIndexToFufill = [Int]()
            
            for (index, direction) in self.stageDirections.enumerated() where direction.date < now {
                
                if requestsToFufill[direction.duration] == nil {
                    requestsToFufill[direction.duration] = [direction]
                } else {
                    requestsToFufill[direction.duration]?.append(direction)
                }
                
                requestsIndexToFufill.append(index)
            }
            
            requestsIndexToFufill.reversed().forEach({ self.stageDirections.remove(at: $0) })
            
            DispatchQueue.main.async {
                self.startLighthouseDirections?(requestsToFufill)
                self.isCheckingDirections = false
            }
            
            
        }
        
        
    }
}

class Lighthouse: UIView {
    
    enum LighthouseState {
        case reset, off, on
    }
    
    let innerView = UIView()
    var state = LighthouseState.reset {
        didSet {
            setNeedsLayout()
        }
    }
    
    let uuid = UUID()
    
    var resetState: ((Lighthouse) -> ())?
    var onState: ((Lighthouse) -> ())?
    var offState: ((Lighthouse) -> ())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        assert(bounds.height == bounds.width)
        
        backgroundColor = .clear
        
        if innerView.superview == nil {
            innerView.backgroundColor = .white
            innerView.alpha = 0.0
            addSubview(innerView)
        }
        innerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        innerView.layer.cornerRadius = innerView.bounds.width / 2
        innerView.center = CGPoint(x: bounds.width / 2,
                                   y: bounds.height / 2)
        
        //
        
        //        switch state {
        //        case .reset:
        //            resetState?(self)
        //        case .off:
        //            offState?(self)
        //        case .on:
        //            onState?(self)
        //        }
        
    }
    
}
