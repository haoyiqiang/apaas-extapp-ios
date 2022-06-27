//
//  EMMessageBubbleView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMMessageModel.h"

@interface EMMessageBubbleView : UIImageView

@property (nonatomic, readonly) AgoraChatMessageDirection direction;

@property (nonatomic, readonly) AgoraChatMessageType type;

@property (nonatomic, strong) EMMessageModel *model;

- (instancetype)initWithDirection:(AgoraChatMessageDirection)aDirection
                             type:(AgoraChatMessageType)aType;

- (void)setupBubbleBackgroundImage;



@end
