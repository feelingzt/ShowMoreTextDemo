//
//  RootVC.m
//  ShowMoreText
//
//  Created by yaoshuai on 2017/1/20.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "RootVC.h"
#import "Cell.h"
#import "Model.h"

static NSString *cellID = @"cellID";

@interface RootVC ()

@end

@implementation RootVC{
    NSArray<Model*> *_modelList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[Cell class] forCellReuseIdentifier:cellID];
    [self loadData];
}

// MARK: - 隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}

// MARK: - 加载数据
- (void)loadData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"TextInfo" withExtension:@"json"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSArray<NSDictionary*> *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSMutableArray<Model *> *arrM = [NSMutableArray arrayWithCapacity:array.count];
        
        [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Model *model = [[Model alloc] initWithDict:obj];
            [arrM addObject:model];
        }];
        _modelList = arrM.copy;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

// MARK: - tableView数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _modelList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    Model *model = _modelList[indexPath.row];
    cell.model = model;
    [cell setShowMoreBlock:^(UITableViewCell *currentCell) {
        NSIndexPath *reloadIndexPath = [self.tableView indexPathForCell:currentCell];
        [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    return cell;
}

// MARK: - 返回cell高度的代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Model *model = _modelList[indexPath.row];
    if (model.isShowMoreText){
        return [Cell moreHeight:model];
    } else{
        return [Cell defaultHeight:model];
    }
}


@end
