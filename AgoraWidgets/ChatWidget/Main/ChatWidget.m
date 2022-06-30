//
//  ChatWidget.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/12.
//  Copyright © 2021 Agora. All rights reserved.
//


#import "ChatManager.h"
#import <WHToast/WHToast.h>
#import "ChatTopView.h"
#import "AnnouncementView.h"
#import "ChatView.h"
#import "CustomBadgeView.h"
#import "ChatWidget.h"
#import <AgoraWidgets/AgoraWidgets-Swift.h>

static const NSString* kAvatarUrl = @"avatarUrl";
static const NSString* kNickname = @"nickName";
static const NSString* kChatRoomId = @"chatroomId";

@interface ChatWidgetLaunchData : NSObject
// key
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *orgName;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *token007;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *hxToken;

// room
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *chatRoomId;

// user
@property (nonatomic, copy) NSString *avatarurl;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *userName;
@end

@implementation ChatWidgetLaunchData
- (BOOL)checkIsLegal {
    // key
    if (self.appKey.length <= 0) {
        return false;
    }
    
    // if we login with token,password can set nil
//    if (self.password.length <= 0) {
//        return false;
//    }
    
    if (self.token007.length <= 0) {
        return false;
    }
    
    if (self.host.length <= 0) {
        return false;
    }
    
    if (self.appId.length <= 0) {
        return false;
    }
    
    // room
    if (self.roomUuid.length <= 0) {
        return false;
    }
    
    if (self.chatRoomId.length <= 0) {
        return false;
    }
    
    // user
    if (self.userUuid.length <= 0) {
        return false;
    }
    
    if (self.userName.length <= 0) {
        return false;
    }
    
    return YES;
}
@end

#define TOP_HEIGHT 34
#define MINIBUTTON_SIZE 40

@interface ChatWidget () <ChatManagerDelegate,
                          UITextFieldDelegate,
                          AgoraUIContainerDelegate,
                          ChatTopViewDelegate,
                          ChatViewDelegate>
@property (nonatomic, strong) ChatManager* chatManager;
@property (nonatomic, strong) ChatTopView* chatTopView;
@property (nonatomic, strong) AnnouncementView* announcementView;
@property (nonatomic, strong) ChatView* chatView;
@property (nonatomic, strong) AgoraBaseUIContainer* containView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
//@property (nonatomic,strong) UIButton* miniButton;
@property (nonatomic, strong) CustomBadgeView* badgeView;
@property (nonatomic, strong) ChatWidgetLaunchData *launchData;
@property (nonatomic, assign) CGFloat topHeight;
@property (nonatomic, assign) BOOL launchedFlag;
@property (nonatomic) AgoraChatServerAPI* tokenRequest;
@end

@implementation ChatWidget
- (instancetype)initWithWidgetInfo:(AgoraWidgetInfo *)info {
    self = [super initWithWidgetInfo:info];
    
    if (self) {
        self.view.delegate = self;
        self.launchData = [[ChatWidgetLaunchData alloc] init];
        self.topHeight = TOP_HEIGHT;
        self.launchedFlag = NO;
        [self initViews];
        [self initData:info.roomProperties];
    }
    
    return self;
}
- (void)containerLayoutSubviews {
    [self layoutViews];
}

- (void)onMessageReceived:(NSString *)message {
    if ([message isEqualToString:@"min"]) {
        [self chatTopViewDidClickHide];
    } else if ([message isEqualToString:@"max"]) {
        [self showView];
    } else if ([message isEqualToString:@"hideTopBar"]) {
        self.chatTopView.hidden = true;
        self.topHeight = 0;
        [self layoutViews];
    } else if ([message isEqualToString:@"hideMiniButton"]) {
        self.chatTopView.hideButton.hidden = true;
    } else if ([message isEqualToString:@"hideAnnouncement"]) {
        self.chatTopView.announcementButton.hidden = true;
        self.chatTopView.selLine.hidden = true;
    } else if ([message isEqualToString:@"hideInput"]) {
        self.chatView.chatBar.hidden = true;
    } else if ([message isEqualToString:@"hideMuteButton"]) {
        [self.chatView hideMuteButton];
    } else {
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
        [self initData:dic];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.chatManager logout];
}

