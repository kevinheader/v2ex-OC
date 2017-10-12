//
//  WTLoginViewController.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/23.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTLogin2FARequestItem;
@interface WTLoginViewController : UIViewController
/** 登陆成功的回调 */
@property (nonatomic, copy) void (^loginSuccessBlock)();

/** 两步验证请求参数 */
@property (nonatomic, strong) WTLogin2FARequestItem *twoFArequestItem;
@end
