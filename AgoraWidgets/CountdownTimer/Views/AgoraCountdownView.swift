//
//  AgoraCountdownView.swift
//  AgoraEducation
//
//  Created by LYY on 2021/5/8.
//  Copyright © 2021 Agora. All rights reserved.
//

public class AgoraCountdownView: UIView {
    private let isPad: Bool = UIDevice.current.isPad
    
    private var timer: DispatchSourceTimer?
    
    private var isSuspend: Bool = true
        
    private var timeArr: Array<SingleTimeGroup> = []
    
    private var totalTime: Int64 = 0 {
        didSet {
            timeArr.forEach { group in
                group.turnColor(color: (totalTime <= 3) ? .red : UIColor(hexString: "4D6277")!)
            }
            let newTimeStrArr = totalTime.secondsToTimeStrArr()
            for i in 0..<timeArr.count {
                guard i <= newTimeStrArr.count else {
                    return
                }
                timeArr[i].updateStr(str: newTimeStrArr[i])
            }
        }
    }
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "F9F9FC")
        view.layer.cornerRadius = 6
        view.clipsToBounds = true

        let titleLabel = UILabel()
        titleLabel.text = GetWidgetLocalizableString(object: self,
                                                     key: "Countdown_title")
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        let line = UIView()
        line.backgroundColor = UIColor(hexString: "EEEEF7")
        
        view.addSubview(titleLabel)
        view.addSubview(line)
        
        titleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(isPad ? 19 : 10)
            make?.top.equalTo()(isPad ? 10 : 6)
        }
        
        line.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(0)
            make?.height.equalTo()(1)
        }
        
        return view
    }()
    
    private lazy var colonView: UILabel = {
        let colon = UILabel()
        colon.text = ":"
        colon.textColor = UIColor(hexString: "4D6277")
        colon.font = UIFont.boldSystemFont(ofSize: isPad ? 48 : 34)
        colon.backgroundColor = .clear
        colon.textAlignment = .center
        return colon
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)

        initView()
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func invokeCountDown(duration: Int64) {
        guard self.timer == nil else {
            return
        }
        totalTime = duration
        timer = DispatchSource.makeTimerSource(flags: [],
                                               queue: DispatchQueue.global())
        timer?.schedule(deadline: .now(),
                        repeating: 1)
        
        timer?.setEventHandler { [weak self] in
            if let `self` = self {
                if self.totalTime > 0 {
                    self.totalTime -= 1
                } else {
                    self.timer?.cancel()
                    self.timer = nil
                }
            } else {
                self?.timer?.cancel()
                self?.timer = nil
            }
            
        }
        isSuspend = true
        
        startTimer()
    }

    public func cancelCountDown() {
        stopTimer()
    }
}

// MARK: UI
private extension AgoraCountdownView {
    func initView() {
        isUserInteractionEnabled = true
        backgroundColor = .white
        addSubview(titleView)
        addSubview(colonView)
        if timeArr.count == 0 {
            for _ in 0...3 {
                let timeView = SingleTimeGroup(frame: .zero)
                timeArr.append(timeView)
                addSubview(timeView)
            }
        }
        
        layer.shadowColor = UIColor(red: 0.18,
                                    green: 0.25,
                                    blue: 0.57,
                                    alpha: 0.15).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        layer.shadowPath    = UIBezierPath(rect: frame).cgPath
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.89,
                                    green: 0.89,
                                    blue: 0.93,
                                    alpha: 1).cgColor
        clipsToBounds = true
        layer.cornerRadius = 6
        
    }
    
    func initLayout() {
        let singleWidth: CGFloat = 36
        let singleHeight: CGFloat = 48
        let gap_small: CGFloat = 4
        let colonViewWidth: CGFloat = 12
        
        let titleViewHeight: CGFloat = 32
        
        let xArr: [CGFloat] = [-((singleWidth * 1.5) + gap_small + (colonViewWidth * 0.5)),
                               -((singleWidth * 0.5) + (colonViewWidth * 0.5)),
                               (singleWidth * 0.5) + (colonViewWidth * 0.5),
                               (singleWidth * 1.5) + (colonViewWidth * 0.5) + gap_small]
        
        titleView.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(0)
            make?.height.equalTo()(titleViewHeight)
        }
        
        colonView.mas_makeConstraints { make in
            make?.top.equalTo()(titleView.mas_bottom)
            make?.bottom.equalTo()(0)
            make?.centerX.equalTo()(0)
            make?.width.equalTo()(colonViewWidth)
        }
        
        for i in 0..<timeArr.count {
            let timeView = timeArr[i]
            timeView.mas_makeConstraints { make in
                make?.centerX.equalTo()(0)?.offset()(xArr[i])
                make?.top.equalTo()(titleView.mas_bottom)?.offset()(11)
                make?.width.equalTo()(singleWidth)
                make?.height.equalTo()(singleHeight)
            }
        }
    }
    
    func startTimer() {
        if isSuspend {
            timer?.resume()
        }
        isSuspend = false
    }
    
    func stopTimer() {
        if isSuspend {
            timer?.resume()
        }
        isSuspend = false
        timer?.cancel()
        timer = nil
    }
}

extension Int64 {
    fileprivate func secondsToTimeStrArr() -> Array<String> {
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
