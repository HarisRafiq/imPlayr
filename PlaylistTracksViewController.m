//
//  PlaylistTracksViewController.m
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 6/25/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "PlaylistTracksViewController.h"
#import "TopPlayerView.h"
#import "MiddleViewCell.h"
#import "PlaylistViewController.h"
#import   "AudioManager.h"
#import  "PlaylistManager.h"
@interface PlaylistTracksViewController ()<UITableViewDataSource, UITableViewDelegate,TopPlayerViewDelegate>
@property (nonatomic, copy) NSArray *listArray;
@property (strong, nonatomic) UITableView * tableView;
@property (nonatomic) TopPlayerView *topPlayerView;
@end

@implementation PlaylistTracksViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 75,self.view.bounds.size.width, self.view.bounds.size.height-75) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    _topPlayerView=[[TopPlayerView alloc] initWithFrame:CGRectMake(0,0,320,75)];
    [self.view addSubview:_topPlayerView];
    [_topPlayerView setupForControlHeader];
        [_topPlayerView setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin];
    _topPlayerView.delegate=self;
    
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
  
 

}
- (void)viewWillDisappear:(BOOL)animated
{
    
	[super viewWillDisappear:animated];
    [_topPlayerView removeNotification];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
     ];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setColorScheme) name:NOTIFICATION_COLORS_CHANGED object:nil];
    [_topPlayerView addNotification];
    [self setPlaylistArray];
    
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
    [self setPlaylistArray];
    
    
    
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
        [ _topPlayerView setLeftText:[NSString stringWithFormat:@"%lu %@",(unsigned long)[[self.tableView indexPathsForSelectedRows] count],NSLocalizedString(@"Delete", nil)]];
        
        
        return;
    }
    PlaylistViewController* playerController =[[PlaylistViewController alloc] init];
    
    Playlist * playlist = [_listArray objectAtIndex:[indexPath row]];
    [playerController setCurrentPlaylist:playlist];
    [self.navigationController pushViewController:playerController animated:YES];
    
    
    
    
}
-(void)setColorScheme{
    
    
    self.tableView.backgroundColor=[AudioManager sharedInstance].bgColor;
    self.view.backgroundColor = [AudioManager sharedInstance].bgColor ;
    if(_tableView.editing)
        [_topPlayerView setEditViewForControlHeader];
    else [_topPlayerView setControlView];
    
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
- (void)editAction
{
    [self.tableView setEditing:!self.tableView.editing animated:NO];
    if(_tableView.editing)
        [_topPlayerView setEditViewForControlHeader];
    else [_topPlayerView setControlView];
    [self setPlaylistArray];
    
}
- (void)topPlayer:(TopPlayerView *)topPlayer didSelectIndex:(NSInteger)selectedIndex{
    
    if (_tableView.isEditing)
    {
        if(selectedIndex==0){
            if([[self.tableView indexPathsForSelectedRows] count]>0)
                [self deleteSelection];
            
            
            
        }
        if(selectedIndex==2)
            [self editAction];
    }
    
    
    else {
        if(selectedIndex==0){
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            
        }
        
        if(selectedIndex==2)
            [self editAction];
        
        
        
        
    }
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing)
    { if([[self.tableView indexPathsForSelectedRows] count]>0)
        [ _topPlayerView setLeftText:[NSString stringWithFormat:@"%lu %@",(unsigned long)[[self.tableView indexPathsForSelectedRows] count],NSLocalizedString(@"Delete", nil)]];
    else [ _topPlayerView setLeftText:NSLocalizedString(@"Clear", nil) ];
        
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


@end
