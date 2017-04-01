//
//  SQLiteDatabaseManager.h
//  SQLite
//
//  Created by Young on 2017/3/23.
//  Copyright © 2017年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteDatabaseManager : NSObject

+ (sqlite3 *)openOrCreateDatabaseWithFilePath:(NSString *)filePath;
+ (void)closeDatabase:(sqlite3 *)database;

@end
