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
    
    for (int i=0; i< NETTypeArray.count; i ++ ) {
        JsonType * type = [[JsonType alloc]init];
        type.netType = [NETTypeArray objectAtIndex:i];
        type.swiftType = [swiftTypeArray objectAtIndex:i];
        type.defaultValue = [defaultValueArray objectAtIndex:i];
        [self.typeArray addObject:type];
    }
    
    
    
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
        att.annotation = annotation;

        
        [self config:[[subArr.lastObject stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\r" withString:@""] attribute:att];
        [self.mutableArray addObject:att];
        NSString *outStr = [NSString stringWithFormat:@"\r/**%@*/\rpublic var %@ : %@ = %@",att.annotation,att.Attribute,att.type,att.defaultValue];
        NSLog(@"%@", outStr);
        attStr = [NSString stringWithFormat:@"%@\n%@",attStr,outStr];
        
    }
    NSString *supModel = self.prefixTF.stringValue.length ? self.prefixTF.stringValue : @"Codable";
    self.netTF.string = [NSString stringWithFormat:@"public class Model : %@ {\n %@ ",supModel,attStr];
    /**
    private enum CodingKeys : String, CodingKey {
    case name
    case abc = "alc_v"
    case brewery
    case style
    }
    */
    self.netTF.string = [NSString stringWithFormat:@"%@\n\rprivate enum CodingKeys : String, CodingKey {\n",self.netTF.string];
    for (Attribute *model in self.mutableArray) {
        self.netTF.string = [NSString stringWithFormat:@"%@\n\rcase %@ = \"%@\"",self.netTF.string,model.Attribute,model.Attribute];
    }
    self.netTF.string = [NSString stringWithFormat:@"%@\n\r}",self.netTF.string];
    self.netTF.string = [NSString stringWithFormat:@"%@\n}",self.netTF.string];
}


- (void)config:(NSString *)str attribute:(Attribute *)attribute{
    NSArray *subArr = [str componentsSeparatedByString:@" "];
    
    for (NSString *s in subArr) {
        if (s.length>0) {
            if ([s isEqualToString:@"public"]) {
            } else if ([s isEqualToString:self.typeArray[0].netType] ||
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
                attribute.Attribute = s;
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
