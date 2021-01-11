//
//  IntroScene.m
//  Cookieman
//
//  Created by Macdocdoc on 6/12/14.
//  Copyright Box of Markers 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "GameScene.h"
#import "CCAnimation.h"
#import "CCAnimationCache.h"
#import "CCTexture.h"
#import "CCTextureCache.h"

#define random_range(low,high) (arc4random()%(high-low+1))+low
#define frandom (float)arc4random()/UINT64_C(0x100000000)
#define frandom_range(low,high) ((high-low)*frandom)+low
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation IntroScene {
    
    id idleAction;
    id moveAction;
    
    CCSprite *backclouds1;
    CCSprite *backfarhills1;
    CCSprite *backclosehills1;
    CCSprite *backfloor1;
    
    CCSprite *flower1;
    CCSprite *flower2;
    CCSprite *flower3;
    
    CCSprite *cookieman;
    CCSprite *title;
    
    int isRestartShown;
    
    CCLabelTTF *start;
    CCLabelTTF *l1;
    CCLabelTTF *l2;
    CCLabelTTF *l3;
    
    NSString *font;

}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCDirector sharedDirector] purgeCachedData];
    
    isRestartShown = 0;
    self.userInteractionEnabled = YES;
    font = @"Cooper";
    
    CCNodeColor *back = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2 green:1.0 blue:1.0]];
    [self addChild:back z:-1 name:@"back"];
    
    CCSprite *backsky = [CCSprite spriteWithImageNamed:@"backsky.png"];
    backsky.anchorPoint = ccp(1.0f, 1.0f);
    backsky.position = ccp(self.contentSize.width, self.contentSize.height);
    [self addChild:backsky z:0 name:@"backsky"];
    
    
    backclouds1 = [CCSprite spriteWithImageNamed:@"backclouds.png"];
    backclouds1.anchorPoint = ccp(1.0f, 0.0f);
    backclouds1.position = ccp(self.contentSize.width, 0.0);
    [self addChild:backclouds1 z:1 name:@"backclouds1"];
    
    backfarhills1 = [CCSprite spriteWithImageNamed:@"backfarhills.png"];
    backfarhills1.anchorPoint = ccp(1.0f, 0.0f);
    backfarhills1.position = ccp(self.contentSize.width, 0);
    [self addChild:backfarhills1 z:2 name:@"backfarhills1"];
    
    backclosehills1 = [CCSprite spriteWithImageNamed:@"backclosehills.png"];
    backclosehills1.anchorPoint = ccp(1.0f, 0.0f);
    backclosehills1.position = ccp(self.contentSize.width, 0);
    [self addChild:backclosehills1 z:4 name:@"backclosehills1"];
    
    backfloor1 = [CCSprite spriteWithImageNamed:@"backfloor.png"];
    backfloor1.anchorPoint = ccp(1.0f, 0.0f);
    backfloor1.position = ccp(self.contentSize.width, 0);
    [self addChild:backfloor1 z:4 name:@"backfloor1"];
    
    flower1 = [self makeFlower];
    [backfloor1 addChild:flower1 z:10 name:@"flower1"];
    flower2 = [self makeFlower];
    [backfloor1 addChild:flower2 z:10 name:@"flower2"];
    flower3 = [self makeFlower];
    [backfloor1 addChild:flower3 z:10 name:@"flower3"];
    
    NSString *animationName = @"IDLE_ANIMATION";
    CCAnimation* animation = Nil;
    animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    
    if(!animation) {
        
        NSMutableArray *animFrames = [NSMutableArray array];
        
        for (int i=1; i<=1; i++) {
            NSString *path = [NSString stringWithFormat:@"cookieman_idle%d.png", i];
            CCTexture* tex = [[CCTextureCache sharedTextureCache] addImage:path];
            CGSize texSize = tex.contentSize;
            CGRect texRect = CGRectMake(0, 0, texSize.width, texSize.height);
            CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rectInPixels:texRect rotated:NO offset:CGPointMake(0, 0) originalSize:texSize];
            [animFrames addObject:frame];
        }
        animation = [CCAnimation animationWithSpriteFrames:animFrames];
        animation.delayPerUnit = 0.1f;
        animation.restoreOriginalFrame = YES;
        
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:animationName];
        
    }
    
    idleAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:animation]];
    
    animationName = @"MOVE_ANIMATION";
    animation = Nil;
    animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    
    if(!animation) {
        
        NSMutableArray *animFrames = [NSMutableArray array];
        
        for (int i=1; i<=4; i++) {
            NSString *path = [NSString stringWithFormat:@"cookieman_m%d.png", i];
            CCTexture* tex = [[CCTextureCache sharedTextureCache] addImage:path];
            CGSize texSize = tex.contentSize;
            CGRect texRect = CGRectMake(0, 0, texSize.width, texSize.height);
            CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rectInPixels:texRect rotated:NO offset:CGPointMake(0, 0) originalSize:texSize];
            [animFrames addObject:frame];
        }
        animation = [CCAnimation animationWithSpriteFrames:animFrames];
        animation.delayPerUnit = 0.1f;
        animation.restoreOriginalFrame = NO;
        
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:animationName];
        
    }
    
    moveAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:animation]];
    
    animation = nil;
    
    cookieman = [CCSprite spriteWithImageNamed:@"cookieman_idle1.png"];
    cookieman.scale = 0.3;
    cookieman.position = ccp(self.contentSize.width/2, backsky.boundingBox.size.height*.28);
    CGPoint cookiemanOrigin = cookieman.position;
    cookieman.anchorPoint = ccp(0.5f, 0.0f);
    [self addChild:cookieman z:10 name:@"cookieman"];
    
    // Initialize walking animation
    [cookieman runAction:moveAction];
    
    // Move cookieman off screen
    cookieman.position = ccp(0.0-cookieman.boundingBox.size.width, cookieman.position.y);
    
    // Move him to origin
    id cookiemanDelay = [CCActionDelay actionWithDuration:.5];
    id m1 = [CCActionMoveTo actionWithDuration:3 position:ccp(cookiemanOrigin.x, cookiemanOrigin.y)];
    id m2 = [CCActionCallBlock actionWithBlock:(^{
        [cookieman stopAllActions];
        [cookieman runAction:idleAction];
    })];
    id m = [CCActionSequence actionWithArray:@[cookiemanDelay,m1,m2]];
    [cookieman runAction:m];
    
    cookiemanDelay = nil;
    m1 = nil;
    m2 = nil;
    m = nil;
    
    float l1Size = 24.0f;
    float l2Size = 52.0f;
    float l3Size = 52.0f;
    if(!IS_IPAD) {
        l1Size = 18.0f;
        l2Size = 42.0f;
        l3Size = 42.0f;
    }
    
    // Title
    l1 = [CCLabelTTF labelWithString:@" The " fontName:font fontSize:l1Size];
    l1.position = ccp(self.contentSize.width/2, self.contentSize.height*.85);
    l1.color = [CCColor whiteColor];
    l1.outlineColor = [CCColor blackColor];
    l1.outlineWidth = 2;
    [self addChild:l1 z:10 name:@"l1"];
    
    l2 = [CCLabelTTF labelWithString:@" COOKIE " fontName:font fontSize:l2Size];
    l2.position = ccp(self.contentSize.width/2, l1.position.y-l1.boundingBox.size.height/2-l2.boundingBox.size.height/2);
    l2.color = [CCColor whiteColor];
    l2.outlineColor = [CCColor blackColor];
    l2.outlineWidth = 2;
    [self addChild:l2 z:10 name:@"l2"];
    
    l3 = [CCLabelTTF labelWithString:@" GUY " fontName:font fontSize:l3Size];
    l3.position = ccp(self.contentSize.width/2, l2.position.y-l2.boundingBox.size.height/2-l3.boundingBox.size.height/2);
    l3.color = [CCColor whiteColor];
    l3.outlineColor = [CCColor blackColor];
    l3.outlineWidth = 2;
    [self addChild:l3 z:10 name:@"l3"];
    
    CGPoint l1Origin = l1.position;
    CGPoint l2Origin = l2.position;
    CGPoint l3Origin = l3.position;
    
    l1.position = ccp(self.contentSize.width+l2.boundingBox.size.width/2, l1.position.y);
    l2.position = ccp(self.contentSize.width+l2.boundingBox.size.width/2, l2.position.y);
    l3.position = ccp(self.contentSize.width+l2.boundingBox.size.width/2, l3.position.y);
    
    id titleDelay = [CCActionDelay actionWithDuration:.5];
    id f1 = [CCActionCallBlock actionWithBlock:(^{
    [l1 runAction:[CCActionMoveTo actionWithDuration:.2 position:l1Origin]];
    })];
    id f2 = [CCActionCallBlock actionWithBlock:(^{
    [l2 runAction:[CCActionMoveTo actionWithDuration:.2 position:l2Origin]];
    })];
    id f3 = [CCActionCallBlock actionWithBlock:(^{
    [l3 runAction:[CCActionMoveTo actionWithDuration:.2 position:l3Origin]];
    })];
    
    id fd1 = [CCActionDelay actionWithDuration:.5];
    id fd2 = [CCActionDelay actionWithDuration:.5];
    id fd3 = [CCActionDelay actionWithDuration:.5];
    
    [self runAction:[CCActionSequence actionWithArray:@[titleDelay, f1, fd1, f2, fd2, f3, fd3]]];
    
    titleDelay = nil;
    f1 = nil;
    fd1 = nil;
    f2 = nil;
    fd2 = nil;
    f3 = nil;
    fd3 = nil;
    
    float restartFontSize = 40.0f;
    if(!IS_IPAD) restartFontSize = 40.0f;
    
    // Show start button
    start = [CCLabelTTF labelWithString:@" Start " fontName:font fontSize:restartFontSize];
    start.outlineColor = [CCColor blackColor];
    start.outlineWidth = 2;
    start.color = [CCColor whiteColor];

    start.position = ccp(self.contentSize.width + start.boundingBox.size.width, start.boundingBox.size.height/2 + 40);
    CGPoint finalPos = ccp(self.contentSize.width/2,start.boundingBox.size.height/2+40);
    [self addChild:start z:10 name:@"restart"];
    
    id a1 = [CCActionCallBlock actionWithBlock:(^{
        [start runAction:[CCActionMoveTo actionWithDuration:.2 position:finalPos]];
    })];
    
    id a2 = [CCActionCallBlock actionWithBlock:(^{
        isRestartShown = 1;
    })];
    
    [self runAction:[CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:4],a1,[CCActionDelay actionWithDuration:.5] ,a2]]];
    
    a1 = nil;
    a2 = nil;
    
	return self;
}


