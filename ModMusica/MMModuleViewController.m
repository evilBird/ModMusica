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
#import "MMModuleManager.h"

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
    NSString *modName = [self.datasource moduleNamesForView:self][button.tag];
    [self.delegate moduleView:self tappedButton:button selectedModuleWithName:modName];
}

- (void)handleActionSwitch:(id)sender
{
    UISwitch *mySwitch = (UISwitch *)sender;
    if (mySwitch.tag == 0){
        [self.delegate moduleView:self lockTempoDidChange:(int)mySwitch.isOn];
    }else{
        [self.delegate moduleView:self shuffleDidChange:(int)mySwitch.isOn];
        [self.tableView reloadData];
    }
}

- (void)setDatasource:(id<MMModuleViewControllerDatasource>)datasource
{
    _datasource = datasource;
    [self.tableView reloadData];
}

- (NSArray *)modules
{
    if (!self.datasource) {
        return nil;
    }
    
    return [self.datasource modulesForModuleView:self];
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
        return ([self.datasource moduleNamesForView:self].count + 1);
    }else{
        return 1;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *fillColor = [self.delegate currentFillColor];
    UIColor *lightFillColor = [fillColor blendWithColor:[UIColor whiteColor] weight:0.1];
    UIColor *darkFillColor = [fillColor blendWithColor:[UIColor blackColor] weight:0.1];
    
    UIColor *textColor = [self.delegate currentTextColor];
    UIColor *lightTextColor = [textColor blendWithColor:[UIColor whiteColor] weight:0.1];
    UIColor *darkTextColor = [textColor blendWithColor:[UIColor blackColor] weight:0.1];
    
    cell.contentView.backgroundColor = [fillColor jitterWithPercent:2];
    
    if ([cell isKindOfClass:[MMModuleCellView class]]) {
        MMModuleCellView *c = (MMModuleCellView *)cell;
        NSString *modName = [self.datasource moduleNamesForView:self][indexPath.row];
        c.titleLabel.text = modName;
        c.titleLabel.textColor = [textColor jitterWithPercent:2];
        c.buttonTrailingEdgeConstraint.constant = ([self.delegate openDrawerWidth] - 8);
        
        if ([modName isEqualToString:[self.datasource currentModName]] && [self.datasource playbackIsActive]) {
            c.actionButton.selected = YES;
        }else{
            c.actionButton.selected = NO;
        }
        
        if ([self.datasource modsAreShuffled:self]) {
            c.actionButton.enabled = NO;
        }else{
            c.actionButton.enabled = YES;
        }
        
        c.actionButton.tintColor = [UIColor clearColor];
        
        [c.actionButton setTitleColor:fillColor forState:UIControlStateNormal];
        [c.actionButton setTitleColor:darkFillColor forState:UIControlStateDisabled];
        [c.actionButton setTitleColor:lightFillColor forState:UIControlStateSelected];
        
        if ([self.datasource modIsPurchased:modName]) {
            [c.actionButton setTitle:@"PLAY" forState:UIControlStateNormal];
            [c.actionButton setTitle:@"PLAYING" forState:UIControlStateSelected];
            [c.actionButton setTitle:@"..." forState:UIControlStateDisabled];
        }else{
            [c.actionButton setTitle:[self.datasource formattedPriceForMod:modName]
                            forState:UIControlStateNormal];
            [c.actionButton setTitle:[self.datasource formattedPriceForMod:modName]
                            forState:UIControlStateHighlighted|UIControlStateSelected];
            [c.actionButton setTitle:@"..." forState:UIControlStateDisabled];
        }
        
        if (c.actionButton.isEnabled && !c.actionButton.isSelected) {
            [c.actionButton setBackgroundColor:textColor];
        }else if (c.actionButton.isEnabled && c.actionButton.isSelected){
            [c.actionButton setBackgroundColor:lightTextColor];
        }else{
            [c.actionButton setBackgroundColor:darkTextColor];
        }
        
        [c.contentView layoutIfNeeded];
        
    }else if ([cell isKindOfClass:[MMModuleSwitchCellView class]]){
        MMModuleSwitchCellView *c = (MMModuleSwitchCellView *)cell;
        c.titleLabel.textColor = [textColor jitterWithPercent:2];
        c.actionSwitch.tag = indexPath.row;
        c.buttonTrailingEdgeConstraint.constant = ([self.delegate openDrawerWidth] - 8);
        [c.actionSwitch setTintColor:textColor];
        [c.actionSwitch setOnTintColor:textColor];
        c.titleLabel.textColor = textColor;
        [c.contentView layoutIfNeeded];
    }
}

- (void)configureModCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MMModuleCellView *c = (MMModuleCellView *)cell;
    NSString *modName = [self.datasource moduleNamesForView:self][indexPath.row];
    c.titleLabel.text = modName;
    c.actionButton.tag = indexPath.row;
    c.actionButton.layer.cornerRadius = 4;
    c.buttonTrailingEdgeConstraint.constant = ([self.delegate openDrawerWidth] - 8);
    [c.actionButton addTarget:self action:@selector(tapInCellButton:) forControlEvents:UIControlEventTouchUpInside];
    [c.actionButton setTintColor:[UIColor clearColor]];
}

- (void)configureSwitchCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MMModuleSwitchCellView *c = (MMModuleSwitchCellView *)cell;
    c.actionSwitch.tag = indexPath.row;
    c.buttonTrailingEdgeConstraint.constant = ([self.delegate openDrawerWidth] - 8);
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
        
        if (indexPath.row < [self.datasource moduleNamesForView:self].count) {
            
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
        titleLabel.text = @"music";
        self.sectionHeaderLabel1 = titleLabel;
        self.sectionHeaderView1 = header;

    }else if (section == 1){
        self.sectionHeaderLabel2 = titleLabel;
        self.sectionHeaderView2 = header;
        titleLabel.text = @"tempo";

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
