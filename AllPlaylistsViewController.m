//
//  AllPlaylistsViewController.m
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 7/20/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "AllPlaylistsViewController.h"
#import "MiddleViewCell.h"
#import "PlaylistViewController_iPad.h"
#import   "AudioManager.h"
#import  "PlaylistManager.h"
@interface AllPlaylistsViewController ()<UITableViewDataSource, UITableViewDelegate>{

    NSArray *toolbarItems;
    UIBarButtonItem *deleteButton;
}
@property (nonatomic, copy) NSArray *listArray;
@property (strong, nonatomic) UITableView * tableView;

@end

@implementation AllPlaylistsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Playlists"];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 75,self.view.bounds.size.width, self.view.bounds.size.height-75) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
        
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    deleteButton = [[UIBarButtonItem alloc]
                    initWithTitle:@"Delete"
                    style:UIBarButtonItemStyleBordered
                    target:self
                    action:@selector(deleteSelection)];
    [deleteButton setTintColor:[UIColor colorWithRed:0.7 green:0 blue:0 alpha:1]];
    [deleteButton setEnabled:NO];
    
    toolbarItems = [[NSArray alloc] initWithObjects:deleteButton, nil];
    [self setToolbarItems:toolbarItems animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Protocol
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_listArray count]>0)
        return [_listArray count];
    else return 0;
}
-(void)setPlaylistArray{
    
    _listArray=[[PlaylistManager getInstance] allPlaylists];
    [self setColorScheme];
    
}
- (void)deleteSelection
{
    NSArray *indexPaths;
    indexPaths = [_tableView indexPathsForSelectedRows];
    NSUInteger count = indexPaths.count;
    
    for (NSUInteger x = 0; x < count; x++)
        
        [[PlaylistManager getInstance] deletePlaylistAtIndex:[indexPaths[x] row]-x];
    [[PlaylistManager getInstance] loadAllPlaylist];
    [self setEditing:NO animated:NO];
    
    
    
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.navigationController setToolbarHidden:!editing animated:animated];
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    // Clear the selection when finished editing
    if (!editing)
    {
        [self updateSelectionCount];
    }
    [self setPlaylistArray];
}

- (void)updateSelectionCount
{
    NSUInteger count = [[self.tableView indexPathsForSelectedRows] count];
    NSString *title = @"Delete";
    
    if (count > 0) {
        title = [NSString stringWithFormat:@"%@ (%d)", title, count];
    }
    
    deleteButton.enabled = (count != 0);
    deleteButton.title = title;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // If the controls are visible don't allow cell interaction
    if (tableView.isEditing)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isEditing] == YES) {
            [self updateSelectionCount];
        }
        
        
        return;
    }
    
    PlaylistViewController_iPad* playerController =[[PlaylistViewController_iPad alloc] init];
    
    Playlist * playlist = [_listArray objectAtIndex:[indexPath row]];
  [playerController setCurrentPlaylist:playlist];
    [self.navigationController pushViewController:playerController animated:YES];
    
    
    
    
}
-(void)setColorScheme{
    
    
    self.tableView.backgroundColor=[AudioManager sharedInstance].bgColor;
    self.view.backgroundColor = [AudioManager sharedInstance].bgColor ;
 
    
    [self.tableView reloadData];
    
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

 - (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
     UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
     if ([cell isEditing] == YES) {
         [self updateSelectionCount];
     }
     return;
 
 }
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * identity = @"listViewCell";
    
    MiddleViewCell * cell = (MiddleViewCell *) [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        
        cell = [[MiddleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
    }
    
    Playlist *p =  [_listArray objectAtIndex:[indexPath row]];
    
    [cell setMiddleLabel: [NSString stringWithFormat:@"%.2ld",(unsigned long)([indexPath row]+1)]];
    [cell setLeftLabel:[p title]];
    [cell setRightLabel: [NSString stringWithFormat:@"%.2ld Tracks",(unsigned long)[[p tracks] count]]];
    
    return cell;
}
- (void)viewWillDisappear:(BOOL)animated
{
    
	[super viewWillDisappear:animated];
     
    [[NSNotificationCenter defaultCenter] removeObserver:self
     ];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setColorScheme) name:NOTIFICATION_COLORS_CHANGED object:nil];
  [self.tableView setFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    [self setPlaylistArray];
    
}

@end
