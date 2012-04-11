//
//  SettingsViewController.m
//  MexicanWave
//
//  Created by Daniel Anderton on 05/04/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import "SettingsViewController.h"
#import "MEXWavingViewController.h"
#define kNumberOfSettings 2
#define kSettingsKeyVibration NSLocalizedString(@"Vibration", @"Settings Table row title vibration")
#define kSettingsKeySounds NSLocalizedString(@"Sounds", @"Settings Table row title sounds")
#define kUserDefaultKeySound @"sound_preference"
#define kUserDefaultKeyVibration @"vibration_preference"
#define kSettingsVibrationTag 0
#define kSettingsSoundsTag 1
#define kNSLocaleKeyUK @"GB"
#define kNSLocaleKeyES @"ES"
#define kNSLocaleKeyUS @"US"
#define kSwitchWidthOffset 20.0f

@interface SettingsViewController ()
-(NSString*)appstoreURLForCurrentLocale;
@end

@implementation SettingsViewController
@synthesize btnYellAppLink;
@synthesize table;
- (void)dealloc {
    [table release];
    [btnYellAppLink release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
        
    //tap gesture to make it eaiser to go back to home screen
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapCancel)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    [tap release];
    
    //if we are in a geography we have an app present it
    if([[self appstoreURLForCurrentLocale] length]){
        btnYellAppLink.hidden = NO;
        [btnYellAppLink setTitle:NSLocalizedString(@"Yell and Find",@"Yell tag line button Link to appstore") forState:UIControlStateNormal];
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)didTapCancel{
    MEXWavingViewController* waveController = (MEXWavingViewController*)self.parentViewController;
    [waveController resume];
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    [self setTable:nil];
    [self setBtnYellAppLink:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark TableView Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return kNumberOfSettings;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return NSLocalizedString(@"Wave Effects", @"Settings table header title");
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //add a switch that enables the user to change the settings
        UISwitch* switchControl = [[[UISwitch alloc]init]autorelease];
        switchControl.tag = 99;
        switchControl.center = CGPointMake(320 - switchControl.frame.size.width*0.5 -kSwitchWidthOffset , cell.frame.size.height*0.5f);
        [switchControl addTarget:self action:@selector(didChangeTableSwitch:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:switchControl];
    }

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //get the switch for row and update the  labels and switch from userdefaults
    UISwitch* currentSwitch = (UISwitch*)[cell viewWithTag:99];
    currentSwitch.tag = indexPath.row;
    currentSwitch.on = (indexPath.row == kSettingsVibrationTag) ? [defaults boolForKey:kUserDefaultKeyVibration] : [defaults boolForKey:kUserDefaultKeySound];
    cell.textLabel.text = (indexPath.row == kSettingsVibrationTag) ? kSettingsKeyVibration : kSettingsKeySounds;
    return cell;
}

-(void)didChangeTableSwitch:(UISwitch*)currentSwitch{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //update the correct nsuserdefault
    if(currentSwitch.tag == kSettingsSoundsTag){
        [defaults setBool:currentSwitch.isOn forKey:kUserDefaultKeySound];
    }
    //if its not sound lets double check its vibration
    else if(currentSwitch.tag == kSettingsVibrationTag){
        [defaults setBool:currentSwitch.isOn forKey:kUserDefaultKeyVibration];
    }
    
    [defaults synchronize];
}
#pragma mark gestureRecognizer 
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Disallow recognition of tap gestures in the yell button.
    if (touch.view == btnYellAppLink) {
        return NO;
    }
    return YES;
}
- (IBAction)didTapYellLink:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self appstoreURLForCurrentLocale]]];
}
-(NSString*)appstoreURLForCurrentLocale{
    NSLocale* currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString* countryCode = [currentLocale objectForKey:NSLocaleCountryCode]; //get current locale as code.

    //compare codes to get correct url for app store.
    if([countryCode isEqualToString:kNSLocaleKeyUK]){
       return @"http://itunes.apple.com/gb/app/yell-search-find-local-uk/id329334877?mt=8";
    }
    else if([countryCode isEqualToString:kNSLocaleKeyUS]){
        return @"http://itunes.apple.com/us/app/us-yellow-pages/id306599340?mt=8";
    }
    else if([countryCode isEqualToString:kNSLocaleKeyES]){
        return @"http://itunes.apple.com/es/app/paginas-amarillas-de-peru/id341220443?mt=8";
    }
    
    return nil;
}

@end
