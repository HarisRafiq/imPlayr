//
//  imNowPlayingViewController.m
//  imPlayr2
//
//  Created by YAZ on 5/27/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "imNowPlayingViewController.h"
#import   "QueueTableCell.h"
#import "AppDelegate.h"
#import "PlaylistManager.h"
#import "imConstants.h"
#import "imStreamer.h"
@interface imNowPlayingViewController ()
@property (nonatomic) TopPlayerView *topPlayerView;

@end

@implementation imNowPlayingViewController
-(id)initWithFrame:(CGRect)frame{
if(self=[super initWithFrame:frame])
{
    
     self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,75,self.bounds.size.width, self.bounds.size.height-125) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
     [self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentMode=UIViewContentModeScaleAspectFit;
     
 
    
     
     self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.clipsToBounds=YES;
    self.layer.borderWidth=1;
    _tableView.backgroundColor=[UIColor clearColor];

    _topPlayerView=[[TopPlayerView alloc] initWithFrame:CGRectMake(0,0, self.bounds.size.width, 75)];
    _topPlayerView.delegate = self;
    _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0,self.bounds.size.height-50, self.bounds.size.width, 50)];
    _closeLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, _bottomView.frame.size.width, 50)];
    
    _closeLabel.textColor=[UIColor whiteColor] ;
    
    _closeLabel.textAlignment=NSTextAlignmentCenter;
    
    _closeLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:20];
    _closeLabel.text=@"Close";
    
    _closeLabel.numberOfLines=1;
    _closeLabel.clipsToBounds=YES;
        [_bottomView addSubview:_closeLabel];
    [self addSubview:_bottomView];
    _topPlayerView.delegate = self;
    [self addSubview:_topPlayerView];
    [_topPlayerView setShuffleView];
    [self setTracks];
    [self addNotfification];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleQueue)];
    [_bottomView addGestureRecognizer:tap];
    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:
     UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    [self.tableView setAutoresizesSubviews:YES];
    [self.tableView setAutoresizingMask:
     UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    [_bottomView setAutoresizingMask:
     UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleTopMargin];
}


    return self;
}
-(void)switchToiPad{

    [_bottomView removeFromSuperview];
    
    [self.tableView setFrame:CGRectMake(0,75,self.bounds.size.width, self.bounds.size.height-75)];

}
-(void)toggleQueue{

    [_delegate dismissNowPlaying];

}
-(void)shuffleToggle{
 [_topPlayerView setShuffleView];


}
-(void)repeatToggle{
    [_topPlayerView setShuffleView];
}
-(void)cleanUp{
     [[NSNotificationCenter defaultCenter ] removeObserver:self];
    [_topPlayerView removeNotification];
    

}
-(void)addNotfification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setColorScheme) name:NOTIFICATION_COLORS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repeatToggle) name:NOTIFICATION_REPEAT_TOGGLED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shuffleToggle) name:NOTIFICATION_SHUFFLE_TOGGLED object:nil];
    [_topPlayerView addNotification];


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
    
    QueueTableCell * cell = (QueueTableCell *) [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil)
        cell = [[QueueTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    
    
    
    playrsTrack *t=[_tracks objectAtIndex:[indexPath row]];
    
    cell.track = t;
    [cell setTrackIndex:[indexPath row]+1];
    
    if(([[AudioManager sharedInstance] currentStreamer]!=nil&&[[[AudioManager sharedInstance] currentStreamer] status]==AudioStreamerPlaying) ||[[imStreamer sharedInstance] isHTTPRunning]){
    if([[AudioManager sharedInstance] currentTrackIndex]==[indexPath row])
    {
        [cell setIsPlaying];
    
    }
    
    else
        [cell setNotPlaying];
    
    }
    else
        [cell setNotPlaying];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - UITableViewDelegate Protocol
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing)
    { if([[self.tableView indexPathsForSelectedRows] count]>0)
        [ _topPlayerView setMiddleText:[NSString stringWithFormat:@"%lu %@",(unsigned long)[[self.tableView indexPathsForSelectedRows] count],NSLocalizedString(@"Delete", nil)]];
    else [ _topPlayerView setMiddleText:NSLocalizedString(@"Delete All", nil)];
        
    }
    
    return;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // If the controls are visible don't allow cell interaction
    if (tableView.isEditing)
    {
        [ _topPlayerView setMiddleText:[NSString stringWithFormat:@"%lu %@",(unsigned long)[[self.tableView indexPathsForSelectedRows] count],NSLocalizedString(@"Delete", nil)]];
        
        
        return;
    }
    [[AudioManager sharedInstance] setCurrentTrackIndex:[indexPath row]];
    
    [[AudioManager sharedInstance] _resetStreamer];
    
}
-(void)setTracks{
    _tracks=[[AudioManager sharedInstance] playerQueue];
    [self setColorScheme];
    
}
-(void)setColorScheme{
 
            
            
    _closeLabel.textColor=  [[AudioManager sharedInstance] secondaryColor]  ;

    _bottomView.backgroundColor=  [[AudioManager sharedInstance] bgColorDark]  ;

             self.backgroundColor = [AudioManager sharedInstance].bgColor ;
            self.layer.borderColor= [AudioManager sharedInstance].bgColorDark.CGColor;
            
            if(_tableView.editing)
                [_topPlayerView setEditView];
            else [_topPlayerView setShuffleView];
           [self.tableView reloadData];

}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [[AudioManager sharedInstance] moveTrackFromIndex:sourceIndexPath.row toIndexPath:destinationIndexPath.row]  ;
    [self setTracks];
    
    
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

