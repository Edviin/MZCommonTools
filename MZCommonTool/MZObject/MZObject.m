//
//  MZObject.m
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//

#import "MZObject.h"
#import "MZObjectPropertyAttribute.h"

static NSDictionary<NSString *, MZObjectPropertyAttribute *> * scanPropertyAttributeOfClass(Class cls) {
    
    NSMutableDictionary * propertyDic = [NSMutableDictionary dictionary];
    NSScanner* scanner = nil;
    NSString* propertyType = nil;
    
    // inspect inherited properties up to the JSONModel class
    while (cls != [MZObject class]) {
        
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
        
        //loop over the class properties
        for (unsigned int i = 0; i < propertyCount; i++) {
            
            MZObjectPropertyAttribute* p = [[MZObjectPropertyAttribute alloc] init];
            
            //get property name
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            p.name = @(propertyName);
            
            //get property attributes
            const char *attrs = property_getAttributes(property);
            NSString* propertyAttributes = @(attrs);
            NSArray* attributeItems = [propertyAttributes componentsSeparatedByString:@","];
            
            //ignore read-only properties
            if ([attributeItems containsObject:@"R"]) {
                continue; //to next property
            }
            
            //check for 64b BOOLs
            if ([propertyAttributes hasPrefix:@"Tc,"]) {
                //mask BOOLs as structs so they can have custom converters
                p.structName = @"BOOL";
            }
            
            scanner = [NSScanner scannerWithString: propertyAttributes];
            
            //JMLog(@"attr: %@", [NSString stringWithCString:attrs encoding:NSUTF8StringEncoding]);
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            
            //check if the property is an instance of a class
            if ([scanner scanString:@"@\"" intoString: &propertyType]) {
                
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
                
                //JMLog(@"type: %@", propertyClassName);
                p.type = NSClassFromString(propertyType);
                p.isMutable = ([propertyType rangeOfString:@"Mutable"].location != NSNotFound);
                
                //read through the property protocols
                while ([scanner scanString:@"<" intoString:NULL]) {
                    
                    NSString* protocolName = nil;
                    
                    [scanner scanUpToString:@">" intoString: &protocolName];
                    
                    if ([protocolName isEqualToString:@"Optional"]) {
                        p.isOptional = YES;
                    }
                    else if([protocolName isEqualToString:@"ConvertOnDemand"]) {
                        p.convertsOnDemand = YES;
                    }
                    else if([protocolName isEqualToString:@"Ignore"]) {
                        p = nil;
                    }
                    else {
                        p.protocol = protocolName;
                    }
                    
                    [scanner scanString:@">" intoString:NULL];
                }
                
            }
            
            if (p && ![propertyDic objectForKey:p.name]) {
                [propertyDic setValue:p forKey:p.name];
            }
        }
        
        free(properties);
        cls = [cls superclass];
    }
    
    return propertyDic;
}

@implementation MZObject

+ (instancetype)serializeWithJsonObject:(NSDictionary *)jsonObject {
    
    return [[self.class alloc] initWithJsonObject:jsonObject];
}

+ (NSMutableArray *)serializeWithJsonObjects:(NSArray *)jsonObjects {
    
    return [self.class importObjectsWithJsonObjects:jsonObjects ObjectType:self.class];
}

- (instancetype)init {
    
    self = [super init];
    return self;
}

- (instancetype)initWithJsonObject:(NSDictionary *)jsonObj {
    
    if(!jsonObj || 0 == jsonObj.count)
        return nil;
    
    self = [super init];
    if(nil == self)
        return nil;
    
    BOOL isOk = [self importObjectWithJsonObject:jsonObj];
    
    if(!isOk)
        return nil;
    
    return self;
}

- (NSDictionary *)toJsonObject {
    
    return [self exportToJsonObject];
}