-(CCSprite *)makeFlower {
    CCSprite *f = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"flower%d.png",random_range(1, 2)]];
    f.anchorPoint = ccp(0.5f, 0.0f);
    f.positionType = CCPositionTypeNormalized;
    f.position = ccp(frandom_range(0.0, 1.0), frandom_range(0.2, 0.33));
    return f;
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchLocation = [touch locationInNode:self];
    
    if(isRestartShown == 1) {
        
        if(CGRectContainsPoint(CGRectMake(start.position.x-start.boundingBox.size.width/2, start.position.y-start.boundingBox.size.height/2, start.boundingBox.size.width, start.boundingBox.size.height), touchLocation)) {
            
            [self startGameScene];
            
        }
        
    }
    
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)startGameScene {
    
    
    // start spinning scene with transition
    id b1 = [CCActionCallBlock actionWithBlock:(^{
        [l1 runAction:[CCActionMoveTo actionWithDuration:.3 position:ccp(self.contentSize.width/2, self.contentSize.height+l1.boundingBox.size.height+l2.boundingBox.size.height+l3.boundingBox.size.height)]];
        [l2 runAction:[CCActionMoveTo actionWithDuration:.3 position:ccp(self.contentSize.width/2, self.contentSize.height+l1.boundingBox.size.height+l2.boundingBox.size.height+l3.boundingBox.size.height)]];
        [l3 runAction:[CCActionMoveTo actionWithDuration:.3 position:ccp(self.contentSize.width/2, self.contentSize.height+l1.boundingBox.size.height+l2.boundingBox.size.height+l3.boundingBox.size.height)]];
        [start runAction:[CCActionMoveTo actionWithDuration:.3 position:ccp(self.contentSize.width/2, 0.0-start.boundingBox.size.height)]];
    })];
    id b2 = [CCActionCallBlock actionWithBlock:(^{
        
        idleAction = nil;
        moveAction = nil;
        backclouds1 = nil;
        backfarhills1 = nil;
        backclosehills1 = nil;
        backfloor1 = nil;
        flower1 = nil;
        flower2 = nil;
        flower3 = nil;
        cookieman = nil;
        title = nil;
        start = nil;
        l1 = nil;
        l2 = nil;
        l3 = nil;
        
        [self removeAllChildrenWithCleanup:YES];
        [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    })];
    id b = [CCActionSequence actionWithArray:@[b1,[CCActionDelay actionWithDuration:.5],b2]];
    
    [self runAction:b];
    
    b1 = nil;
    b2 = nil;
    b = nil;
    
}

// -----------------------------------------------------------------------
@end
