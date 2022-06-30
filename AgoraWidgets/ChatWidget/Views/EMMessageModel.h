//
//  EMMessageModel.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraChat/AgoraChat.h>
#import <Masonry/Masonry.h>

#define MSG_EXT_GIF_ID @"em_expression_id"
#define MSG_EXT_GIF @"em_is_big_expression"
#define MSG_EXT_RECALL @"em_recall"

typedef NS_ENUM(NSInteger, AgoraChatMessageType) {
    AgoraChatMessageTypeText = 1,
    AgoraChatMessageTypeImage,
    AgoraChatMessageTypeVideo,
    AgoraChatMessageTypeLocation,
    AgoraChatMessageTypeVoice,
    AgoraChatMessageTypeFile,
    AgoraChatMessageTypeCmd,
    AgoraChatMessageTypeExtGif,
    AgoraChatMessageTypeExtRecall,
    AgoraChatMessageTypeExtCall,
};

NS_ASSUME_NONNULL_BEGIN

@interface EMMessageModel : NSObject

@property (nonatomic, strong) NSString *readReceiptCount;

@property (nonatomic, strong) AgoraChatMessage*emModel;

@property (nonatomic) AgoraChatMessageDirection direction;

@property (nonatomic) AgoraChatMessageType type;

//@property (nonatomic) BOOL isReadReceipt;

@property (nonatomic) BOOL isPlaying;

- (instancetype)initWithEMMessage:(AgoraChatMessage*)aMsg;

@end

NS_ASSUME_NONNULL_END
