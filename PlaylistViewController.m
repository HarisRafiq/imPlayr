//
//  PlaylistViewController.m
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 6/25/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "PlaylistViewController.h"
#import "TopPlayerView.h"
#import "Utitlities.h"
#import "playrsMemory.h"
 #import "imConstants.h"
#import "MiddleViewCell.h"
#import  "AudioManager.h"
@interface PlaylistViewController ()<UITableViewDataSource, UITableViewDelegate,TopPlayerViewDelegate>{
    
     Playlist *currentPlaylist;
}
@property (nonatomic, copy) NSArray *tracks;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic) TopPlayerView *topPlayerView;


@end
@implementation PlaylistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [[AudioManager sharedInstance] setPlaylist:currentPlaylist];
    
    [[AudioManager sharedInstance] setCurrentTrackIndex:[indexPath row]];
    
    [[AudioManager sharedInstance] _resetStreamer];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




-(void)setCurrentPlaylist:(Playlist *)p{
    currentPlaylist=p;
    
    [self setTracks];
    
}
-(void)setTracks{
    NSArray *l= [currentPlaylist tracksFromPlaylist] ;
    self.tracks= l ;
    
    [self setColorScheme];
}

- (void)viewDidLoad {
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
 
    //[self.tableView setLongPressReorderEnabled:YES];
    self.tableView.backgroundColor=[AudioManager sharedInstance].bgColorDark;
    self.view.backgroundColor = [AudioManager sharedInstance].bgColorDark ;
    _topPlayerView=[[TopPlayerView alloc] initWithFrame:CGRectMake(0,0,320,75)];
    [self.view addSubview:_topPlayerView];
     [_topPlayerView setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin];
    [_topPlayerView setupForControlForSubHeader];
    _topPlayerView.delegate = self;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
 
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
     ];
    [_topPlayerView removeNotification];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setColorScheme) name:NOTIFICATION_COLORS_CHANGED object:nil];
    [_topPlayerView addNotification];
    [self setTracks];
    
}

#pragma mark - UITableViewDataSource Protocol

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
    
    if([_tracks count]>0)
        
        return [_tracks count];
    
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identity = @"trackListCell";
    
    MiddleViewCell * cell = (MiddleViewCell *) [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil)
        cell = [[MiddleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    
    
    
    playrsTrack *t=[_tracks objectAtIndex:[indexPath row]];
    
    
    
    [cell setMiddleLabel: [NSString stringWithFormat:@"%.2d",([indexPath row]+1)]];
    [cell setLeftLabel:[t title]];
    [cell setRightLabel: [Utitlities convertTimeFromSeconds: [t.duration stringValue]]];
    
    return cell;
}


#pragma mark - UITableViewDelegate Protocol

-(void)setColorScheme{
   
            
            
            
    self.tableView.backgroundColor=[AudioManager sharedInstance].bgColor;
    self.view.backgroundColor = [AudioManager sharedInstance].bgColor ;
            if(_tableView.editing)
                [_topPlayerView setEditViewForControlHeader];
            else [_topPlayerView setControlForSubHeader];
    
    [self.tableView reloadData];
    
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [[AudioManager sharedInstance] moveTrackFromIndex:sourceIndexPath.row toIndexPath:destinationIndexPath.row]  ;
    [self setTracks];
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - UITableViewDelegate Protocol
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing)
    { if([[self.tableView indexPathsForSelectedRows] count]>0)
        [ _topPlayerView setLeftText:[NSString stringWithFormat:@"%lu %@",(unsigned long)[[self.tableView indexPathsForSelectedRows] count],NSLocalizedString(@"Delete", nil)]];
    else [ _topPlayerView setLeftText:NSLocalizedString(@"Clear", nil) ];
        
    }
    
    return;
    
}
- (void)topPlayer:(TopPlayerView *)topPlayer didSelectIndex:(NSInteger)selectedIndex{
    
    if (_tableView.isEditing)
    {
        if(selectedIndex==0){
            if([[self.tableView indexPathsForSelectedRows] count]>0)
                [self deleteSelection];
            
            else [self triggerClearSelectionAlert];
            
        }
        if(selectedIndex==2)
            [self editAction];
        
    }
    
    else {
        
        
        
        if(selectedIndex==0){
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        if(selectedIndex==2){
            [self editAction];
            
        }
        
        
    }
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.isEditing)
        return NO;
    else return YES;
    
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
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if(_tableView.editing)
        [_topPlayerView setEditViewForControlHeader];
    else [_topPlayerView setControlForSubHeader];
    [self setTracks];
    
}
- (void)deleteSelection
{
    NSArray *indexPaths;
    indexPaths = [self.tableView indexPathsForSelectedRows];
    NSUInteger count = indexPaths.count;
    for (NSUInteger x = 0; x < count; x++){
        [currentPlaylist removeTracksAtIndex:[indexPaths[x] row]-x ];
    }
    
    
    [currentPlaylist save];
    [self editAction];
    
}
-(void)clearSelection{
    
    [currentPlaylist clear];
    [self editAction];
    
    
}

- (void)triggerClearSelectionAlert
{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete All", nil)  message: NSLocalizedString(@"Confirm To Delete All?", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self clearSelection];
    
}
@end
