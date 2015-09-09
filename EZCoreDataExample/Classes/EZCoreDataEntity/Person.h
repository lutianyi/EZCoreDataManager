//
//  Person.h
//  EZCoreDataExample
//
//  Created by 卢天翊 on 15/9/9.
//  Copyright (c) 2015年 Lanou3G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * p_name;
@property (nonatomic, retain) NSNumber * p_age;

@end
