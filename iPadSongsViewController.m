//
//  iPadSongsViewController.m
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 7/18/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "iPadSongsViewController.h"
#import "LibraryViewController.h"
#import  "playrsMemory.h"
#import "playrsTrack.h"
#import "GBFlatSelectableButton.h"
#import "AudioManager.h"
#import "Utitlities.h"
#import "ArtistSectionHeader.h"
@interface SongCell_iPad : UITableViewCell
{
    GBFlatSelectableButton *queueButton;
    GBFlatSelectableButton *playButton;
    GBFlatSelectableButton *playlistButton;
    
    UIView *expandedView;
    UILabel * _trackNumber;
    UILabel * _trackName;
    UILabel * _trackDuration;
    
    
}
@property (weak, nonatomic) playrsTrack * track;

@end
@implementation SongCell_iPad
@synthesize track = _track;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        
        expandedView=[[UIView alloc] initWithFrame:CGRectMake(0 , 55, self.bounds.size.width, 55)];
        
        expandedView.backgroundColor=[UIColor colorWithRed:0.090039 green:0.090039 blue:0.090039 alpha:1.0];
        [self addSubview:expandedView];
        self.contentView.backgroundColor=[UIColor colorWithRed:0.937255 green:0.937255 blue:0.937255 alpha:1.0] ;
        
        
        queueButton = [[GBFlatSelectableButton alloc] initWithFrame:CGRectMake(160, 5, 150, 44)];
        queueButton.buttonColor = [UIColor blackColor];
        [queueButton setTitle:NSLocalizedString(@"Queue", nil)
                     forState:UIControlStateNormal];
        playButton = [[GBFlatSelectableButton alloc] initWithFrame:CGRectMake(5, 5, 150, 44)];
        playButton.buttonColor = [UIColor blackColor];
        [playButton setTitle:NSLocalizedString(@"Play", nil)
                    forState:UIControlStateNormal];
        
        
        _trackNumber = [[UILabel alloc] initWithFrame:CGRectMake(2.5, 12.5, 30, 30)];
        _trackNumber.font = [UIFont fontWithName:@"Bebas" size:15.0];
        _trackNumber.textColor = [[AudioManager sharedInstance] bgColor] ;
        _trackNumber.textAlignment = NSTextAlignmentCenter;
        _trackNumber.lineBreakMode = NSLineBreakByTruncatingTail;
        _trackNumber.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_trackNumber];
        
        
        _trackDuration = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-37.5,12.5, 30, 30)];
        _trackDuration.font = [UIFont fontWithName:@"Bebas" size:12.0];
        _trackDuration.textColor =  [[AudioManager sharedInstance] primaryColor] ;
        _trackDuration.textAlignment = NSTextAlignmentCenter;
        _trackDuration.lineBreakMode = NSLineBreakByTruncatingTail;
        _trackDuration.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_trackDuration];
        
        
        
        _trackName = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.bounds.size.width-80, 55)];
        _trackName.font = [UIFont fontWithName:@"Ubuntu Condensed" size:15.0];
        _trackName.textColor = [UIColor colorWithRed:0.0745098 green:0.0666667 blue:0.0666667 alpha:1.0];
        
        _trackName.textAlignment = NSTextAlignmentCenter;
        _trackName.lineBreakMode = NSLineBreakByTruncatingTail;
        _trackName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_trackName];
        
        
        [expandedView addSubview:queueButton];
        [expandedView addSubview:playButton];
        
        [_trackName setTag:1];
        [_trackNumber setTag:3];
        [queueButton setTag:6];
        [playButton setTag:5];
        
        [expandedView setTag:4];
        self.autoresizesSubviews =YES;
        
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews=YES;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.autoresizesSubviews=YES;
        expandedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        queueButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _trackName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _trackDuration.autoresizingMask =   UIViewAutoresizingFlexibleLeftMargin;
        _trackNumber.autoresizingMask =   UIViewAutoresizingFlexibleRightMargin;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews=YES;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.autoresizesSubviews=YES;
        
    }
    return self;
}

-(void)setSelected:(BOOL)selected{
    
    
    
}

