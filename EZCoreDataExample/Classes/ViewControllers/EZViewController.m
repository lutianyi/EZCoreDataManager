//
//  EZViewController.m
//  EZCoreDataExample
//
//  Created by 卢天翊 on 15/9/9.
//  Copyright (c) 2015年 Lanou3G. All rights reserved.
//

#import "EZViewController.h"
#import "Person.h"

@interface EZViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView * myTableView;
@property (strong, nonatomic) NSMutableArray * persenList;

@end

@implementation EZViewController

@synthesize myTableView, persenList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.myTableView];
    
    [self fetchWithReloadData];
}

- (void)fetchWithReloadData {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        persenList = [[NSMutableArray alloc] initWithArray:[[EZCoreDataManager defaultManager] fetchEntitiesWithName:@"Person" predicate:nil sortKeys:nil]];
        
        [self.myTableView reloadData];
    });
}

# pragma mark - Table View DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return persenList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * identifier = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    Person * personEntity = persenList[indexPath.row];
    
    cell.textLabel.text = personEntity.p_name;
    cell.detailTextLabel.text = [personEntity.p_age stringValue];
    
    return cell;
}

# pragma mark - Lazy loading method

- (UITableView *)myTableView {
    
    if (!myTableView) {
        
        myTableView = [[UITableView alloc] initWithFrame:self.view.frame];
        myTableView.delegate = self;
        myTableView.dataSource = self;
    }
    return myTableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