- (void)deleteSelection
{

    NSArray *indexPaths;
    indexPaths = [self.tableView indexPathsForSelectedRows];
    NSUInteger count = indexPaths.count;
    
    for (NSUInteger x = 0; x < count; x++){
        [ [AudioManager sharedInstance] removeSongFromQueue:[indexPaths[x] row]-x];
    }
    
    if([[AudioManager sharedInstance] currentStreamer]!=nil&&[[[AudioManager sharedInstance] currentStreamer] status]==AudioStreamerPlaying){
        for (NSUInteger x = 0; x < count; x++){
            if([[AudioManager sharedInstance] currentTrackIndex]==(int)[indexPaths[x] row])
                
                [[AudioManager sharedInstance] changeTrackDueToDeletion];
            
        }
    }
    
    
    [[AudioManager sharedInstance] save];
    [self editAction];
}
-(void)clearSelection{
    
    [[AudioManager sharedInstance] clearQueue];
     [ self editAction];
    
}
-(void)saveSelection{

    [self didPressAddPlaylist];
    [ self editAction];

    
}
- (void)editAction
{
    [self.tableView setEditing:!self.tableView.editing animated:NO];
    if(_tableView.editing)
        [_topPlayerView setEditView];
    else [_topPlayerView setShuffleView];
    [self setTracks];

}
- (void)didPressAddPlaylist
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Create New Playlist", nil)
                                                         message:NSLocalizedString(@"Type the name of your new Playlist", nil)
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               otherButtonTitles:NSLocalizedString(@"Add", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField * textField = [alertView textFieldAtIndex:0];
    textField.placeholder = NSLocalizedString(@"Name goes here", nil);
    alertView.delegate = self;
    alertView.tag=1;
    
    [alertView show];
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 0)
    {
        if(alertView.tag==1){
            UITextField * textField = [alertView textFieldAtIndex:0];
            
            Playlist *p=[[PlaylistManager getInstance] addPlaylistWithName: textField.text ];
            [p addTracksFromArray:_tracks];
            
            
            
        }
    }
}
- (void)topPlayer:(TopPlayerView *)topPlayer didSelectIndex:(NSInteger)selectedIndex{
    
    if (_tableView.isEditing)
    {
        if(selectedIndex==1){
            if([[self.tableView indexPathsForSelectedRows] count]>0)
                [self deleteSelection];
            
            else [self clearSelection];
            
        }
        if(selectedIndex==0)
            [self editAction];
        if(selectedIndex==2)
            [self saveSelection];
    }
    
    else {
        
        if(selectedIndex==1){
            [[AudioManager sharedInstance] toggleShuffle];
            
        }
        
        if(selectedIndex==0){
         [[AudioManager sharedInstance] toggleRepeat];
            
        }
        if(selectedIndex==2){
            [self editAction];
            
        }
        
        
    }
    
}

 @end
