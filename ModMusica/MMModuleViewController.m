//
//  MMModuleViewController.m
//  ModMusica
//
//  Created by Travis Henspeter on 6/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMModuleViewController.h"
#import "MMModuleCellView.h"
#import "MMModuleSwitchCellView.h"
#import "UIView+Layout.h"
#import "UIColor+HBVHarmonies.h"
#import "MMModuleEditCellView.h"

static NSString *kModuleCellId = @"ModuleCellId";
static NSString *kModuleSwitchCellId = @"ModuleSwitchCellId";
static NSString *kModuleEditCellId = @"ModuleEditCellId";

@interface MMModuleViewController ()

@property (nonatomic,strong)        UILabel         *sectionHeaderLabel1;
@property (nonatomic,strong)        UIView          *sectionHeaderView1;

@property (nonatomic,strong)        UILabel         *sectionHeaderLabel2;
@property (nonatomic,strong)        UIView          *sectionHeaderView2;


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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.delegate && self.datasource) {
        [self.tableView reloadData];
    }
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

- (void)handleActionSwitch:(id)sender
{
    UISwitch *mySwitch = (UISwitch *)sender;
    if (mySwitch.tag == self.modules.count) {
        [self.delegate moduleView:self shuffleDidChange:(int)mySwitch.isOn];
        [self.tableView reloadData];
    }else if (mySwitch.tag == 0){
        [self.delegate moduleView:self lockTempoDidChange:(int)mySwitch.isOn];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        return (self.modules.count + 1);
    }else{
        return 1;
    }
}

- (void)configureModCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    UIColor *fillColor = [self.delegate currentFillColor];
    UIColor *textColor = [self.delegate currentTextColor];
    
    MMModuleCellView *c = (MMModuleCellView *)cell;
    NSDictionary *mod = self.modules[indexPath.row];
    c.titleLabel.text = mod[@"title"];
    c.titleLabel.textColor = textColor;
    NSNumber *purchased = mod[@"purchased"];
    c.actionButton.tag = indexPath.row;
    c.actionButton.layer.cornerRadius = 4;
    c.buttonTrailingEdgeConstraint.constant = ([self.delegate openDrawerWidth] - 8);
    c.contentView.backgroundColor = [fillColor jitterWithPercent:5];
    [c.actionButton setTitleColor:[fillColor jitterWithPercent:5] forState:UIControlStateNormal];
    [c.actionButton setBackgroundColor:[textColor jitterWithPercent:5]];
    [c.actionButton addTarget:self action:@selector(tapInCellButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if (purchased.integerValue) {
        [c.actionButton setTitle:NSLocalizedString(@"PLAY", nil) forState:UIControlStateNormal];
    }else{
        [c.actionButton setTitle:NSLocalizedString(@"GET", nil) forState:UIControlStateNormal];
    }
    
    if ([self.datasource modsAreShuffled:self]) {
        c.actionButton.enabled = NO;
    }else{
        c.actionButton.enabled = YES;
    }
    
    [c.contentView layoutIfNeeded];
}

- (void)configureSwitchCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UIColor *fillColor = [self.delegate currentFillColor];
    UIColor *textColor = [self.delegate currentTextColor];
    
    MMModuleSwitchCellView *c = (MMModuleSwitchCellView *)cell;
    c.actionSwitch.tag = indexPath.row;
    c.buttonTrailingEdgeConstraint.constant = ([self.delegate openDrawerWidth] - 8);
    c.contentView.backgroundColor = [fillColor jitterWithPercent:5];
    
    [c.actionSwitch setTintColor:[textColor jitterWithPercent:5]];
    [c.actionSwitch setOnTintColor:[textColor jitterWithPercent:5]];
    c.titleLabel.textColor = textColor;
    [c.actionSwitch addTarget:self action:@selector(handleActionSwitch:) forControlEvents:UIControlEventValueChanged];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    UIColor *fillColor = [self.delegate currentFillColor];
    UIColor *textColor = [self.delegate currentTextColor];
    
    tableView.backgroundView.backgroundColor = fillColor;
    tableView.backgroundColor = fillColor;
    
    self.sectionHeaderLabel1.textColor = textColor;
    self.sectionHeaderView1.backgroundColor = fillColor;
    self.sectionHeaderLabel2.textColor = textColor;
    self.sectionHeaderView2.backgroundColor = fillColor;

    if (indexPath.section == 0) {
        
        if (indexPath.row < self.modules.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:kModuleCellId forIndexPath:indexPath];
            [self configureModCell:cell atIndexPath:indexPath];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:kModuleSwitchCellId forIndexPath:indexPath];
            [self configureSwitchCell:cell atIndexPath:indexPath];
            [(MMModuleSwitchCellView *)cell titleLabel].text = @"shuffle";
        }

    }else if (indexPath.section == 1){

        cell = [tableView dequeueReusableCellWithIdentifier:kModuleSwitchCellId forIndexPath:indexPath];
        [self configureSwitchCell:cell atIndexPath:indexPath];
        [(MMModuleSwitchCellView *)cell titleLabel].text = @"lock";
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
        UILabel *titleLabel = [UILabel new];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [self.delegate currentTextColor];
        titleLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]*1.3];
    if (section == 0) {
        titleLabel.text = NSLocalizedString(@"music",nil);
        self.sectionHeaderLabel1 = titleLabel;
        self.sectionHeaderView1 = header;

    }else if (section == 1){
        self.sectionHeaderLabel2 = titleLabel;
        self.sectionHeaderView2 = header;
        titleLabel.text = NSLocalizedString(@"tempo",nil);

    }
        [header addSubview:titleLabel];
        [header addConstraint:[titleLabel pinEdge:LayoutEdge_Left
                                           toEdge:LayoutEdge_Left
                                           ofView:header
                                        withInset:8]];
        
        [header addConstraint:[titleLabel alignCenterYToSuperOffset:0]];
        
        [titleLabel layoutIfNeeded];
        

        return header;
        
    
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