#pragma mark - ChatWidget
- (void)initViews {
    [self.view.superview layoutIfNeeded];
    
    self.containView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containView.backgroundColor = [UIColor clearColor];
    self.containView.layer.borderWidth = 1;
    self.containView.layer.borderColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:241/255.0 alpha:1.0].CGColor;
    self.containView.layer.cornerRadius = 5;
    [self.view addSubview:self.containView];
    
    self.chatTopView = [[ChatTopView alloc] initWithFrame:CGRectZero];
    self.chatTopView.delegate = self;
    [self.containView addSubview:self.chatTopView];
    
    self.announcementView = [[AnnouncementView alloc] initWithFrame:CGRectZero];
    
    self.chatView = [[ChatView alloc] initWithFrame:CGRectZero];
    self.chatView.delegate = self;
    [self.containView addSubview:self.chatView];
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(handleTapAction:)];
    [self.containView addGestureRecognizer:self.tap];
    
//    self.miniButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.miniButton setImage:[UIImage imageNamedFromBundle:@"icon_chat"] forState:UIControlStateNormal];
//    self.miniButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.miniButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//    self.miniButton.layer.cornerRadius = MINIBUTTON_SIZE/2;
//    self.miniButton.layer.borderWidth = 1;
//    self.miniButton.layer.borderColor = [UIColor colorWithRed:47/255.0 green:65/255.0 blue:146/255.0 alpha:0.15].CGColor;
//    [self.miniButton addTarget:self action:@selector(showView) forControlEvents:UIControlEventTouchUpInside];
//    self.miniButton.backgroundColor = UIColor.whiteColor;
//    [self.containerView addSubview:self.miniButton];
//    self.miniButton.hidden = YES;
    
    self.badgeView = [[CustomBadgeView alloc] init];
    [self.view addSubview:self.badgeView];
    self.badgeView.hidden = YES;
}

- (void)layoutViews {
    self.containView.frame = CGRectMake(0,
                                        0,
                                        self.view.bounds.size.width,
                                        self.view.bounds.size.height);
    self.chatTopView.frame = CGRectMake(0, 0, self.containView.bounds.size.width, self.topHeight);
    
    self.announcementView.frame = CGRectMake(0,self.topHeight,self.containView.bounds.size.width,self.containView.bounds.size.height - self.topHeight);
    
    self.chatView.frame = CGRectMake(0,self.topHeight,self.containView.bounds.size.width,self.containView.bounds.size.height - self.topHeight);
    
//    self.miniButton.frame = CGRectMake(10, self.containerView.bounds.size.height - MINIBUTTON_SIZE - 10, MINIBUTTON_SIZE, MINIBUTTON_SIZE);
    
    self.badgeView.frame = CGRectMake(10 + MINIBUTTON_SIZE*4/5, self.view.bounds.size.height - MINIBUTTON_SIZE - 10, self.badgeView.badgeSize, self.badgeView.badgeSize);
}

- (void)handleTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        [self.containView endEditing:YES];
    }
}

- (void)recallMsg:(NSString*)msgId
{
}

