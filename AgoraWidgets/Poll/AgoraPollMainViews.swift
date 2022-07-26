//
//  AgoraPollMainViews.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/13.
//

import UIKit
import AgoraUIBaseViews

class AgoraPollReceiverView: UIView, AgoraUIContentContainer {
    // Data
    var selectedMode: AgoraPollViewSelectedMode = .single {
        didSet {
            headerView.selectedMode = selectedMode
        }
    }
    
    var state: AgoraPollViewState = .unselected {
        didSet {
            tableView.state = state
            submitButton.pollState = state
        }
    }
    
    // View
    private let headerView = AgoraPollHeaderView()
    let titleLabel = AgoraPollTitleLabel()
    let tableView = AgoraPollTableView()
    let submitButton = AgoraPollSubmitButton()
    
    private(set) var neededSize = CGSize(width: 180,
                                         height: 147)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initViewFrame()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        layer.masksToBounds = true
        
        addSubviews([headerView,
                     titleLabel,
                     tableView,
                     submitButton])
    }
    
    func initViewFrame() {
        headerView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: neededSize.width,
                                  height: 17)
    }
    
    func updateViewProperties() {
        let component = UIConfig.poll
        
        headerView.backgroundColor = component.headerBackgroundColor
        
        backgroundColor = component.backgroundColor
        
        layer.borderColor = component.boardColor.cgColor
        layer.borderWidth = component.boardWidth
        layer.cornerRadius = component.cornerRadius
        
        agora_all_sub_views_update_view_properties()
    }
    
    func updateViewFrame(titleHeight: CGFloat,
                         tableHeight: CGFloat) -> CGSize {
        let titleLabelSpace: CGFloat = 15
        let limitWidth: CGFloat = neededSize.width - (titleLabelSpace * 2)
      
        let titleLabelX = titleLabelSpace
        let titleLabelY = headerView.frame.maxY + 10
        let titleLabelWidth = limitWidth
        let titleLabelHeight = titleHeight
        
        titleLabel.frame = CGRect(x: titleLabelX,
                                  y: titleLabelY,
                                  width: titleLabelWidth,
                                  height: titleLabelHeight)
        
        let tableViewY = titleLabel.frame.maxY + 10
        let tableViewHeight = tableHeight
        tableView.frame = CGRect(x: 0,
                                 y: tableViewY,
                                 width: neededSize.width,
                                 height: tableViewHeight)
        
        let submitButtonWidth: CGFloat = 70
        let submitButtonHeight: CGFloat = 22
        let submitButtonX = (neededSize.width - submitButtonWidth) * 0.5
        let submitButtonY = tableView.frame.maxY + 10
        
        submitButton.frame = CGRect(x: submitButtonX,
                                    y: submitButtonY,
                                    width: submitButtonWidth,
                                    height: submitButtonHeight)
        
        let buttonBottomSpace: CGFloat = 10
        
        let newHeight = submitButton.frame.maxY + buttonBottomSpace
        
        let newSize = CGSize(width: neededSize.width,
                             height: newHeight)
        
        neededSize = newSize
        
        return newSize
    }
}
