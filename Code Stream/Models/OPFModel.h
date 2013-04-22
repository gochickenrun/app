//
//  OPFModel.h
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-04-18.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "Mantle.h"  
#import "OPFDatabaseAccess.h"
#import "OPFRecordProtocol.h"
#import "OPFQuery.h"
#import "OPFQueryable.h"

@interface OPFModel : MTLModel <MTLJSONSerializing, OPFRecordProtocol, OPFQueryable>

@property (copy, readonly) NSString* modelName;

+(OPFDatabaseAccess *) getDBAccess;
+(FMResultSet *) findModel: (NSString*) modelName withIdentifier: (NSInteger) identifier;
+(FMResultSet *) allForModel: (NSString*) modelName;
+(FMResultSet *) allForModel:(NSString *)modelName page: (NSInteger) page;
+(FMResultSet *) allForModel:(NSString *)modelName page: (NSInteger) page per: (NSInteger) per;
+(NSDateFormatter*) dateFormatter;
+(NSInteger) defaultPageSize;
+(OPFRootQuery*) query;
@end