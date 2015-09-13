//
//  CoreDataManager.m
//  LOCoreDataSample
//
//  Created by 卢天翊 on 15/8/26.
//  Copyright (c) 2015年 Lanou3G. All rights reserved.
//

#import "EZCoreDataManager.h"
@import CoreData;

@interface EZCoreDataManager ()

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;

@end

@implementation EZCoreDataManager

static EZCoreDataManager * s_defaultManager = nil;

+ (EZCoreDataManager *)defaultManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        s_defaultManager = [[EZCoreDataManager alloc] init];
    });
    return s_defaultManager;
}

/**
 *  单例的初始化方法, 在init方法中初始化单例类持有的对象
 *
 *  @return 初始化后的对象
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 添加观察者, 当ManagerObjectContext发生变化时调用saveContext方法
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveContext) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    }
    return self;
}

- (void)addManagedObjectForName:(NSString *)name dictionary:(NSDictionary *)dictionary {
    
    NSManagedObject * managerObject = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.managedObjectContext];
    
    [managerObject setValuesForKeysWithDictionary:dictionary];
}

- (NSArray *)fetchEntitiesWithName:(NSString *)name predicate:(NSPredicate *)predicate sortKeys:(NSArray *)keys {
    
    // 实例化查询请求
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:name];
    
    // 谓词搜索如果没有谓词, 那么默认查询全部
    if (predicate) {
        
        [fetchRequest setPredicate:predicate];
    }
    
    // 如果没有用来排序的key, 那么默认不排序
    if (keys) {
        
        // 如果有排序的Key就先创建一个数组来接收多个NSSortDescriptor对象(尽管是一个, 因为setSortDescriptors:方法需要数组作为参数)
        NSMutableArray * sortDescriptorKeys = [NSMutableArray new];
        
        // 遍历所有的用来排序的key
        for (NSString * key in keys) {
            
            // 每有一个Key, 就使用该key来创建一个NSSortDescriptor
            NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
            
            // 在sortDescriptorKeys数组中添加一个NSSortDescriptor元素
            [sortDescriptorKeys addObject:sortDescriptor];
        }
        
        // 查询请求设置排序方式
        [fetchRequest setSortDescriptors:sortDescriptorKeys];
    }
    
    // 使用数组来接收查询到的内容
    NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    // 创建一个新的数组返回, 在外部去做判断
    return fetchedObjects ? fetchedObjects : [NSArray new];
}

- (void)deleteAllEntityObjects:(NSArray *)objects {
    
    // 遍历删除传进来数组中的元素对应的表内容
    for (NSManagedObject * object in objects) {
        
        // 使用管理者删除对象, 数组中的元素并没有缺少
        [self.managedObjectContext deleteObject:object];
    }
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    
    if (DEBUG) {
        NSLog(@"%@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    }
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 *  模型器的懒加载方法
 *
 *  @return 唯一的模型器
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (!_managedObjectModel) {
        
        NSURL * modelURL = [[NSBundle mainBundle] URLForResource:self.xcdatamodeldName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

/**
 *  链接器的懒加载方法
 *
 *  @return 唯一的链接器对象
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (!_persistentStoreCoordinator) {
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSURL * storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", self.databaseName]];
        
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSInferMappingModelAutomaticallyOption: @YES, NSMigratePersistentStoresAutomaticallyOption: @YES} error:nil];
    }
    return _persistentStoreCoordinator;
}

/**
 *  管理者的懒加载方法
 *
 *  @return 唯一的管理者对象
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (!_managedObjectContext) {
        
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _managedObjectContext;
}

# pragma mark - Core Data Model Name
/**
 *  可视化Model类的对应名称, 如果没有就使用当前的BundleName关联
 */
- (NSString *)xcdatamodeldName {
    
    if (!_xcdatamodeldName) {
        _xcdatamodeldName = [self currentBundleName];
    }
    return _xcdatamodeldName;
}

# pragma mark - Database Name
/**
 *  保存到本地的文件名称, 如果没有保存为BundleName.sqlite
 */

- (NSString *)databaseName {
    
    if (!_databaseName) {
        _databaseName = [self currentBundleName];
    }
    return _databaseName;
}

/**
 *  当前的BundleName
 */
- (NSString *)currentBundleName {
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

# pragma mark - Context Save
/**
 *  ManagerObjectContext的保存方法
 */
- (void)saveContext {
    
    [self.managedObjectContext save:nil];
}

@end
