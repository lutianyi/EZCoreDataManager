//
//  CoreDataManager.h
//  LOCoreDataSample
//
//  Created by 卢天翊 on 15/8/26.
//  Copyright (c) 2015年 Lanou3G. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZCoreDataManager : NSObject

/**
 *  可视化模型文件(默认与项目名相同)
 */
@property (nonatomic, copy) NSString * xcdatamodeldName;

/**
 *  数据库保存的文件(默认与项目名相同)
 */
@property (nonatomic, copy) NSString * databaseName;

/**
 *  单例的初始化类方法
 *
 *  @return CoreDataManager
 */
+ (EZCoreDataManager *)defaultManager;

/**
 *  添加一个对象模型到数据库中
 *
 *  @param name       模型类的名字
 *  @param dictionary 需要对应赋值的属性
 */
- (void)addManagedObjectForName:(NSString *)name dictionary:(NSDictionary *)dictionary;

/**
 *  查询对象模型
 *
 *  @param name      模型类的名字
 *  @param predicate 创建一个谓词 e.g. name = ezer AND age = 15, description CONTAINAR
 *  @param sortkeys  用来排序的Keys(注意是个数组)
 *
 *  @return 返回查到的对象, 在外部使用时应与name对应
 */
- (NSArray *)fetchEntitiesWithName:(NSString *)name predicate:(NSPredicate *)predicate sortKeys:(NSArray *)keys;

/**
 *  删除对象模型
 *
 *  @param models 对象模型数组(注意是数组, 尽管是删除一个也要数组)
 */
- (void)deleteAllEntityObjects:(NSArray *)objects;

@end
