//
//  DownloadViewController_iPad.m
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 7/19/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "DownloadViewController_iPad.h"
#import "Utitlities.h"
#import "DownloadManager.h"
#import "DownloadCell.h"
#import "AudioManager.h"
#import "playrsMemory.h"
#import "playrsTrack.h"

@interface DownloadViewController_iPad (){
    NSArray *toolbarItems;
    UIBarButtonItem *deleteButton;

}
@property (strong, nonatomic) NSArray *completedDownloads;

@property (strong, nonatomic) NSMutableArray *downloads;
@property (strong, nonatomic) NSMutableDictionary *cells;

@end

@implementation DownloadViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidLayoutSubviews{

   

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cells = [NSMutableDictionary dictionary];
    [self setTitle:@"Downloads"];
 [self.view setAutoresizesSubviews:YES];
    
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
    [self.view setAutoresizingMask: UIViewAutoresizingFlexibleWidth|
     
     UIViewAutoresizingFlexibleHeight];
   }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
  
    [self.tableView setFrame:CGRectMake(0, 55.5+48,self.view.frame.size.width, self.view.frame.size.height-(55.5+48))];
    [self.downloadBTN setFrame:CGRectMake(self.view.frame.size.width-55,55.5, 45, 45)];
    [self.urlField setFrame:CGRectMake(0, 55, self.view.frame.size.width-60, 48)];

}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self
     ];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    
    
    
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
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isEditing] == YES) {
            [self updateSelectionCount];
        }
        
        
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
    
    
}
#pragma mark - text view delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.urlField resignFirstResponder];
    return NO;
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isEditing] == YES) {
        [self updateSelectionCount];
    }
    return;
    
}
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
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
    
    [self setEditing:NO animated:NO];
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

@end
