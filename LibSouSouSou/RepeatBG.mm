//
//  RepeatBG.m
//  GameSouSouSou
//
//  Created by Fancyzero on 13-5-25.
//
//

#import "RepeatBG.h"
@implementation RepeatBG
@synthesize m_offset;
@synthesize m_width;

-(void) draw
{

    float w = texture_.contentSize.width;
    quad_.tl.texCoords.u = quad_.bl.texCoords.u = 0 + m_offset / w;
    quad_.bl.texCoords.v = 1;
    quad_.tl.texCoords.v = 0;
    quad_.tr.texCoords.u = quad_.br.texCoords.u = (m_offset + m_width)/w;
    quad_.br.texCoords.v = 1;
    quad_.tr.texCoords.v = 0;
    [super draw];
    
    
}
@end
