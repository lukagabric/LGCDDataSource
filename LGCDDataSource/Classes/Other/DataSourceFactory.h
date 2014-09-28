//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataUpdateOperationGroupManager.h"


@interface DataSourceFactory : NSObject


+ (LGDataUpdateOperationGroupManager *)contactsUpdateManagerWithActivityView:(UIView *)activityView;


@end