- (void)initData:(NSDictionary *)properties {
    NSDictionary *widgetExtraProps = properties;
    
    // key
    NSString *appKey = nil;
    NSString *password = self.info.localUserProperties[@"userId"];
    NSString *orgName = nil;
    NSString *token007 = nil;
    
    NSDictionary *keys = widgetExtraProps[@"keys"];
    token007 = keys[@"token"];
    NSString *appId = keys[@"agoraAppId"];
    NSString *host = keys[@"host"];
    
    // room
    NSString *chatRoomId = nil;
    NSString *roomUuid = self.info.roomInfo.roomUuid;
    
    // user
    NSString *avatarurl = properties[@"avatarurl"];
    NSString *userUuid = self.info.localUserProperties[@"userId"];
    NSString *userName = self.info.localUserInfo.userName;
    
    if (widgetExtraProps) {
        appKey = widgetExtraProps[@"appKey"];
        chatRoomId = widgetExtraProps[@"chatRoomId"];
        orgName = widgetExtraProps[@"orgName"];
    }
        
    // key
    if (appKey.length > 0) {
        self.launchData.appKey = appKey;
    }
    
    if (orgName.length > 0) {
        self.launchData.orgName = orgName;
    }
    
    if (password.length > 0) {
        self.launchData.password = password;
    }
    
    if (token007.length > 0) {
        self.launchData.token007 = token007;
    }
    
    if (host.length > 0){
        self.launchData.host = host;
    }
    
    if (appId.length > 0) {
        self.launchData.appId = appId;
    }
    
    // room
    if (chatRoomId.length > 0) {
        self.launchData.chatRoomId = chatRoomId;
    }
    
    if (roomUuid.length > 0) {
        self.launchData.roomUuid = roomUuid;
    }
    
    // user
    if (avatarurl.length > 0) {
        self.launchData.avatarurl = avatarurl;
    }
    
    if (userUuid.length > 0) {
        self.launchData.userUuid = userUuid;
    }
    
    if (userName.length > 0) {
        self.launchData.userName = userName;
    }
    
    if (![self.launchData checkIsLegal] || self.launchedFlag) {
        return;
    }
    if(self.launchData.token007.length > 0) {
        [self fetchHXToken];
    }
    
    
//    self.launchedFlag = YES;
//    [self launch];
}

- (void)fetchHXToken
{
    self.tokenRequest = [AgoraChatServerAPI createInstanceWithInputhost:self.launchData.host inputappId:self.launchData.appId inputtoken:self.launchData.token007 inputroomId:self.launchData.roomUuid inputuserId:self.info.localUserInfo.userUuid];
    __weak typeof(self) weakself = self;
    [self.tokenRequest fetchHXToken:self.launchData.userUuid success:^(NSDictionary<NSString *,id> * _Nonnull body) {
        if(body) {
            NSDictionary* bodyData = [body objectForKey:@"data"];
            if(bodyData) {
                NSString* hxToken = [bodyData objectForKey:@"token"];
                if(hxToken.length > 0) {
                    weakself.launchData.hxToken = hxToken;
                    weakself.launchedFlag = YES;
                    [weakself launch];
                }
            }
        }
        } failure:^(NSError * _Nonnull) {
            [WHToast showErrorWithMessage:[@"fcr_hyphenate_im_login_faild" agora_localized:@"AgoraWidgets"] duration:2 finishHandler:^{
                    
            }];
        }];
}

- (void)launch {
    ChatUserConfig* user = [[ChatUserConfig alloc] init];
    
    user.avatarurl = self.launchData.avatarurl;
    user.username = self.launchData.userUuid;
    user.nickname = self.launchData.userName;
    user.roomUuid = self.launchData.roomUuid;
    user.token = self.launchData.hxToken;
    if ([self.info.localUserInfo.userRole isEqualToString:@"teacher"]) {
        user.role = 1;
    } else {
        user.role = 2;
    }
    
    kChatRoomId = self.launchData.chatRoomId;
    
    NSString *appKey = self.launchData.appKey;
    NSString *password = self.launchData.password;
    
    ChatManager *manager = [[ChatManager alloc] initWithUserConfig:user
                                                            appKey:appKey
                                                          password:password
                                                        chatRoomId:kChatRoomId];
    
    manager.delegate = self;
    self.chatManager = manager;
    self.chatView.chatManager = self.chatManager;
    
    [self.chatManager launch];
}

#pragma mark - ChatManagerDelegate
- (void)chatMessageDidReceive
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray<AgoraChatMessage*>* array = [weakself.chatManager msgArray];
        [self.chatView updateMsgs:array];
        if(array.count > 0) {
            [self sendMessage:@"chatWidgetDidReceiveMessage"];
            if([self.containView isHidden]) {
                // 最小化了
                self.badgeView.hidden = NO;
            }
            if(self.chatTopView.currentTab != 0) {
                // 显示红点
                self.chatTopView.isShowRedNotice = YES;
            }
        }
    });
    
}

