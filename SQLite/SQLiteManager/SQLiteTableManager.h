//
//  SQLiteTableManager.h
//  SQLite
//
//  Created by Young on 2017/3/23.
//  Copyright © 2017年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteTableManager : NSObject

+ (NSArray *)queryWithDatabase:(sqlite3 *)database sql:(NSString *)sql columnTypes:(NSArray *)columnTypes;
+ (int)modifyWithDatabase:(sqlite3 *)database sql:(NSString *)sql;
+ (int)modifyWithDatabase:(sqlite3 *)database sql:(NSString *)sql parameters:(NSArray *)parameters;
+ (BOOL)modifyWithDatabase:(sqlite3 *)database sql:(NSString *)sql parametersArray:(NSArray<NSArray *> *)parametersArray stopWhenError:(BOOL)stopWhenError;

@end
