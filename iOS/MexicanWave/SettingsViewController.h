//
//  SettingsViewController.h
//  MexicanWave
//
//  Created by Daniel Anderton on 05/04/2012.
//  Copyright (c) 2012 Yell Group Plc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *table;
@property (retain, nonatomic) IBOutlet UIButton *btnYellAppLink;

- (IBAction)didTapYellLink:(id)sender;

@end