- (void)layoutSubviews {
	[super layoutSubviews];
    _trackDuration.textColor =  [[AudioManager sharedInstance] primaryColor] ;
    _trackNumber.textColor = [[AudioManager sharedInstance] primaryColor] ;
    self.contentView.backgroundColor=[[AudioManager sharedInstance] bgColor]  ;
    _trackName.textColor =[[AudioManager sharedInstance] secondaryColor] ;
    
    
    self.layer.backgroundColor = [[AudioManager sharedInstance] bgColor] .CGColor;
    if(!expandedView.hidden){
        expandedView.backgroundColor= [[AudioManager sharedInstance] bgColorDark]  ;
        
        [playButton setNeedsDisplay];
        [queueButton setNeedsDisplay];
        
    }
}
-(void)setTrackIndex:(NSUInteger)i
{
    
    _trackNumber.text = [NSString stringWithFormat:@"%.2lu",(unsigned long)i];
    [self setNeedsLayout];
    
}
- (void)setTrack:(playrsTrack *)track
{
    _track = track;
    _trackName.text =[track title];
    _trackDuration.text =[Utitlities convertTimeFromSeconds:[[track duration] stringValue]];
    
    [self setNeedsLayout];
}

@end

@interface iPadSongsViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSMutableArray *searchResultArray;
    BOOL isSearch;
    
    
}

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, copy) NSArray *tracks;
@property(nonatomic,retain)NSIndexPath *selectedIndex;
@end

