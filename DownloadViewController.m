//
//  DownloadViewController.m
//  FileSafe
//
//  Created by Lombardo on 14/04/13.
//
//

#import "DownloadViewController.h"
#import "DownloadCell.h"
#import "DownloadManager.h"
#import  "AudioManager.h"
#import "imConstants.h"
#import "playrsMemory.h"
#import "Utitlities.h"
#import "playrsTrack.h"
#import "imConstants.h"
@interface DownloadViewController ()
@property (strong, nonatomic) NSArray *completedDownloads;

@property (strong, nonatomic) NSMutableArray *downloads;
@property (strong, nonatomic) NSMutableDictionary *cells;

@end

@implementation DownloadViewController

- (id)init
{
    self = [super init];
    if (self) {

         self.cells = [NSMutableDictionary dictionary];
             }
    return self;
}
- (void)loadView
{
    UIView *newView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = newView;
    [self.view setFrame:CGRectMake(newView.frame.origin.x, newView.frame.origin.y,320, newView.frame.size.height)];
  
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 125,self.view.frame.size.width, self.view.frame.size.height-125) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    self.urlField = [[UITextField alloc] initWithFrame:CGRectMake(0, 77, self.view.frame.size.width-60, 48)];
    self.urlField.placeholder=NSLocalizedString(@"Enter URL to download", nil) ;
	self.urlField.adjustsFontSizeToFitWidth = YES;
 		self.urlField.font = [UIFont systemFontOfSize:14];
	self.urlField.borderStyle = UITextBorderStyleRoundedRect;
	self.urlField.keyboardType = UIKeyboardTypeURL;
	self.urlField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.urlField.delegate=self;
    
    [self.view addSubview:self.urlField];
 
    self.downloadBTN=[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-55, 77.5, 45, 45)];
    
    [self.downloadBTN addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.downloadBTN setImage:[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"download_file" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ] forState:UIControlStateNormal];
 
 
    

    
    [self.view addSubview:self.downloadBTN];
    

    _topPlayerView=[[TopPlayerView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,75)];
    [self.view addSubview:_topPlayerView];
    [_topPlayerView setupForControlHeader];
    _topPlayerView.delegate=self;
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;

   }
-(void)fileListUpdated{
    self.completedDownloads=  [[playrsMemory sharedInstance] songsGroupedByTypeDownloads] ;
    [self setColorScheme];

}
- (void) viewWillAppear:(BOOL)animated
{
    self.downloads = [[[[DownloadManager sharedInstance] tasks] allValues] mutableCopy];

    self.completedDownloads=  [[playrsMemory sharedInstance] songsGroupedByTypeDownloads] ;
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileListUpdated ) name:NOTIFICATION_DB_FILE_LIST_UPDATED object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setColorScheme) name:NOTIFICATION_COLORS_CHANGED object:nil];

         [self setColorScheme];
    [_topPlayerView addNotification];

    
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self
     ];
    [_topPlayerView removeNotification];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        
        // Return the number of rows in the section.
        return [self.downloads count];
    }
    
    else return [self.completedDownloads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ if([indexPath section]==0){
    static NSString *CellIdentifier = @"Cell";
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell ==nil)
        cell=[[DownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    // Configure the cell...
   
    [self configureCell:cell forIndexPath:indexPath];
    return cell;

}
    else {
    
        static NSString *CellIdentifier2 = @"Cell2";
        DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if(cell ==nil)
            cell=[[DownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        playrsTrack *_track =  (playrsTrack *)[self.completedDownloads objectAtIndex:indexPath.row];
        cell.fileName.text = [_track title];
        cell.percentageLabel.text = [NSString stringWithFormat:@"%li",(unsigned long)indexPath.row+1];
        cell.progressLabel.text =  [Utitlities convertTimeFromSeconds: [_track.duration stringValue]];
     
        return cell;

    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing)
    {
        [ _topPlayerView setLeftText:[NSString stringWithFormat:@"%lu %@",(unsigned long)[[self.tableView indexPathsForSelectedRows] count],NSLocalizedString(@"Delete", nil)]];
        
        
        return;
    }
    
    if([indexPath section]==1){
   
        playrsTrack *_track =  (playrsTrack *)[self.completedDownloads objectAtIndex:indexPath.row];

        [[AudioManager sharedInstance] addTrackToQueue:_track toBeginning:YES];

            [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setColorScheme];

   

    }
    else {
    
        Download *download =  [self.downloads objectAtIndex:indexPath.row];
        
        [download resumeOrPause];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    }
    }


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void)configureCell:(DownloadCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    
    Download *download =  [self.downloads objectAtIndex:indexPath.row];
    cell.fileName.text = [download fileName];
    cell.percentageLabel.text = @"0 %";
    cell.progressLabel.text = @"";
    
    [self.cells setObject:cell forKey:[download url]];
    
    [download setProgressBlock:^(NSURL *url, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
             float downloadedkb = totalBytesWritten / 1024;
            float totalkb = totalBytesExpectedToWrite / 1024;
            cell.progressLabel.text = [NSString stringWithFormat:@"%.0f KB/ %.0f KB", downloadedkb,totalkb];
            
            cell.percentageLabel.text = [NSString stringWithFormat:@"%.1f %%", progress*100];

        });
        
    }];
    
    
    
    [download setCompletionBlock:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.downloads = [[[[DownloadManager sharedInstance] tasks] allValues] mutableCopy];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        });
    }];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
