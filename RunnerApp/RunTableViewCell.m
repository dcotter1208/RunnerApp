//
//  RunTableViewCell.m
//  RunnerApp
//
//  Created by DetroitLabs on 6/17/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "RunTableViewCell.h"

@implementation RunTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [[UIColor whiteColor]CGColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
