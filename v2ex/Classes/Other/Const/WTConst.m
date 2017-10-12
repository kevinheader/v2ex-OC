//
//  WTConst.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/30.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//



/** 标题View的高度 */
//CGFloat const WTTitleViewHeight = 64;
/** 导航栏的Y的最大值  */
//CGFloat const WTNavigationBarMaxY = 64;
/** TabBar的高度*/
CGFloat const WTTabBarHeight = 49;
/** 通用边距*/
CGFloat const WTMargin = 8;
/** 工具条的高度 */
CGFloat const WTToolBarHeight = 44;
/** 导航栏的高度 */
CGFloat const WTNavigationBarHeight = 20;
/** 状态栏的高度 */
CGFloat const WTStatusBarHeight = 44;

/** App白天主色调 */
NSString * const WTAppLightColor = @"#28AD54";

/** 正常颜色*/
NSString * const WTNormalColor = @"#515151";

/** 非正常颜色*/
NSString * const WTNoNormalColor = @"#25A14F";

/** 话题主颜色　*/
NSString * const WTTopicCellMainColor = @"@494949";

NSString * const WTNoExistMemberTip = @"不存在这个用户";

/** 工具栏上按钮点击的通知 */
NSString * const WTToolBarButtonClickNotification = @"WTToolBarButtonClickNotification";
/** 登陆状态发生变化 通知　*/
NSString * const WTLoginStateChangeNotification = @"WTLoginStateChangesNotification";

/** 用户控制器头部View的高度 */
CGFloat const WTUserInfoHeadViewHeight = 200;
/** 用户控制器toolBar的高度*/
CGFloat const WTUserInfoToolBarHeight = 44;

/** 未读通知 */
NSString * const WTUnReadNotificationNotification = @"WTUnReadNotificationNotification";

/** 未读通知个数 */
NSString * const WTUnReadNumKey = @"WTUnReadNumKey";
/** 需要两步验证 */
NSString * const WT2FALoginTip = @"你的 V2EX 账号已经开启了两步验证，请输入验证码继续";


/** 两步验证通知 */
NSString * const WTTwoStepAuthNSNotification = @"WTTwoStepAuthNSNotification";

/** 两步验证通知Once的key */
NSString * const WTTwoStepAuthWithOnceKey = @"WTTwoStepAuthWithOnceKey";