- (void)start  {
    NSURL *url = [NSURL URLWithString:self.urlField.text];
    if(url!=nil)
    {
    Download *download = [[DownloadManager sharedInstance] downloadForURL:url];
    
    [download start];
    self.downloads=[[[[DownloadManager sharedInstance] tasks] allValues] mutableCopy];
    if([self.urlField isFirstResponder])
        [self.urlField resignFirstResponder];

    
        [_tableView reloadData];

    }
    }



-(void)setColorScheme{
 
             
            
    self.tableView.backgroundColor=[AudioManager sharedInstance].bgColor;
    self.view.backgroundColor = [AudioManager sharedInstance].bgColor ;
    
    [self.downloadBTN setImage:[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"download_file" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]  ] forState:UIControlStateNormal];
    
    
    
            [self.tableView reloadData];
    if(_tableView.editing)
        [_topPlayerView setEditViewForControlHeader];
    else [_topPlayerView setControlForSubHeader];
    
    
}
#pragma mark - text view delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.urlField resignFirstResponder];
    return NO;
}
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
         return NO;
    
    
}
- (void)editAction
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if(_tableView.editing)
        [_topPlayerView setEditViewForControlHeader];
    else [_topPlayerView setControlForSubHeader];
    [self fileListUpdated];
    
}
- (void)deleteSelection
{
    NSArray *indexPaths;
    indexPaths = [self.tableView indexPathsForSelectedRows];
    NSUInteger count = indexPaths.count;
    
    for (NSUInteger x = 0; x < count; x++){
        if([indexPaths[x] section]==1){
        playrsTrack *_track =  (playrsTrack *)[self.completedDownloads objectAtIndex:[indexPaths[x] row] ];

        [[playrsMemory sharedInstance ] deleteTrack:_track ];
        }
        else  if([indexPaths[x] section]==0){
            Download *download =  [self.downloads objectAtIndex:[indexPaths[x] row]-x ];
            [download cancel];
            
            [self.downloads removeObjectAtIndex:[indexPaths[x] row]-x ];
        
        
        }
           
        }
    
    
     [self editAction];
    
}
- (void)triggerClearSelectionAlert
{
    
    /* selected item is a proper file, ask the user if s/he wants to download it */
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete All", nil) message: @"Confirm To Delete All?"  delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)  otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self clearSelection];
    
 }

-(void)clearSelection{
    for (NSUInteger x = 0; x < [_completedDownloads count]; x++){
        playrsTrack *_track =  (playrsTrack *)[self.completedDownloads objectAtIndex:x];
        
        [[playrsMemory sharedInstance ] deleteTrack:_track ];
    }
     [self editAction];
    
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([self.urlField isFirstResponder])
        [self.urlField resignFirstResponder];
}
@end
