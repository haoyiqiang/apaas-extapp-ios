//
//  AgoraCountdownView.swift
//  AgoraEducation
//
//  Created by LYY on 2021/5/8.
//  Copyright © 2021 Agora. All rights reserved.
//

import AgoraUIBaseViews

public class AgoraCountdownView: UIView {
    enum Color {
        case warning, normal
    }
    
    // View
    private let headerView = AgoraCountdownHeaderView()
    private let colonView = AgoraCountdownColonLabel()
    private var timePages = [AgoraCountdownSingleTimeGroup]()
    
    // Frame
    let neededSize = CGSize(width: 98,
                            height: 54)
    
    var timePageColor: Color = .normal {
        didSet {
            guard oldValue != timePageColor else {
                return
            }
            
            var color: UIColor
            
            switch timePageColor {
            case .normal:
                color = UIColor(hexString: "4D6277")!
            case .warning:
                color = .red
            }
            
            timePages.forEach { group in
                group.turnColor(color: color)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        initViews()
        initViewFrame()
    }
    
    func updateTimePages(timeList: [String]) {
        for index in 0..<timePages.count {
            let text = timeList[index]
            let page = timePages[index]
            page.updateStr(str: text)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View
extension AgoraCountdownView: AgoraUIContentContainer {
    public func initViews() {
        addSubview(headerView)
        addSubview(colonView)
        
        for _ in 0...3 {
            let timeView = AgoraCountdownSingleTimeGroup(frame: .zero)
            timePages.append(timeView)
            addSubview(timeView)
        }
        
        layer.masksToBounds = true
    }
    
    public func initViewFrame() {
        // Header View
        let titleViewHeight: CGFloat = 17
        
        headerView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: neededSize.width,
                                  height: titleViewHeight)
        
        // Colon View
        let colonViewWidth: CGFloat = 6
        let colonViewHeight: CGFloat = neededSize.height - headerView.frame.maxY
        let colonViewX: CGFloat = (neededSize.width - colonViewWidth) * 0.5
        let colonViewY: CGFloat = headerView.frame.maxY
        
        colonView.frame = CGRect(x: colonViewX,
                                 y: colonViewY,
                                 width: colonViewWidth,
                                 height: colonViewHeight)
        
        // Time Page View
        let timePageContentHeight = neededSize.height - headerView.frame.maxY
        
        let timePageWidth: CGFloat = 18
        let timePageHeight: CGFloat = 24
        let timePageHorizontalSpace: CGFloat = 2
        let timePageY: CGFloat = (timePageContentHeight - timePageHeight) * 0.5 + headerView.frame.maxY
        
        let timePageXs: [CGFloat] = [(colonView.frame.minX - (timePageWidth * 2) - timePageHorizontalSpace),
                                     (colonView.frame.minX - timePageWidth),
                                     (colonView.frame.maxX),
                                     (colonView.frame.maxX + timePageWidth + timePageHorizontalSpace)]
        
        for i in 0..<timePages.count {
            let timeView = timePages[i]
            let timePageX = timePageXs[i]
            
            timeView.frame = CGRect(x: timePageX,
                                    y: timePageY,
                                    width: timePageWidth,
                                    height: timePageHeight)
        }
    }
    
    public func updateViewProperties() {
        let config = UIConfig.counter
        
        layer.shadowColor = config.shadow.color
        layer.shadowOffset = config.shadow.offset
        layer.shadowOpacity = config.shadow.opacity
        layer.shadowRadius = config.shadow.radius
        
        backgroundColor = config.backgroundColor
        layer.cornerRadius = config.cornerRadius
        
        layer.borderWidth = config.borderWidth
        layer.borderColor = config.borderColor.cgColor
    }
}

fileprivate extension Int64 {
    func secondsToTimeStrArr() -> Array<String> {
        guard self > 0 else {
            return ["0","0","0","0"]
        }
        
        let minsInt = self / 60
        let min0Str = String(minsInt / 10)
        let min1Str = String(minsInt % 10)
        
        var sec0Str = "0"
        var sec1Str = "0"
        
        if self % 60 != 0 {
            let remainder = self % 60
            sec0Str = remainder > 9 ? String(remainder / 10) : "0"
            sec1Str = remainder > 9 ? String(remainder % 10) : String(remainder)
        }
        
        return [min0Str,
                min1Str,
                sec0Str,
                sec1Str]
    }
}
