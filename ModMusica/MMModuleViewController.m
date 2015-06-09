//
//  MMModuleViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMModuleViewController.h"
#import "MMModuleCellView.h"
#import "UIView+Layout.h"
#import "UIColor+HBVHarmonies.h"

@interface MMModuleViewController ()

@property (nonatomic,strong)        UILabel         *sectionHeaderLabel;
@property (nonatomic,strong)        UIView          *sectionHeaderView;

@end

@implementation MMModuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.sectionHeaderHeight = 40;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)tapInCellButton:(id)sender
{
    UIButton *button = sender;
    if (button.tag < self.modules.count) {
        NSDictionary *mod = self.modules[button.tag];
        NSString *modName = mod[@"title"];
        [self.delegate moduleView:self selectedModuleWithName:modName];
    }
}

- (void)setDatasource:(id<MMModuleViewControllerDatasource>)datasource
{
    _datasource = datasource;
    self.modules = [_datasource modulesForModuleView:self];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.modules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ModuleCellId" forIndexPath:indexPath];
    
    MMModuleCellView *c = (MMModuleCellView *)cell;
    NSDictionary *mod = self.modules[indexPath.row];
    c.titleLabel.text = mod[@"title"];
    NSNumber *purchased = mod[@"purchased"];
    c.actionButton.tag = indexPath.row;
    c.actionButton.layer.cornerRadius = 5;
    c.buttonTrailingEdgeConstraint.constant = ([self.delegate openDrawerWidth] - 8);
    UIColor *fillColor = [self.delegate currentFillColor];
    UIColor *textColor = [self.delegate currentTextColor];
    
    c.contentView.backgroundColor = [fillColor jitterWithPercent:5];
    
    tableView.backgroundView.backgroundColor = fillColor;
    
    [c.actionButton setTitleColor:c.contentView.backgroundColor forState:UIControlStateNormal];
    
    [c.actionButton setBackgroundColor:textColor];
    c.titleLabel.textColor = textColor;
    self.sectionHeaderLabel.textColor = textColor;
    self.sectionHeaderView.backgroundColor = [fillColor jitterWithPercent:5];
    tableView.backgroundColor = [fillColor jitterWithPercent:5];
    
    [c.actionButton addTarget:self action:@selector(tapInCellButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if (purchased.integerValue) {
        [c.actionButton setTitle:NSLocalizedString(@"PLAY", nil) forState:UIControlStateNormal];
    }else{
        [c.actionButton setTitle:NSLocalizedString(@"GET", nil) forState:UIControlStateNormal];
    }
    // Configure the cell...
    
    [c.contentView layoutIfNeeded];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
        UILabel *titleLabel = [UILabel new];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [self.delegate currentTextColor];
        titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        titleLabel.text = NSLocalizedString(@"My Mods",nil);
        [header addSubview:titleLabel];
        [header addConstraint:[titleLabel pinEdge:LayoutEdge_Left
                                           toEdge:LayoutEdge_Left
                                           ofView:header
                                        withInset:8]];
        [header addConstraint:[titleLabel alignCenterYToSuperOffset:0]];
        
        [titleLabel layoutIfNeeded];
        
        self.sectionHeaderLabel = titleLabel;
        self.sectionHeaderView = header;
        return header;
        
    }
    
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
