//
//  CircleView.m
//  RCTAgora
//
//  Created by Jason Liang on 9/9/18.
//

#import "CircleView.h"

@implementation CircleView

- (void)drawRect:(CGRect)rect {
  CGRect borderRect = CGRectInset(self.bounds, 2, 2);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.8);
  CGContextSetRGBFillColor(context, 1, 1, 1, 0.5);
  CGContextSetLineWidth(context, 2.0);
  CGContextFillEllipseInRect (context, borderRect);
  CGContextStrokeEllipseInRect(context, borderRect);
  CGContextFillPath(context);
}

@end
