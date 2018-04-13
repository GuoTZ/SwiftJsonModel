//
//  NETViewController.m
//  SwiftModel
//
//  Created by RM on 2018/4/11.
//  Copyright © 2018年 GTZ. All rights reserved.
//

#import "NETViewController.h"


@interface JsonType : NSObject
///，NET类型
@property (nonatomic, copy) NSString *netType;
///SWift类型
@property (nonatomic, copy) NSString *swiftType;
///SWift类型默认值
@property (nonatomic, copy) NSString *defaultValue;
@end
@implementation JsonType

@end

@interface Attribute : NSObject
///注释
@property (nonatomic, copy) NSString *annotation;
//类型
@property (nonatomic, copy) NSString *type;
///属性
@property (nonatomic, copy) NSString *Attribute;
///SWift类型默认值
@property (nonatomic, copy) NSString *defaultValue;
@end
@implementation Attribute

@end

@interface NETViewController ()
@property (weak) IBOutlet NSTextView *netTF;
@property (weak) IBOutlet NSTextField *prefixTF;
@property (nonatomic, strong) NSMutableArray<JsonType *>  *typeArray;
@property (nonatomic, strong) NSArray<NSString *>  *OCArray;
@property (nonatomic, strong) NSMutableArray<Attribute *>  *mutableArray;
@end

