//
//  WTNodeViewModel.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTNodeViewModel.h"
#import "NetworkTool.h"
#import "WTURLConst.h"
#import "TFHpple.h"
#import "MJExtension.h"
#import "NSString+Extension.h"
#import "FMDatabase.h"

static FMDatabase *_db;

@implementation WTNodeViewModel

MJCodingImplementation

#pragma mark - Public Method
/**
 *  加载节点数据
 *
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)getNodeItemsWithSuccess:(void (^)(NSMutableArray<WTNodeViewModel *> *nodeVMs))success failure:(void(^)(NSError *error))failure
{
    
    [[NetworkTool shareInstance] GETWithUrlString: WTHTTPBaseUrl success:^(NSData *data) {
        
        NSMutableArray<WTNodeViewModel *> *nodeVMs = [self getNodeItemsWithData: data];
        
        if (success)
        {
            success(nodeVMs);
        }
        
    } failure:^(NSError *error) {
        
        if (failure)
        {
            failure(error);
        }
        
    }];
}

/**
 *  加载所有节点数据
 *
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
+ (void)loadAllNodeItemsWithSuccess:(void (^)(NSMutableArray<WTNodeViewModel *> *nodeVMs))success failure:(void(^)(NSError *error))failure
{
    // 1、从数据库中加载
    
    
    // 2、从网络上加载
    [[NetworkTool shareInstance] GETWithUrlString: WTAllNodeUrl success:^(NSArray *data) {
        
        NSMutableArray<WTNodeItem *> *nodeItems = [WTNodeItem mj_objectArrayWithKeyValuesArray: data];
        
        
        // 1、为所有节点的数据作排序处理
        //[self sortedArrayWithChineseObject: nodeItems];
        NSMutableArray *array = [self sortObjectsAccordingToInitialWith: nodeItems];
        [self saveNodeItemToCache: array];
        
        // 2、缓存到数据库中
        
        if (success)
        {
//            success(nodeVMs);
        }
        
    } failure:^(NSError *error) {
        
        if (failure)
        {
            failure(error);
        }
    }];
//
//    NSMutableArray<WTNodeItem *> *nodeItems = [WTNodeItem mj_objectArrayWithFilename: @"/Users/wutouqishigj/Desktop/nodeItems.plist"];
//    [self sortedArrayWithChineseObject: nodeItems];
}

#pragma mark - Private Method
/**
 *  根据二进制加载热门节点
 *
 *  @param data 二进制
 *
 *  @return 热门节点数组
 */
- (NSMutableArray<WTNodeViewModel *> *)getNodeItemsWithData:(NSData *)data
{
    NSMutableArray<WTNodeViewModel *> *nodeVMs = [NSMutableArray array];
    
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData: data];
    TFHppleElement *boxElement = [doc searchWithXPathQuery: @"//div[@class='box']"].lastObject;
    
    NSArray<TFHppleElement *> *cells = [boxElement searchWithXPathQuery: @"//div[@class='cell']"];
    
    for (int i = 1; i < cells.count; i++)
    {
        @autoreleasepool {
            
            TFHppleElement *cell = cells[i];
            
            WTNodeViewModel *nodeVM = [WTNodeViewModel new];
            
            nodeVM.title = [[cell searchWithXPathQuery: @"//span[@class='fade']"].firstObject content];
            
            NSArray<TFHppleElement *> *as = [cell searchWithXPathQuery: @"//a"];
            
            NSMutableArray<WTNodeItem *> *nodeItems = [NSMutableArray array];
            for (TFHppleElement *a in as)
            {
                @autoreleasepool {
                    
                    WTNodeItem *nodeItem = [WTNodeItem new];
                    
                    nodeItem.title = [a content];
                    nodeItem.url = [NSString stringWithFormat: @"%@%@", WTHTTPBaseUrl, [a objectForKey: @"href"]];
                    [nodeItems addObject: nodeItem];
                }
            }
            
            nodeVM.nodeItems = nodeItems;
            [nodeVMs addObject: nodeVM];
        }
    }
    
    return nodeVMs;
}

//数组排序
+ (void)sortedArrayWithChineseObject:(NSMutableArray<WTNodeItem *> *)nodeItems
{
    
    // 由于这里耗时时间太长，就把生成后的数据写入plist文件中
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        TICK
        
        for(NSUInteger i = 0; i < 5; i++)
        {
            for(NSUInteger j = 0; j < 5; j++)
            {
                NSString *pinyinFirst = [NSString lowercaseSpellingWithChineseCharacters: nodeItems[j].title];
                NSString *pinyinSecond = [NSString lowercaseSpellingWithChineseCharacters: nodeItems[j + 1].title];
                
                //此处为升序排序，若要降序排序，把NSOrderedDescending 换为NSOrderedAscending即可。
                if(NSOrderedDescending == [pinyinFirst compare:pinyinSecond])
                {
                    
                    WTNodeItem *nodeItem = nodeItems[j];
                    nodeItems[j] = nodeItems[j + 1];
                    nodeItems[j + 1] = nodeItem;
                }
            }
            
            WTLog(@"item:%@, thread:%@", nodeItems[i], [NSThread currentThread])
        }
//        WTLog(@"WTNodeItems:%@", nodeItems)
        [self saveNodeItemToCache: nodeItems];
        TOCK
    });
    
    
    //测试
    //    NSLog(@"%@", mArray);
}