#pragma mark - NSCopying, NSCoding
-(instancetype)copyWithZone:(NSZone *)zone {
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

-(instancetype)initWithCoder:(NSCoder *)decoder {
    NSDictionary * jsonObject = [decoder decodeObjectForKey:@"JSON"];
    
    self = [self.class serializeWithJsonObject:jsonObject];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.toJsonObject forKey:@"JSON"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Private method
- (BOOL)importObjectWithJsonObject:(NSDictionary *)jsonDic {
    
    NSDictionary<NSString *, MZObjectPropertyAttribute *> * classProperties = scanPropertyAttributeOfClass(self.class);
    
    if(!classProperties || 0 == classProperties.count)
        return NO;
    
    //loop over the incoming keys and set self's properties
    for (MZObjectPropertyAttribute * property in [classProperties allValues]) {
        
        //convert key name to model keys, if a mapper is provided
        NSString* jsonKeyPath = property.name;
        
        //general check for data type compliance
        id jsonValue;
        @try {
            
            jsonValue = [jsonDic valueForKeyPath:jsonKeyPath];
        }
        @catch (NSException *exception) {
            
            jsonValue = jsonDic[jsonKeyPath];
        }
        
        if(property && nil != property.type) {
            // handle nils
            if (!jsonValue || [jsonValue isKindOfClass:[NSNull class]]) {
                
                [self setValue:nil forKey: property.name];
                continue;
            }
            
            // handle array type
            if(property.type == [NSArray class] ||
               property.type == [NSMutableArray class]) {
                
                id value = nil;
                Class protocolClass = NSClassFromString(property.protocol);
                if(protocolClass && [protocolClass isSubclassOfClass:[MZObject class]]) {
                    
                    value = [[protocolClass class] importObjectsWithJsonObjects:jsonValue ObjectType:protocolClass];
                }
                else {
                    
                    value = jsonValue;
                }
                
                [self setValue:value forKey: property.name];
                continue;
            }
            
            if([jsonValue isKindOfClass:NSDictionary.class] ||
               [jsonValue isKindOfClass:NSMutableDictionary.class]) {
                
                id value = nil;
                if ([property.type isSubclassOfClass:[MZObject class]]) {
                    
                    value = [[property.type alloc] initWithJsonObject:jsonValue];
                }
                else {
                    
                    value = jsonValue;
                }
                
                [self setValue:value forKey:property.name];
                continue;
            }
            
            // handle "all other" cases (if any)
            [self setValue:jsonValue forKey: property.name];
            
        }
    }
    
    return YES;
}

+ (NSMutableArray *)importObjectsWithJsonObjects:(NSArray *)jsonObjects ObjectType:(Class)objectType {
    
    if(!jsonObjects ||
       (![jsonObjects isKindOfClass:NSArray.class] &&
        ![jsonObjects isKindOfClass:NSMutableArray.class])) {
           
           return [NSMutableArray array];
       }
    
    //parse dictionaries to objects
    NSMutableArray* list = [NSMutableArray arrayWithCapacity:[jsonObjects count]];
    
    for (id jsonObject in jsonObjects) {
        //handle nil
        if(!jsonObject || [jsonObject isKindOfClass:NSNull.class]) {
            
            continue;
        }
        
        if([jsonObject isKindOfClass:NSDictionary.class] ||
           [jsonObject isKindOfClass:NSMutableDictionary.class]) {
            
            if(objectType && [objectType isSubclassOfClass:MZObject.class]) {//Handle MZObject Array Serialize
                
                id object = [[objectType alloc] initWithJsonObject:jsonObject];
                
                if(object) {
                    
                    [list addObject:object];
                }
                
                continue;
            }
            
            [list addObject:jsonObject];
            continue;
        }
        
        [list addObject:jsonObject];
        continue;
    }
    
    return list;
}

- (NSDictionary *)exportToJsonObject {
    
    NSMutableDictionary * jsonObject = [NSMutableDictionary dictionary];
    NSDictionary<NSString *, MZObjectPropertyAttribute *> * classProperties = scanPropertyAttributeOfClass(self.class);
    
    if(!classProperties || 0 == classProperties.count)
        return [NSDictionary dictionaryWithDictionary:jsonObject];
    
    //loop over the incoming keys and set self's properties
    for (MZObjectPropertyAttribute * property in [classProperties allValues]) {
        
        //convert key name to model keys, if a mapper is provided
        NSString* key = property.name;
        
        if(property) {
            // 1) handle nils
            id value = [self valueForKey:key];
            Class valueClass = property.type;
            if (!valueClass || [valueClass isKindOfClass:[NSNull class]]) {
                
                [jsonObject setValue:value forKey:key];
                continue;
            }
            
            // 2) check if property is itself a JSONModel
            if ([valueClass isSubclassOfClass:[MZObject class]]) {
                
                //initialize the property's model
                id subJsonObject = [value toJsonObject];
                
                [jsonObject setValue:subJsonObject forKey:key];
                //for clarity, does the same without continue
                continue;
            }
            
            // 3) handle array type
            if(valueClass == NSArray.class ||
               valueClass == NSMutableArray.class) {
                
                Class protocolClass = NSClassFromString(property.protocol);
                if(protocolClass && [protocolClass isSubclassOfClass:[MZObject class]]) {
                    
                    NSMutableArray * subJsonObject = [NSMutableArray array];
                    [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        id objJsonObject = [obj toJsonObject];
                        [subJsonObject addObject:objJsonObject];
                    }];
                    
                    [jsonObject setValue:subJsonObject forKey:key];
                    continue;
                }
                
                id subJsonObject = nil;
                if(property.isMutable) {
                    
                    subJsonObject = [value mutableCopy];
                }
                else {
                    subJsonObject = [value copy];
                }
                
                [jsonObject setValue:subJsonObject forKey:key];
                continue;
            }
            
            // 4) handle dictionary type
            if(valueClass == NSDictionary.class ||
               valueClass == NSMutableDictionary.class) {
                
                id subJsonObject = nil;
                if(property.isMutable) {
                    
                    subJsonObject = [value mutableCopy];
                }
                else {
                    
                    subJsonObject = [value copy];
                }
                
                [jsonObject setValue:subJsonObject forKey:key];
                continue;
            }
            
            // 4) handle "all other" cases (if any)
            [jsonObject setValue:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:jsonObject];
}
@end
