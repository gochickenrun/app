//
//  OPFModel.h
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-04-18.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "Mantle.h"  
#import "OPFDatabaseAccess.h"

@interface OPFModel : MTLModel <MTLJSONSerializing>

@property (copy, readonly) NSString* modelName;

+(OPFDatabaseAccess *) getDBAccess;
+(FMResultSet *) findModel: (NSString*) modelName withIdentifier: (NSInteger) identifier;
+(NSDateFormatter*) dateFormatter;
@end