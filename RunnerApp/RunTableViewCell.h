//
//  RunTableViewCell.h
//  RunnerApp
//
//  Created by DetroitLabs on 6/17/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RunTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *paceLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;

@end
