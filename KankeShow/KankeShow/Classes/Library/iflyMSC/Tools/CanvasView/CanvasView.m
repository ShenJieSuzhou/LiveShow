//
//  CanvasView.m
//  Created by sluin on 16/3/1.
//  Copyright (c) 2016年 SunLin. All rights reserved.
//

#import "CanvasView.h"

@implementation CanvasView
{
    CGContextRef context ;
}

- (void)drawRect:(CGRect)rect
{
    [self drawPointWithPoints:self.arrPersons];
    [self drawFixedPointWithPoints:self.arrFixed];
}

-(void)drawPointWithPoints:(NSArray *)arrPersons
{
    if (context) {
        CGContextClearRect(context, self.bounds) ;
    }
    context = UIGraphicsGetCurrentContext();
    
    for (NSDictionary *dicPerson in arrPersons) {
        if ([dicPerson objectForKey:POINTS_KEY]) {
            for (NSString *strPoints in [dicPerson objectForKey:POINTS_KEY]) {
                CGPoint p = CGPointFromString(strPoints);
                CGContextAddEllipseInRect(context, CGRectMake(p.x - 1 , p.y - 1 , 2 , 2));
            }
        }
        
        BOOL isOriRect=NO;
        if ([dicPerson objectForKey:RECT_ORI]) {
            isOriRect=[[dicPerson objectForKey:RECT_ORI] boolValue];
        }
        
        if ([dicPerson objectForKey:RECT_KEY]) {
            
            CGRect rect=CGRectFromString([dicPerson objectForKey:RECT_KEY]);
            
            if(isOriRect){//完整矩形
                CGContextAddRect(context,rect) ;
            }
            else{ //只画四角
                // 左上
                CGContextMoveToPoint(context, rect.origin.x, rect.origin.y+rect.size.height/8);
                CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
                CGContextAddLineToPoint(context, rect.origin.x+rect.size.width/8, rect.origin.y);
                
                //右上
                CGContextMoveToPoint(context, rect.origin.x+rect.size.width*7/8, rect.origin.y);
                CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y);
                CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height/8);
                
                //左下
                CGContextMoveToPoint(context, rect.origin.x, rect.origin.y+rect.size.height*7/8);
                CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y+rect.size.height);
                CGContextAddLineToPoint(context, rect.origin.x+rect.size.width/8, rect.origin.y+rect.size.height);
                
                
                //右下
                CGContextMoveToPoint(context, rect.origin.x+rect.size.width*7/8, rect.origin.y+rect.size.height);
                CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
                CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height*7/8);
            }
        }
    }
    
    [[UIColor greenColor] set];
    CGContextSetLineWidth(context, 2);
    CGContextStrokePath(context);
}

-(void)drawFixedPointWithPoints:(NSArray *)arrFixed
{
    for (NSDictionary *dicPerson in arrFixed) {
        if ([dicPerson objectForKey:POINTS_KEY]) {
            for (NSString *strPoints in [dicPerson objectForKey:POINTS_KEY]) {
                CGPoint p = CGPointFromString(strPoints);
                CGContextAddEllipseInRect(context, CGRectMake(p.x - 1 , p.y - 1 , 2 , 2));
            }
        }
        
        if ([dicPerson objectForKey:RECT_KEY]) {
            
            CGRect rect=CGRectFromString([dicPerson objectForKey:RECT_KEY]);
            
            // 左上
            CGContextMoveToPoint(context, rect.origin.x, rect.origin.y+rect.size.height/8);
            CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
            CGContextAddLineToPoint(context, rect.origin.x+rect.size.width/8, rect.origin.y);
            
            //右上
            CGContextMoveToPoint(context, rect.origin.x+rect.size.width*7/8, rect.origin.y);
            CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y);
            CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height/8);
            
            //左下
            CGContextMoveToPoint(context, rect.origin.x, rect.origin.y+rect.size.height*7/8);
            CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y+rect.size.height);
            CGContextAddLineToPoint(context, rect.origin.x+rect.size.width/8, rect.origin.y+rect.size.height);
            
            
            //右下
            CGContextMoveToPoint(context, rect.origin.x+rect.size.width*7/8, rect.origin.y+rect.size.height);
            CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
            CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height*7/8);
            
        }
    }
    
    [[UIColor blueColor] set];
    CGContextSetLineWidth(context, 2);
    CGContextStrokePath(context);
}

//- (void)drawRect:(CGRect)rect
//{
//    [self drawPointWithPoints:self.arrPersons];
//}
//
//-(void)drawPointWithPoints:(NSArray *)arrPersons
//{
//    if (context) {
//        CGContextClearRect(context, self.bounds) ;
//    }
//    context = UIGraphicsGetCurrentContext();
//
//    for (NSDictionary *dicPerson in arrPersons) {
//        if ([dicPerson objectForKey:POINTS_KEY]) {
//            NSArray * ary = [dicPerson objectForKey:POINTS_KEY];
//            for (int i=0; i<ary.count; i++) {
//                if (i == 3 || i == 0) {
//                    NSString * strPoints = ary[i];
//                    CGPoint p = CGPointFromString(strPoints);
//                    UIImage *image = [UIImage imageNamed:@"glasses"];
//                    CGContextDrawImage(context, CGRectMake(p.x - 25 , p.y - 25 , 80 , 50), image.CGImage);//使用这个使图片上下颠倒了，参考
//                }
//            }
//        }
//    }
////    CGContextSetLineWidth(context, 2);
//    CGContextStrokePath(context);
//}

@end
