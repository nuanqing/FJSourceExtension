//
//  JSToProperty.m
//  FJSourceExtension
//
//  Created by webplus on 17/12/12.
//  Copyright © 2017年 nuanqing. All rights reserved.
//

#import "JSToProperty.h"

@implementation JSToProperty

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    NSInteger startLine = range.start.line;
    NSInteger endLine = range.end.line;
    NSString *totalString = @"";
    for (NSInteger i = startLine; i <= endLine; i++) {
        totalString = [totalString stringByAppendingString:invocation.buffer.lines[i]];
    }
    //解析
    NSData *data = [[NSData alloc] initWithData:[totalString dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (dict == nil) NSLog(@"数据无法解析！");
    
    __block NSString *outPutString = @"";
    
    //判断字典中的类型
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *type = @"";
        NSString *semantics = @"";
        if ([obj isKindOfClass:[NSString class]]) {
            type = @"NSString";
            semantics = @"copy";
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            type = @"NSDictionary";
            semantics = @"copy";
        }else if ([obj isKindOfClass:[NSArray class]]){
            type = @"NSArray";
            semantics = @"copy";
        }else if ([obj isKindOfClass:[NSNumber class]]){
            type = @"NSNumber";
            semantics = @"strong";
        }else{
            type = @"id";
            semantics = @"strong";
        }
        //注释
        outPutString = [outPutString stringByAppendingString:@"\n//"];
        //模型属性
        outPutString = [outPutString stringByAppendingString:[NSString stringWithFormat:@"\n@property (nonatomic, %@) %@ *%@;",semantics,type,key]];
    }];
    
    [invocation.buffer.lines insertObject:outPutString atIndex:endLine+1];
    
    
    completionHandler(nil);
}
@end
