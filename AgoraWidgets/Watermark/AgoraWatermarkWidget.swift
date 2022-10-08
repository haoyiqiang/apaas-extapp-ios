//
//  AgoraWatermarkWidget.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Jonathan on 2022/9/28.
//

import AgoraWidget
import UIKit

@objcMembers public class AgoraWatermarkWidget: AgoraNativeWidget {
    
    private let label = UILabel()
        
    public override func onLoad() {
        super.onLoad()
        createViews()
    }
}
// MARK: - View
private extension AgoraWatermarkWidget {
    func createViews() {
        label.text = info.localUserInfo.userName
        label.font = UIFont.systemFont(ofSize: 40)
        view.addSubview(label)
        label.mas_makeConstraints { make in
            make?.top.equalTo()(30)
            make?.height.equalTo()(0)
            make?.width.equalTo()(0)?.multipliedBy()(2)
        }
        
        //        label.textColor = Colorconf
//        UIView.animate(withDuration: TimeInterval(self.width/40), delay: 0,
//                       options: .curveLinear,
//                       animations: {
//            self.label.transform = .init(translationX: -self.width, y: 0)
//        }) { (bool) in
//            //  循环调用 。退出Controller 时候 记得移除动画
//            if bool {
//                self.lb.transform = .identity
//                self.circleText()
//            }
//        }
    }
}