- (void)chatMessageDidSend:(AgoraChatMessage*)aInfo
{
    [self.chatView updateMsgs:@[aInfo]];
}

- (void)exceptionDidOccur:(NSString*)aErrorDescription
{
    [WHToast showErrorWithMessage:aErrorDescription duration:2 finishHandler:^{
            
    }];
}

- (void)mutedStateDidChanged
{
    if ([self.info.localUserInfo.userRole isEqualToString:@"teacher"]) {
        return;
    }
    self.chatView.chatBar.isAllMuted = self.chatManager.isAllMuted;
    self.chatView.chatBar.isMuted = self.chatManager.isMuted;
}

- (void)chatMessageDidRecall:(NSString*)aMessageId
{
    if(aMessageId.length > 0) {
        [self recallMsg:aMessageId];
    }
}

- (void)roomStateDidChanged:(ChatRoomState)aState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (aState) {
            case ChatRoomStateLogin:
                
                break;
            case ChatRoomStateLoginFailed:
                [WHToast showErrorWithMessage:[@"fcr_hyphenate_im_login_faild" agora_localized:@"AgoraWidgets"] duration:2 finishHandler:^{
                        
                }];
                break;
            case ChatRoomStateLogined:
                
                break;
            case ChatRoomStateJoining:
                
                break;
            case ChatRoomStateJoined:
                
                break;
            case ChatRoomStateJoinFail:
                [WHToast showErrorWithMessage:[@"fcr_hyphenate_im_join_faild" agora_localized:@"AgoraWidgets"] duration:2 finishHandler:^{
                        
                }];
                break;
            default:
                break;
        }
    });
}

- (void)announcementDidChanged:(NSString *)aAnnouncement isFirst:(BOOL)aIsFirst
{
    self.chatView.announcement = aAnnouncement;
    self.announcementView.announcement = aAnnouncement;
    if(!aIsFirst) {
        if([self.containView isHidden]) {
            // 最小化了
            self.badgeView.hidden = NO;
        }
        if(self.chatTopView.currentTab != 1) {
            // 显示红点
            self.chatTopView.isShowAnnouncementRedNotice = YES;
        }
    }
}

#pragma mark - ChatTopViewDelegate
- (void)chatTopViewDidSelectedChanged:(NSUInteger)nSelected
{
    if(nSelected == 0){
        [self.announcementView removeFromSuperview];
        [self.containView addSubview:self.chatView];
    }else{
        [self.chatView removeFromSuperview];
        [self.containView addSubview:self.announcementView];
    }
}

- (void)chatTopViewDidClickHide
{
    self.containView.hidden = YES;
//    self.miniButton.hidden = NO;
    self.badgeView.hidden = self.chatTopView.badgeView.hidden && self.chatTopView.announcementbadgeView.hidden;
    self.view.agora_width = 50;
    [self sendMessage:@"min"];
}

- (void)showView
{
    self.containView.hidden = NO;
//    self.miniButton.hidden = YES;
    if(self.chatTopView.currentTab == 0) {
        self.chatTopView.badgeView.hidden = YES;
        [self.chatView scrollToBottomRow];
    }
    if(self.chatTopView.currentTab == 1) {
        self.chatTopView.announcementbadgeView.hidden = YES;
    }
    self.badgeView.hidden = YES;
    if([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        self.view.agora_width = 300;
    }else
        self.view.agora_width = 200;
    
    [self sendMessage:@"max"];
}

#pragma mark - ChatViewDelegate
- (void)chatViewDidClickAnnouncement
{
    self.chatTopView.currentTab = 1;
}

- (void)msgWillSend:(NSString *)aMsgText
{
    [self.chatManager sendCommonTextMsg:aMsgText];
}

- (void)imageDataWillSend:(NSData*)aImageData
{
    [self.chatManager sendImageMsgWithData:aImageData msgType:ChatMsgTypeCommon asker:nil];
}

@end