+ (void)initialize
{

    // 获取cache路径
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    // 获取数据库保存的全路径
    NSString *filePath = [cachePath stringByAppendingPathComponent: @"nodeitem.sqlite"];
    
    // 创建一个数据库实例
    _db = [FMDatabase databaseWithPath: filePath];
    
    // 测试数据库是否打开成功
    if (_db.open)
    {
        WTLog(@"news.sqlte数据库打开成功");
    }
    else
    {
        WTLog(@"news.sqlte数据库打开成功");
    }
    
    // 创建表格
    BOOL flag = [_db executeUpdate: @"create table t_nodegroup(id integer primary key autoincrement, title text, groupid);"];
    BOOL flag2 = [_db executeUpdate: @"create table t_nodeitem(id integer primary key autoincrement, nodeitem blob, groupid integer, title text, uid integer);"];
    
    if (flag && flag2)
    {
        WTLog(@"t_nodeItem表格创建成功");
    }
    else
    {
        WTLog(@"t_nodeItem表格创建失败");
    }
}

+ (NSMutableArray *)queryAllNodeItemsFromCache
{
    
    FMResultSet *groupResultSet = [_db executeQuery: @"select groupid,title from t_nodegroup"];
    NSMutableArray *array = [NSMutableArray array];
    while (groupResultSet.next)
    {
        
        NSUInteger groupid = [groupResultSet intForColumnIndex: 0];
        NSString *title = [groupResultSet stringForColumnIndex: 1];
        
        FMResultSet *nodeItemResultSet = [_db executeQuery: @"select nodeitem from t_nodeitem where groupid = ?", @(groupid)];
        
        NSMutableArray *nodeItems = [NSMutableArray array];
        while (nodeItemResultSet.next)
        {
            NSData *nodeItemData = [nodeItemResultSet dataForColumnIndex: 0];
            WTNodeItem *nodeItem = [NSKeyedUnarchiver unarchiveObjectWithData: nodeItemData];
            
            [nodeItems addObject: nodeItem];
        }
        
        [array addObject: nodeItems];
    }
    return array;
}

+ (void)saveNodeItemToCache:(NSMutableArray *)array
{
    [_db executeUpdate: @"delete from t_nodegroup"];
    
    [_db executeUpdate: @"delete from t_nodeitem"];
    
    
    for (NSUInteger i = 0; i < array.count; i++)
    {
        [_db executeUpdate: @"insert into t_nodegroup(title, groupid) values(?, ?);", WTIndexTitle[i], @(i)];
        NSArray<WTNodeItem *> *nodeItems = array[i];
        
        for (NSUInteger j = 0; j < nodeItems.count; j++) {
            
            WTNodeItem *nodeItem = nodeItems[j];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject: nodeItem];
            
            
            
            [_db executeUpdate: @"insert into t_nodeitem(groupid, nodeitem, title, uid) values(?, ?, ?, ?);", @(i), data, nodeItem.title, @(nodeItem.uid)];
        }
    }
}

// 按首字母分组排序数组
+ (NSMutableArray *)sortObjectsAccordingToInitialWith:(NSArray *)nodeItems
{
    
    // 初始化UILocalizedIndexedCollation
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    //得出collation索引的数量，这里是27个（26个字母和1个#）
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    //初始化一个数组newSectionsArray用来存放最终的数据，我们最终要得到的数据模型应该形如@[@[以A开头的数据数组], @[以B开头的数据数组], @[以C开头的数据数组], ... @[以#(其它)开头的数据数组]]
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity: sectionTitlesCount];
    
    //初始化27个空数组加入newSectionsArray
    for (NSInteger index = 0; index < sectionTitlesCount; index++)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }
    
    //将每个名字分到某个section下
//    for (int i = 0; i < 30; i++) {
//        WTNodeItem *nodeItem = nodeItems[i];
//    }
    for (WTNodeItem *nodeItem in nodeItems) {
    
        //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第11（第一位是0），sectionNumber就为11
        NSInteger sectionNumber = [collation sectionForObject: nodeItem collationStringSelector:@selector(title)];
        //把name为“林丹”的p加入newSectionsArray中的第11个数组中去
        NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
        [sectionNames addObject: nodeItem];
    }
    
    //对每个section中的数组按照name属性排序
    for (NSInteger index = 0; index < sectionTitlesCount; index++)
    {
        NSMutableArray *personArrayForSection = newSectionsArray[index];
        NSArray *sortedPersonArrayForSection = [collation sortedArrayFromArray:personArrayForSection collationStringSelector:@selector(title)];
        newSectionsArray[index] = sortedPersonArrayForSection;
    }
    
    return newSectionsArray;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"nodeItems:%@, title:%@", self.nodeItems, self.title];
}
@end
