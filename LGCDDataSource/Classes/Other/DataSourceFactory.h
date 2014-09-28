//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataUpdateOperationManager.h"


@interface DataSourceFactory : NSObject


+ (LGDataUpdateOperationManager *)contactsUpdateManagerWithActivityView:(UIView *)activityView;


@end