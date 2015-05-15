//
//  PlaylistViewController_iPad.m
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 7/20/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "PlaylistViewController_iPad.h"
#import "MiddleViewCell.h"
#import "PlaylistViewController_iPad.h"
#import   "AudioManager.h"
#import  "PlaylistManager.h"
#import "Utitlities.h"
@interface PlaylistViewController_iPad ()<UITableViewDataSource, UITableViewDelegate>{
    
    NSArray *toolbarItems;
    UIBarButtonItem *deleteButton;
    UIBarButtonItem *backButton;

    Playlist *currentPlaylist;
}
@property (nonatomic, copy) NSArray *tracks;
@property (nonatomic,strong) UITableView *tableView;
 

@end
 @implementation PlaylistViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [[AudioManager sharedInstance] setPlaylist:currentPlaylist];
    
    [[AudioManager sharedInstance] setCurrentTrackIndex:[indexPath row]];
    
    [[AudioManager sharedInstance] _resetStreamer];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




-(void)setCurrentPlaylist:(Playlist *)p{
    currentPlaylist=p;
    [self setTitle:[p title]];

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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
     deleteButton = [[UIBarButtonItem alloc]
                    initWithTitle:@"Delete"
                    style:UIBarButtonItemStyleBordered
                    target:self
                    action:@selector(deleteSelection)];
    [deleteButton setTintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [deleteButton setEnabled:NO];
    backButton = [[UIBarButtonItem alloc]
                    initWithTitle:@"Back"
                    style:UIBarButtonItemStyleBordered
                    target:self
                    action:@selector(goBack)];
    [backButton setTintColor:[UIColor colorWithRed:1.0 green:1 blue:1 alpha:1]];
    self.navigationItem.leftBarButtonItem =backButton;

    toolbarItems = [[NSArray alloc] initWithObjects:deleteButton, nil];
    [self setToolbarItems:toolbarItems animated:YES];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    
}
-(void)goBack{

            [self.navigationController popViewControllerAnimated:YES];
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
            
        
    [self.tableView reloadData];
    
}
 
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - UITableViewDelegate Protocol
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isEditing] == YES) {
            [self updateSelectionCount];
        }
        
        
        return;
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
    [self setEditing:NO animated:NO];
}
 

@end