@implementation NETViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mutableArray = [NSMutableArray array];
    self.typeArray = [NSMutableArray array];
    NSArray *NETTypeArray = @[@"bool",@"decimal",@"double",@"float",@"int",@"long",@"String",@"DateTime",@"string"];
    NSArray *swiftTypeArray = @[@"Bool",@"Double",@"Double",@"Float",@"Int",@"Int",@"String",@"String",@"String"];
    NSArray *defaultValueArray = @[@"false",@"0",@"0",@"0",@"0",@"0",@"\"\"",@"\"\"",@"\"\""];
    self.OCArray = @[@"BOOL",@"double",@"double",@"float",@"NSInteger",@"NSInteger",@"NSString",@"NSString",@"NSString"];
    for (int i=0; i< NETTypeArray.count; i ++ ) {
        JsonType * type = [[JsonType alloc]init];
        type.netType = [NETTypeArray objectAtIndex:i];
        type.swiftType = [swiftTypeArray objectAtIndex:i];
        type.defaultValue = [defaultValueArray objectAtIndex:i];
        [self.typeArray addObject:type];
    }
    
    
    
}
///生成oc
- (IBAction)okOCAction:(id)sender {
    if (self.netTF.string.length==0) {
        [self alertMsg:@"请输入要转换的json"];
        return;
    }
    
    NSString *json = [[[[[[self.netTF.string stringByReplacingOccurrencesOfString:@";" withString:@""]stringByReplacingOccurrencesOfString:@"get" withString:@""]stringByReplacingOccurrencesOfString:@"set" withString:@""]stringByReplacingOccurrencesOfString:@"{" withString:@""]stringByReplacingOccurrencesOfString:@"}" withString:@""]stringByReplacingOccurrencesOfString:@"///" withString:@""];
    
    NSArray * array = [json componentsSeparatedByString:@"<summary>"];
    NSLog(@"%@", array);
    NSString *attStr = [NSString stringWithFormat:@"@interface Model : %@ \n",self.prefixTF.stringValue.length?self.prefixTF.stringValue:@"NSObject"];
    for (NSString *str in array) {
        Attribute *att = [[Attribute alloc]init];
        NSArray *subArr = [str componentsSeparatedByString:@"</summary>"];
        ///去掉回车与tab
        NSString *annotation = [[[subArr.firstObject stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\r" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
        att.annotation = annotation ;
        [self config:[[subArr.lastObject stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\r" withString:@""] attribute:att];
        if (att.Attribute) {
            [self.mutableArray addObject:att];
            if ([att.type isEqualToString:self.typeArray[0].swiftType] ||
                [att.type isEqualToString:self.typeArray[2].swiftType] ||
                [att.type isEqualToString:self.typeArray[3].swiftType] ||
                [att.type isEqualToString:self.typeArray[4].swiftType] ||
                [att.type isEqualToString:self.typeArray[5].swiftType] ||
                [att.type isEqualToString:self.typeArray[6].swiftType] ||
                [att.type isEqualToString:self.typeArray[7].swiftType] ||
                [att.type isEqualToString:self.typeArray[8].swiftType] ) {
                NSInteger index = 0;
                for (JsonType *typ in self.typeArray) {
                    if ([typ.swiftType isEqualToString:att.type]) {
                        index = [self.typeArray indexOfObject:typ];
                    }
                }
                if (index>5) {
                    NSString *outStr = [NSString stringWithFormat:@"\n\r/**%@*/\r@property (nonatomic, copy) NSString *%@; ",att.annotation,att.Attribute];
                    NSLog(@"%@", outStr);
                    attStr = [NSString stringWithFormat:@"%@%@",attStr,outStr];
                } else {
                    NSString *outStr = [NSString stringWithFormat:@"\n\r/**%@*/\r@property (nonatomic, assign) %@ %@; ",att.annotation,[self.OCArray objectAtIndex:index],att.Attribute];
                    NSLog(@"%@", outStr);
                    attStr = [NSString stringWithFormat:@"%@%@",attStr,outStr];
                }
            } else {
                NSString *outStr = [NSString stringWithFormat:@"\n\r/**%@*/\r@property (nonatomic, strong) %@ *%@; ",att.annotation,att.type,att.Attribute];
                NSLog(@"%@", outStr);
                attStr = [NSString stringWithFormat:@"%@%@",attStr,outStr];
            }
            
        }
        
    }
    self.netTF.string = attStr;
    self.netTF.string = [NSString stringWithFormat:@"%@\n@end",self.netTF.string];
    self.netTF.string = [NSString stringWithFormat:@"%@\n@implementation Model\n",self.netTF.string];
    self.netTF.string = [NSString stringWithFormat:@"%@+ (NSDictionary *)modelContainerPropertyGenericClass {\n\rreturn @{ };\n}",self.netTF.string];
    self.netTF.string = [NSString stringWithFormat:@"%@\n@end",self.netTF.string];
}

- (IBAction)okBtn:(id)sender {
    if (self.netTF.string.length==0) {
        [self alertMsg:@"请输入要转换的json"];
        return;
    }
    
    NSString *json = [[[[[[self.netTF.string stringByReplacingOccurrencesOfString:@";" withString:@""]stringByReplacingOccurrencesOfString:@"get" withString:@""]stringByReplacingOccurrencesOfString:@"set" withString:@""]stringByReplacingOccurrencesOfString:@"{" withString:@""]stringByReplacingOccurrencesOfString:@"}" withString:@""]stringByReplacingOccurrencesOfString:@"///" withString:@""];
    
    NSArray * array = [json componentsSeparatedByString:@"<summary>"];
    NSLog(@"%@", array);
    NSString *attStr = @"";
    for (NSString *str in array) {
        Attribute *att = [[Attribute alloc]init];
        NSArray *subArr = [str componentsSeparatedByString:@"</summary>"];
        ///去掉回车与tab
        NSString *annotation = [[[subArr.firstObject stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\r" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
        att.annotation = annotation ;
        [self config:[[subArr.lastObject stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\r" withString:@""] attribute:att];
        if (att.Attribute) {
            [self.mutableArray addObject:att];
        
            NSString *outStr = [NSString stringWithFormat:@"\r/**%@*/\rpublic var %@ : %@ = %@",att.annotation,att.Attribute,att.type,att.defaultValue];
            NSLog(@"%@", outStr);
            attStr = [NSString stringWithFormat:@"%@%@",attStr,outStr];
        }
        
    }
    NSString *supModel = self.prefixTF.stringValue.length ? self.prefixTF.stringValue : @"Codable";
    self.netTF.string = [NSString stringWithFormat:@"public class Model : %@ {\n %@ ",supModel,attStr];

    self.netTF.string = [NSString stringWithFormat:@"%@\n\rprivate enum CodingKeys : String, CodingKey {\n",self.netTF.string];
    for (Attribute *model in self.mutableArray) {
        self.netTF.string = [NSString stringWithFormat:@"%@\rcase %@ = \"%@\"",self.netTF.string,model.Attribute,model.Attribute];
    }
    self.netTF.string = [NSString stringWithFormat:@"%@\n\r}",self.netTF.string];
    self.netTF.string = [NSString stringWithFormat:@"%@\n}",self.netTF.string];
}


- (void)config:(NSString *)str attribute:(Attribute *)attribute{
    while ([str hasPrefix:@"\r"]) {
        
        str = [str substringFromIndex:1];
    }
    while ([str hasSuffix:@"\r"]) {
        
        str = [str substringToIndex:([str length] - 1)];
    }
    while ([str hasPrefix:@" "]) {
        
        str = [str substringFromIndex:1];
    }
    while ([str hasSuffix:@" "]) {
        
        str = [str substringToIndex:([str length] - 1)];
    }
    NSArray *subArr = [str componentsSeparatedByString:@" "];
    
    for (NSString *s in subArr) {
        if (s.length>0) {
            if ([subArr.firstObject isEqualToString:s]) {
            } else  if ([subArr.lastObject isEqualToString:s]){
                attribute.Attribute = s;
            } else {
                if ([s isEqualToString:self.typeArray[0].netType] ||
                         [s isEqualToString:self.typeArray[2].netType] ||
                         [s isEqualToString:self.typeArray[3].netType] ||
                         [s isEqualToString:self.typeArray[4].netType] ||
                         [s isEqualToString:self.typeArray[5].netType] ||
                         [s isEqualToString:self.typeArray[6].netType] ||
                         [s isEqualToString:self.typeArray[7].netType] ||
                         [s isEqualToString:self.typeArray[8].netType] ){
                    for (JsonType *type in self.typeArray) {
                        if ([s isEqualToString:type.netType]) {
                            attribute.type = type.swiftType;
                            attribute.defaultValue = type.defaultValue;
                        }
                    }
                } else {
                    attribute.type = s;
                    attribute.defaultValue = [NSString stringWithFormat:@"%@()",s];
                }
            }
        }
    }
}


- (void)alertMsg:(NSString *)msg {
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    [alert setMessageText:msg];
    [alert setInformativeText:@"请输入正确格式的json"];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            self.netTF.string = @"";
        }else if(returnCode == NSAlertSecondButtonReturn){
        }
    }];
}

@end
