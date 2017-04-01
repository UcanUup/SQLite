//
//  ViewController.m
//  SQLite
//
//  Created by Young on 2017/3/16.
//  Copyright © 2017年 Young. All rights reserved.
//

#import "ViewController.h"
#import "SQLiteManager.h"
#import "FriendTableManager.h"

#define TABLE_NUM 500
#define RECORD_NUM 1000

#define QUERY_NUM 500

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self createData];
//    [self createIndex];
//    [self deleteIndex];
    [self queryData];
}

#pragma mark - 创建和查询

- (void)createData {
    for (NSInteger i = 0; i < TABLE_NUM; i++) {
        [FriendTableManager checkTableWithId:i];
        
        NSMutableArray *messageArray = [NSMutableArray array];
        for (NSInteger j = 0; j < RECORD_NUM; j++) {
            int friendId = (int)i;
            int senderId = [self randomNumber:1 to:10000];
            int receiverId = [self randomNumber:1 to:10000];
            int sendTime = [self randomNumber:1 to:1000000];
            int receiveTime = [self randomNumber:1 to:1000000];
            int sendLocation = [self randomNumber:1 to:1000];;
            int receiveLocation = [self randomNumber:1 to:1000];
            int messageId = (int)j;
            NSString *messageContent = [self randomString:[self randomNumber:1 to:500]];
            NSData *extraInfo = [[self randomString:[self randomNumber:1 to:500]] dataUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *message = @[@(friendId), @(senderId), @(receiverId), @(sendTime), @(receiveTime), @(sendLocation), @(receiveLocation), @(messageId), messageContent, extraInfo];
            [messageArray addObject:message];
        }
        
        [[SQLiteManager sharedInstance] modifyDatabaseWithFilePath:[FriendTableManager databaseFilePath] sql:[FriendTableManager sqlForInsertMessageWithId:i] parametersArray:messageArray stopWhenError:NO];
        NSLog(@"创建表结束 %@", @(i));
    }
}

- (void)queryData {
    for (NSInteger i = 0; i < QUERY_NUM; i++) {
        [FriendTableManager checkTableWithId:i];
        NSArray *dataArray = [[SQLiteManager sharedInstance] queryDatabaseWithFilePath:[FriendTableManager databaseFilePath] sql:[FriendTableManager sqlForSearchMessageWithId:i] columnTypes:[FriendTableManager columnTypesForSearchMessage]];
        for (NSArray *rowData in dataArray) {
            NSLog(@"查询结果 %@ %@ %@ %@", rowData[0], rowData[1], rowData[2], rowData[3]);
        }
    }
}

#pragma mark - 索引

- (void)createIndex {
    for (NSInteger i = 0; i < TABLE_NUM; i++) {
        int resultCode = [FriendTableManager createIndexWithId:i];
        if (resultCode != 0) {
            NSLog(@"插入索引失败 %@", @(i));
        }
    }
    NSLog(@"插入索引完成");
}

- (void)deleteIndex {
    for (NSInteger i = 0; i < TABLE_NUM; i++) {
        int resultCode = [FriendTableManager deleteIndexWithId:i];
        if (resultCode != 0) {
            NSLog(@"删除索引失败 %@", @(i));
        }
    }
    NSLog(@"删除索引完成");
}

#pragma mark - 随机数据

- (NSString *)randomString:(int)length {
    char data[length];
    for (int x = 0; x < length; data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
}

- (int)randomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

@end