@implementation iPadSongsViewController
bool isCellSame=false;

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
    _selectedIndex=[[NSIndexPath alloc]init];
    [self setTitle:@"Songs"];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth ;
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.tableView registerClass:[SongCell_iPad class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[ArtistSectionHeader class] forHeaderFooterViewReuseIdentifier:@"Header"];
    
	self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask: UIViewAutoresizingFlexibleWidth|
     
     UIViewAutoresizingFlexibleHeight];
    [self.tableView setAutoresizesSubviews:YES];
    [self.tableView setAutoresizingMask:
     
     UIViewAutoresizingFlexibleHeight];
    CGSize bsize = self.tableView.frame.size;
    
    _searchBar = [[UISearchBar alloc] init];
    
    
    _searchBar.frame = CGRectMake(0, 0, bsize.width, 46);
    [self.tableView setTableHeaderView:_searchBar];
    
    
    _searchBar.barStyle = UIBarStyleDefault;
    _searchBar.barTintColor=[UIColor clearColor];
    
    _searchBar.backgroundColor=[UIColor clearColor];
    [_searchBar setSearchBarStyle:UISearchBarStyleProminent];
    
    _searchBar.placeholder = @"imPlayr";
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    _searchBar.delegate = self;
}
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
     
    [[NSNotificationCenter defaultCenter] removeObserver:self
     ];
	//[self showNavBarAnimated:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setColorScheme) name:NOTIFICATION_COLORS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTrackList ) name:NOTIFICATION_DB_FILE_LIST_UPDATED object:nil];
    [self setTracks:[[playrsMemory sharedInstance] songsGroupedByArtist]];
    [self setColorScheme];
    [self.tableView setFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setColorScheme{
    
    self.tableView.backgroundColor=[AudioManager sharedInstance].bgColor;
    self.view.backgroundColor = [AudioManager sharedInstance].bgColor ;
     [self.tableView reloadData];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ArtistSectionHeader* sct = [tableView dequeueReusableCellWithIdentifier:@"Header"];
	if (!sct) {
		sct =[[ArtistSectionHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];	}
    
    playrsTrack *t;
    NSString *title=NSLocalizedString(@"Unknown", nil);
    NSArray *a;
    
    if(!isSearch){
        a=[_tracks objectAtIndex:section];
        if([a count]!=0){
            t=[a objectAtIndex:0];
            title=[t artist];
        }
    }
    else {
        title=NSLocalizedString(@"No Search Found", nil);
        
        a=[searchResultArray objectAtIndex:section];
        if([a count]!=0){
            t=[a objectAtIndex:0];
            title=[t artist];
        }
    }
    
    
    [sct setTitleArtist:title];
    [sct setTotalSongs:[NSString stringWithFormat:@"%lu Songs",(unsigned long)[a count]]];
    [Utitlities attachArtwork:t toImageView:[sct artistImageView] thumbnail:YES];
    
    
    
    return sct;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath isEqual:tableView.indexPathForSelectedRow]) {
        
        if (isCellSame) {
            return 55;
        }
        else
            return 55+55;
    }
    else
        
        return 55;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearch){
		return [[searchResultArray objectAtIndex:section] count];
	}
    return [[self.tracks objectAtIndex:section] count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(isSearch){
		return [searchResultArray count] ;
	}
    return [ _tracks count] ;
    
    
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SongCell_iPad* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if (!cell) {
		cell = [[SongCell_iPad alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	}
    playrsTrack *track;
    if(!isSearch)
        track= [[self.tracks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	else  track= [[searchResultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell setTrack:track];
    [cell setTrackIndex:[indexPath row]+1];
    
    if([indexPath isEqual:_selectedIndex] && !isCellSame) {
        
        UIView *expandedView=(UIView *) [cell viewWithTag:4]  ;
        GBFlatSelectableButton *playButton=(GBFlatSelectableButton *)[cell viewWithTag:5];
        GBFlatSelectableButton *queueButton=(GBFlatSelectableButton *)[cell viewWithTag:6];
        
        
        [expandedView setHidden:NO];
        [[cell viewWithTag:6] setHidden:NO];
        
        [[cell viewWithTag:5] setHidden:NO];
        [playButton layoutSubviews];
        [queueButton layoutSubviews];
        
        [playButton addTarget:self action:@selector(playPressed:) forControlEvents:UIControlEventTouchDown];
        [queueButton addTarget:self action:@selector(queuePressed:) forControlEvents:UIControlEventTouchDown];
        
    }
    else
    {
        [[cell viewWithTag:5] setHidden:YES];
        [[cell viewWithTag:6] setHidden:YES];
        
        [[cell viewWithTag:4] setHidden:YES];
    }
    
	return cell;
}




-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 80;
}

-(void)setTracks:(NSArray *)tracks{
    isSearch = NO;
    if(searchResultArray)
        [searchResultArray removeAllObjects];
    _searchBar.text=@"";
    _tracks=tracks;
    
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([_selectedIndex isEqual:indexPath]) {
        if (!isCellSame) {
            isCellSame=true;
            
        }
        else
            isCellSame=false;
    }
    else{
        _selectedIndex=indexPath;
        
        isCellSame=false;
    }
    
    [tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


-(void)playPressed:(id)sender
{
    NSIndexPath *indexPath = _selectedIndex;
    
    playrsTrack *track;
    if(!isSearch)
        track= [[self.tracks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	else  track= [[searchResultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    _selectedIndex=nil;
    [_tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [[AudioManager sharedInstance] addTrackToQueue:track toBeginning:YES];
    
    
    
}
- (void) searchTableView{
 	NSString *searchText = _searchBar.text;
    if(searchResultArray == nil){
        searchResultArray = [[NSMutableArray alloc] init];
    }
    for (NSArray *tempArray in _tracks)
	{
        NSMutableArray *sectionArray=[[NSMutableArray alloc] init];
        for (playrsTrack *track in tempArray)
        {
            NSString *busNum = [track title];
            NSRange titleResultsRange = [busNum rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (titleResultsRange.location != NSNotFound){
                [sectionArray addObject:track];
                
			}
            
        }
        
        if([sectionArray count]!=0)
            [searchResultArray addObject:sectionArray];
        
        
    }
	[self.tableView reloadData];
}


- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    if(searchResultArray)
        [searchResultArray removeAllObjects];
	if([searchText length] > 0) {
        isSearch = YES;
        
		[self searchTableView];
	}
    else{
    	isSearch = NO;
        
    	[self.tableView reloadData];
        
        
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    
	if([theSearchBar.text length] > 0){
		isSearch = YES;
	}else{
		isSearch = NO;
	}
	[self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    
	//Add the done button.
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(void)queuePressed:(id)sender
{
    
    NSIndexPath *indexPath = _selectedIndex;
    
    playrsTrack *track;
    if(!isSearch)
        track= [[self.tracks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	else  track= [[searchResultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [[AudioManager sharedInstance] addTrackToQueue:track toBeginning:NO];
    
    _selectedIndex=nil;
    
    [_tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}

-(void)updateTrackList{
    
    [self setTracks:[[playrsMemory sharedInstance] songsGroupedByArtist]];
    
    
}

@end
