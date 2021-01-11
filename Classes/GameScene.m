//
//  GameScene.m
//  Cookieman
//
//  Created by Macdocdoc on 6/12/14.
//  Copyright 2014 Box of Markers. All rights reserved.
//

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
#define MM_BG_SPEED_DUR       ( IS_IPAD ? (6.0f) : (2.0f) )
#define IS_FIRST_IPAD !([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])

typedef enum _ActionState {
    kActionStateNone = 0,
    kActionStateIdle,
    kActionStateMove,
    kActionStateEat
} ActionState;

@implementation GameScene {
    
    CCTime dtGlobal;
    
    int isPressingArrow;
    int isCookieAnimated;
    int isEatingCookie;
    int isRestartShown;
    int isRetina;
    int isAndroidTablet;
    int canEatCookie;
    
    CCSprite *button;
    CCSprite *arrow;
    
    CCSprite *backclouds1;
    CCSprite *backclouds2;
    
    CCSprite *backfarhills1;
    CCSprite *backfarhills2;
    
    CCSprite *backclosehills1;
    CCSprite *backclosehills2;
    
    CCSprite *backfloor1;
    CCSprite *backfloor2;
    
    CCSprite *flower1;
    CCSprite *flower2;
    CCSprite *flower3;
    CCSprite *flower4;
    CCSprite *flower5;
    CCSprite *flower6;
    
    CCSprite *cookie;
    
    id idleAction;
    id moveAction;
    id blinkAction;
    id cookieAction;
    id grabAndBiteAction;
    id chewAction;
    
    ActionState actionState;
    
    CCSprite *cookieman;
    
    float gameTime;
    float lastBlink;

    float distanceOfCookie;
    
    float cookieOriginY;
    
    // All around font
    NSString *font;
    
    // Restart label
    CCLabelTTF *restart;
    
    // cookie count
    int cookieCount;
    
    // Data save
    NSUserDefaults *defaults;
    
}

+ (GameScene*) scene {
    return  [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCDirector sharedDirector] purgeCachedData];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        isRetina = 1;
    } else {
        isRetina = 0;
    }
    
    self.userInteractionEnabled = YES;

    gameTime = 0.0;
    lastBlink = 0.0;
    isEatingCookie = 0;
    isRestartShown = 0;
    font = @"Cooper";
    canEatCookie = 0;
    isAndroidTablet = 0;
    
#ifdef ANDROID
    // Find the current DPI
    float dpi = [[UIScreen mainScreen] dpi];
    
    // Get the screen size in inches
    float width = [[UIScreen mainScreen] bounds].size.width / dpi;
    float height = [[UIScreen mainScreen] bounds].size.height / dpi;
    
    // Rough estimate of the screen size in inches
    float screenSize = sqrtf(width * width + height * height);
    
    if (screenSize > 6) // It's a tablet
        isAndroidTablet = 1;
    else
        isAndroidTablet = 0;
#endif
    
    defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultUserDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:0], @"cookieCount",
                                         nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultUserDefaults];
    
    cookieCount = (int)[defaults integerForKey:@"cookieCount"];
    
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
    
    backclouds2 = [CCSprite spriteWithImageNamed:@"backclouds.png"];
    backclouds2.anchorPoint = ccp(1.0f, 0.0f);
    backclouds2.position = ccp(self.contentSize.width+backclouds1.boundingBox.size.width, 0);
    [self addChild:backclouds2 z:1 name:@"backclouds2"];
    
    backfarhills1 = [CCSprite spriteWithImageNamed:@"backfarhills.png"];
    backfarhills1.anchorPoint = ccp(1.0f, 0.0f);
    backfarhills1.position = ccp(self.contentSize.width, 0);
    [self addChild:backfarhills1 z:2 name:@"backfarhills1"];
    
    backfarhills2 = [CCSprite spriteWithImageNamed:@"backfarhills.png"];
    backfarhills2.anchorPoint = ccp(1.0f, 0.0f);
    backfarhills2.position = ccp(self.contentSize.width+backfarhills1.boundingBox.size.width, 0);
    [self addChild:backfarhills2 z:2 name:@"backfarhills2"];
    
    backclosehills1 = [CCSprite spriteWithImageNamed:@"backclosehills.png"];
    backclosehills1.anchorPoint = ccp(1.0f, 0.0f);
    backclosehills1.position = ccp(self.contentSize.width, 0);
    [self addChild:backclosehills1 z:3 name:@"backclosehills1"];
    
    backclosehills2 = [CCSprite spriteWithImageNamed:@"backclosehills.png"];
    backclosehills2.anchorPoint = ccp(1.0f, 0.0f);
    backclosehills2.position = ccp(self.contentSize.width+backclosehills1.boundingBox.size.width, 0);
    [self addChild:backclosehills2 z:3 name:@"backclosehills2"];

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
    
    backfloor2 = [CCSprite spriteWithImageNamed:@"backfloor.png"];
    backfloor2.anchorPoint = ccp(1.0f, 0.0f);
    backfloor2.position = ccp(self.contentSize.width+backfloor1.boundingBox.size.width, 0);
    [self addChild:backfloor2 z:4 name:@"backfloor2"];
    
    flower4 = [self makeFlower];
    [backfloor2 addChild:flower4 z:10 name:@"flower4"];
    flower5 = [self makeFlower];
    [backfloor2 addChild:flower5 z:10 name:@"flower5"];
    flower6 = [self makeFlower];
    [backfloor2 addChild:flower6 z:10 name:@"flower6"];
    
    cookieman = [CCSprite spriteWithImageNamed:@"cookieman_idle1.png"];
    cookieman.scale = 0.3;
    cookieman.position = ccp(self.contentSize.width/2, backsky.boundingBox.size.height*.28);
    cookieman.anchorPoint = ccp(0.5f, 0.0f);
    [self addChild:cookieman z:10 name:@"cookieman"];
    
    distanceOfCookie = [self returnCookieLocation];
    
    cookie = [CCSprite spriteWithImageNamed:@"cookie_01.png"];
    cookie.scale = 0.10;
    cookie.position = ccp(cookieman.position.x+cookieman.boundingBox.size.width/2+distanceOfCookie-10, cookieman.position.y+cookieman.boundingBox.size.height/2);
    [self addChild:cookie z:9 name:@"cookie"];
    
    cookieOriginY = cookie.position.y;
    
    id up = [CCActionMoveTo actionWithDuration:1 position:ccp(cookie.position.x, cookieOriginY+5)];
    id down = [CCActionMoveTo actionWithDuration:1 position:ccp(cookie.position.x, cookieOriginY-5)];
    id seq = [CCActionSequence actionWithArray:@[up,down]];
    cookieAction = [CCActionRepeatForever actionWithAction:seq];
    isCookieAnimated = 1;
    [cookie runAction:cookieAction];
    
    up = nil;
    down = nil;
    seq = nil;
    
    button = [CCSprite spriteWithImageNamed:@"cookiebutton.png"];
    button.scale = 0.3;
    button.position = ccp(self.contentSize.width*0.25, self.contentSize.height*0.15);
    [self addChild:button z:10 name:@"button"];
    
    arrow = [CCSprite spriteWithImageNamed:@"cookiearrow.png"];
    arrow.scale = 0.3;
    arrow.position = ccp(self.contentSize.width*0.70, self.contentSize.height*0.15);
    [self addChild:arrow z:10 name:@"arrow"];

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
    
    animationName = @"CHEW_ANIMATION";
    animation = Nil;
    animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    
    if(!animation) {
        
        NSMutableArray *animFrames = [NSMutableArray array];
        
        for (int i=3; i<=4; i++) {
            NSString *path = [NSString stringWithFormat:@"cookieman_eat%d.png", i];
            CCTexture* tex = [[CCTextureCache sharedTextureCache] addImage:path];
            CGSize texSize = tex.contentSize;
            CGRect texRect = CGRectMake(0, 0, texSize.width, texSize.height);
            CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rectInPixels:texRect rotated:NO offset:CGPointMake(0, 0) originalSize:texSize];
            [animFrames addObject:frame];
        }
        animation = [CCAnimation animationWithSpriteFrames:animFrames];
        animation.delayPerUnit = 0.2f;
        animation.restoreOriginalFrame = YES;
        
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:animationName];
        
    }
    
    chewAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:animation]];
    
    animationName = @"BLINK_ANIMATION";
    animation = Nil;
    animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    
    if(!animation) {
        
        NSMutableArray *animFrames = [NSMutableArray array];
        
        for (int i=2; i<=3; i++) {
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
    
    id returnToIdle = [CCActionCallBlock actionWithBlock:(^{
        [cookieman stopAllActions];
        [cookieman runAction:idleAction];
    })];
    
    blinkAction = [CCActionSequence actionWithArray:@[[CCActionAnimate actionWithAnimation:animation],returnToIdle]];
    
    
    animationName = @"GRABANDBITE_ANIMATION";
    animation = Nil;
    animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    
    if(!animation) {
        
        NSMutableArray *animFrames = [NSMutableArray array];
        
        for (int i=1; i<=2; i++) {
            NSString *path = [NSString stringWithFormat:@"cookieman_eat%d.png", i];
            CCTexture* tex = [[CCTextureCache sharedTextureCache] addImage:path];
            CGSize texSize = tex.contentSize;
            CGRect texRect = CGRectMake(0, 0, texSize.width, texSize.height);
            CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rectInPixels:texRect rotated:NO offset:CGPointMake(0, 0) originalSize:texSize];
            [animFrames addObject:frame];
        }
        animation = [CCAnimation animationWithSpriteFrames:animFrames];
        animation.delayPerUnit = 0.3f;
        animation.restoreOriginalFrame = NO;
        
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:animationName];
        
    }
    
    id doChewDelay = [CCActionDelay actionWithDuration:0.0];
    
    id doChewAfterBite = [CCActionCallBlock actionWithBlock:(^{
        [cookieman stopAllActions];
        [cookieman runAction:chewAction];
    })];
    
    grabAndBiteAction = [CCActionSequence actionWithArray:@[[CCActionAnimate actionWithAnimation:animation],doChewDelay,doChewAfterBite]];
    
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
    
    [cookieman runAction:idleAction];
    actionState = kActionStateIdle;
    
    animation = nil;
    
    return self;
}

-(float)returnCookieLocation {
    return frandom_range(self.contentSize.width/2+cookie.boundingBox.size.width/2, 1800.0);
}

-(CCSprite *)makeFlower {
    CCSprite *f = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"flower%d.png",random_range(1, 2)]];
    f.anchorPoint = ccp(0.5f, 0.0f);
    f.positionType = CCPositionTypeNormalized;
    f.position = ccp(frandom_range(0.0, 1.0), frandom_range(0.2, 0.33));
    return f;
}

-(void)changeFlowerPosition:(CCSprite*)f {
    f.position = ccp(frandom_range(0.1, 0.9), frandom_range(0.2, 0.33));
}


-(void) update:(CCTime)dt {

    dtGlobal = dt;
    gameTime += dt;
    
    [self scrollClouds];
    
    if (cookieman.position.x+cookieman.boundingBox.size.width/2-cookie.boundingBox.size.width/2+10 < cookie.position.x) canEatCookie = 0;
    else canEatCookie = 1;
    
    if(isPressingArrow == 1 && canEatCookie == 0 && actionState != kActionStateEat) {

        if(actionState == kActionStateIdle) {
            
            actionState = kActionStateMove;
            [cookieman stopAllActions];
            [cookieman runAction:moveAction];
            
            if(isCookieAnimated) {
                
                isCookieAnimated = 0;
                cookie.position = ccp(cookie.position.x,cookieOriginY);
                [cookie stopAllActions];
                
            }
            
        }

        [self scrollAll];
        lastBlink = gameTime;
        
    } else if(actionState != kActionStateEat) {
        
        if(actionState != kActionStateIdle) {
            
            actionState = kActionStateIdle;
            [cookieman stopAllActions];
            [cookieman runAction:idleAction];
            
            if(isCookieAnimated == 0) {
                isCookieAnimated = 1;
                id up = [CCActionMoveTo actionWithDuration:1 position:ccp(cookie.position.x, cookieOriginY+4)];
                id down = [CCActionMoveTo actionWithDuration:1 position:ccp(cookie.position.x, cookieOriginY-4)];
                id seq = [CCActionSequence actionWithArray:@[up,down]];
                [cookie runAction:[CCActionRepeatForever actionWithAction:seq]];
                up = nil;
                down = nil;
                seq = nil;
            }
            
        }
        
        if(actionState == kActionStateIdle) {
            if(gameTime-lastBlink > 3) {
                lastBlink = gameTime;
                [cookieman stopAllActions];
                [cookieman runAction:blinkAction];
            }
        }
        
    } else if(actionState == kActionStateEat) {
        
        if(isEatingCookie == 0) {
            
            isEatingCookie = 1;
            [cookieman stopAllActions];
            [cookieman runAction:grabAndBiteAction];
            
        }
        
    }

}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if(isPressingArrow) return;
    
    CGPoint touchLocation = [touch locationInNode:self];
    
    // If the middle button label thing is tapped
    if(CGRectContainsPoint(CGRectMake(arrow.position.x-arrow.boundingBox.size.width/2, arrow.position.y-arrow.boundingBox.size.height/2, arrow.boundingBox.size.width, arrow.boundingBox.size.height), touchLocation) && arrow.visible) {
        
        isPressingArrow = 1;
        
        
    }
    
    if(CGRectContainsPoint(CGRectMake(button.position.x-button.boundingBox.size.width/2, button.position.y-button.boundingBox.size.height/2, button.boundingBox.size.width, button.boundingBox.size.height), touchLocation) && button.visible) {
        if( canEatCookie ) {
            if(actionState != kActionStateEat) {
                
                cookieCount++;
                [defaults setInteger:cookieCount forKey:@"cookieCount"];
                [defaults synchronize];
                
                cookie.visible = NO;
                button.visible = NO;
                arrow.visible = NO;
                actionState = kActionStateEat;
                
                // Downscale for smaller but better looking images
                float countScale = 1.0;
                float winnerScale = 1.0;
                float countFont = 25.0f;
                float countOutline = 2;
                if(self.contentSize.width < 380.0 || (!isRetina)) {
                    countScale = 0.4;
                    if(!IS_IPAD) winnerScale = 0.45;
                    countFont = 72.0f;
                    countOutline = 4;
                }
                
                // Do celebration animations
                CCSprite *winner = [CCSprite spriteWithImageNamed:@"winnerbanner.png"];
                winner.position = ccp(cookieman.position.x, cookieman.position.y+cookieman.boundingBox.size.height+winner.boundingBox.size.height/2);
                [self addChild:winner z:12 name:@"winner"];
                
                float finalWinnerScale = winnerScale;
                CGPoint finalWinnerPos = winner.position;
                finalWinnerPos = ccp(cookieman.position.x, cookieman.position.y-25);
                
                winner.scale = 0.0;
                winner.position = finalWinnerPos;
                
                id wDelay = [CCActionDelay actionWithDuration:1];
                id w2 = [CCActionScaleTo actionWithDuration:.2 scale:finalWinnerScale*2];
                id w3 = [CCActionScaleTo actionWithDuration:.2 scale:finalWinnerScale];
                id wseq = [CCActionSequence actionWithArray:@[wDelay, w2,w3]];
                [winner runAction:wseq];
                
                wDelay = nil;
                w2 = nil;
                w3 = nil;
                wseq = nil;
                
                float leftScale = 1;
                float rightScale = 1;
                
                CCSprite *fanfareRight = [CCSprite spriteWithImageNamed:@"winnerfanfare.png"];
                fanfareRight.position = ccp(cookieman.position.x+cookieman.boundingBox.size.width/2-33, cookieman.position.y-33);
                fanfareRight.scale = rightScale;
                [self addChild:fanfareRight z:8 name:@"fanfareRight"];
                
                fanfareRight.anchorPoint = ccp(0.0, 0.0);
                fanfareRight.scale = 0;
                
                id frd = [CCActionDelay actionWithDuration:1];
                id fr1 = [CCActionScaleTo actionWithDuration:.2 scale:rightScale];
                id fr2 = [CCActionScaleTo actionWithDuration:.2 scale:rightScale-0.1];
                id fr3 = [CCActionScaleTo actionWithDuration:.2 scale:rightScale];
                
                id block = [CCActionCallBlock actionWithBlock:(^{
                    [[OALSimpleAudio sharedInstance] playEffect:@"winner.wav"];
                })];

                id frseq = [CCActionSequence actionWithArray:@[frd,block,fr1,fr2,fr3]];
                [fanfareRight runAction:frseq];
                
                frd = nil;
                fr1 = nil;
                fr2 = nil;
                fr3 = nil;
                block = nil;
                frseq = nil;
                
                CCSprite *fanfareLeft = [CCSprite spriteWithImageNamed:@"winnerfanfare.png"];
                fanfareLeft.scaleX = -leftScale;
                fanfareLeft.scaleY = leftScale;
                fanfareLeft.anchorPoint = ccp(0.0f, 0.0f);
                fanfareLeft.position = ccp(cookieman.position.x-cookieman.boundingBox.size.width/2+33, cookieman.position.y-33);
                [self addChild:fanfareLeft z:8 name:@"fanfareLeft"];
                fanfareLeft.scale = 0;
                
                id fld = [CCActionDelay actionWithDuration:1];
                id fl1 = [CCActionScaleTo actionWithDuration:.2 scaleX:-leftScale scaleY:leftScale];
                id fl2 = [CCActionScaleTo actionWithDuration:.2 scaleX:-leftScale+0.1 scaleY:leftScale-0.1];
                id fl3 = [CCActionScaleTo actionWithDuration:.2 scaleX:-leftScale scaleY:leftScale];
                id flseq = [CCActionSequence actionWithArray:@[fld,fl1,fl2,fl3]];
                [fanfareLeft runAction:flseq];
                
                fld = nil;
                fl1 = nil;
                fl2 = nil;
                flseq = nil;
                
                float horseScale = 1.0f;
                
                CCSprite *horseRight = [CCSprite spriteWithImageNamed:@"horse.png"];
                horseRight.scale = horseScale;
                horseRight.anchorPoint = ccp(0.0f, 0.0f);
                horseRight.position = ccp(cookieman.position.x+39, cookieman.position.y+24);
                [self addChild:horseRight z:6 name:@"horseRight"];
                
                CCSprite *horseLeft = [CCSprite spriteWithImageNamed:@"horse.png"];
                horseLeft.scale = horseScale;
                horseLeft.scaleX = -horseLeft.scaleX;
                horseLeft.anchorPoint = ccp(0.0f, 0.0f);
                horseLeft.position = ccp(cookieman.position.x-39, cookieman.position.y+24);
                [self addChild:horseLeft z:6 name:@"horseLeft"];
                
                horseRight.rotation = -90;
                horseRight.scale = 0;
                
                id horseRightBlock = [CCActionCallBlock actionWithBlock:(^{
                    [horseRight runAction:[CCActionRotateTo actionWithDuration:.3 angle:9]];
                    [horseRight runAction:[CCActionScaleTo actionWithDuration:.3 scaleX:horseScale scaleY:horseScale]];
                })];
                
                [horseRight runAction:[CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:1],horseRightBlock]]];
                
                horseLeft.rotation = 90;
                horseLeft.scale = 0;
                
                id horseLeftBlock = [CCActionCallBlock actionWithBlock:(^{
                    [horseLeft runAction:[CCActionRotateTo actionWithDuration:.3 angle:-9]];
                    [horseLeft runAction:[CCActionScaleTo actionWithDuration:.3 scaleX:-horseScale scaleY:horseScale]];
                })];
                
                [horseLeft runAction:[CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:1],horseLeftBlock]]];
                
                horseRight = nil;
                horseLeft = nil;
                horseRightBlock = nil;
                horseLeftBlock = nil;
                
                CCSprite *cookiecount = [CCSprite spriteWithImageNamed:@"cookiecount.png"];
                cookiecount.anchorPoint = ccp(0.5f, 0.0f);
                cookiecount.scale = countScale;
                cookiecount.position = ccp(cookieman.position.x, cookieman.position.y+cookieman.boundingBox.size.height+5);
                [self addChild:cookiecount z:10 name:@"cookiecount"];
                
                CCLabelTTF *cookieCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@" %d ",cookieCount] fontName:font fontSize:countFont];
                cookieCountLabel.color = [CCColor whiteColor];
                cookieCountLabel.outlineColor = [CCColor blackColor];
                cookieCountLabel.outlineWidth = countOutline;
                cookieCountLabel.positionType = CCPositionTypeNormalized;
                cookieCountLabel.position = ccp(0.5f, 0.55f);
                [cookiecount addChild:cookieCountLabel z:10 name:@"cookieCountLabel"];
                
                CGPoint ccFinalPost = cookiecount.position;
                
                cookiecount.position = ccp(self.contentSize.width/2, self.contentSize.height+cookiecount.boundingBox.size.height);
                
                
                id cc1 = [CCActionEaseBounceOut actionWithAction:(CCActionInterval*)[CCActionMoveTo actionWithDuration:.5 position:ccFinalPost]];
                id cc2 = [CCActionCallBlock actionWithBlock:(^{
                    isRestartShown = 1;
                })];
                id ccd = [CCActionDelay actionWithDuration:1];
                
                [cookiecount runAction:[CCActionSequence actionWithArray:@[ccd, cc1, cc2]]];
                
                cc1 = nil;
                cc2 = nil;
                ccd = nil;
                cookiecount = nil;
                
            }
        }
    }
    
    if(isRestartShown == 1) {
        
        if([self getChildByName:@"winner" recursively:NO] != nil) {
            
            CCSprite *cc = (CCSprite*)[self getChildByName:@"winner" recursively:NO];
            
            if(CGRectContainsPoint(CGRectMake(cc.position.x-cc.boundingBox.size.width/2, cc.position.y-restart.boundingBox.size.height/2, cc.boundingBox.size.width, cc.boundingBox.size.height), touchLocation)) {
                
                if(touchLocation.x > self.contentSize.width*.60) {
                    [self restartGame];
                }
                if(touchLocation.x < self.contentSize.width*.40) {
                    [self exitGame];
                }
            }
            
            cc = nil;
            
        }
    }
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    isPressingArrow = 0;
    
}

-(void) scrollClouds {
    
    CGPoint pos1 = backclouds1.position;
    CGPoint pos2 = backclouds2.position;
    
    CGSize size1 = backclouds1.boundingBox.size;
    CGSize size2 = backclouds2.boundingBox.size;
    
    CGPoint scrollVel = ccp(-2, 0);
    
    scrollVel = ccpMult(scrollVel, 1.5);
    
    pos1 = ccpAdd(pos1, ccpMult(scrollVel, dtGlobal));
    pos2 = ccpAdd(pos2, ccpMult(scrollVel, dtGlobal));

    if(pos1.x <= 0) {
        pos1.x = pos2.x + size1.width;
    }
    if(pos2.x <= 0) {
        pos2.x = pos1.x + size2.width;
    }

    backclouds1.position = pos1;
    backclouds2.position = pos2;
    
}

-(void) scrollAll {

    CGPoint farScrollVel = ccp(-22, 0);
    CGPoint closeScrollVel = ccp(-45, 0);
    CGPoint floorScrollVel = ccp(-90, 0);
    CGPoint cookieScrollVel = floorScrollVel;
    
    farScrollVel = ccpMult(farScrollVel, 1.5);
    closeScrollVel = ccpMult(closeScrollVel, 1.5);
    floorScrollVel = ccpMult(floorScrollVel, 1.5);
    cookieScrollVel = floorScrollVel;
    
    CGPoint pos1;
    CGPoint pos2;
    CGSize size1;
    CGSize size2;
    CGPoint scrollVel;
    
    
    // Move far hills
    pos1 = backfarhills1.position;
    pos2 = backfarhills2.position;
    size1 = backfarhills1.boundingBox.size;
    size2 = backfarhills2.boundingBox.size;
    scrollVel = farScrollVel;
    
    pos1 = ccpAdd(pos1, ccpMult(scrollVel, dtGlobal));
    pos2 = ccpAdd(pos2, ccpMult(scrollVel, dtGlobal));
    
    if(pos1.x <= 0) {
        pos1.x = pos2.x + size1.width;
    }
    if(pos2.x <= 0) {
        pos2.x = pos1.x + size2.width;
    }
    
    backfarhills1.position = pos1;
    backfarhills2.position = pos2;
    
    
    // Move close hills
    pos1 = backclosehills1.position;
    pos2 = backclosehills2.position;
    size1 = backclosehills1.boundingBox.size;
    size2 = backclosehills2.boundingBox.size;
    scrollVel = closeScrollVel;
    
    pos1 = ccpAdd(pos1, ccpMult(scrollVel, dtGlobal));
    pos2 = ccpAdd(pos2, ccpMult(scrollVel, dtGlobal));
    
    if(pos1.x <= 0) {
        pos1.x = pos2.x + size1.width;
    }
    if(pos2.x <= 0) {
        pos2.x = pos1.x + size2.width;
    }
    
    backclosehills1.position = pos1;
    backclosehills2.position = pos2;
    
    // Move floor
    pos1 = backfloor1.position;
    pos2 = backfloor2.position;
    size1 = backfloor1.boundingBox.size;
    size2 = backfloor2.boundingBox.size;
    scrollVel = floorScrollVel;
    
    pos1 = ccpAdd(pos1, ccpMult(scrollVel, dtGlobal));
    pos2 = ccpAdd(pos2, ccpMult(scrollVel, dtGlobal));
    
    if(pos1.x <= 0) {
        pos1.x = pos2.x + size1.width;
        [self changeFlowerPosition:flower1];
        [self changeFlowerPosition:flower2];
        [self changeFlowerPosition:flower3];
    }
    if(pos2.x <= 0) {
        pos2.x = pos1.x + size2.width;
        [self changeFlowerPosition:flower4];
        [self changeFlowerPosition:flower5];
        [self changeFlowerPosition:flower6];
    }
    
    backfloor1.position = pos1;
    backfloor2.position = pos2;
    
    // Move cookie
    pos1 = cookie.position;
    scrollVel = cookieScrollVel;
    
    pos1 = ccpAdd(pos1, ccpMult(scrollVel, dtGlobal));
    
    cookie.position = pos1;

    
}


-(void) restartGame {
    
    [cookieman stopAllActions];
    [cookieman runAction:idleAction];
    actionState = kActionStateIdle;
    
    isEatingCookie = 0;
    isRestartShown = 0;
    
    [cookie stopAllActions];
    
    [self removeChildByName:@"winner" cleanup:YES];
    [self removeChildByName:@"horseRight" cleanup:YES];
    [self removeChildByName:@"horseLeft" cleanup:YES];
    [self removeChildByName:@"fanfareRight" cleanup:YES];
    [self removeChildByName:@"fanfareLeft" cleanup:YES];
    [self removeChildByName:@"cookiecount" cleanup:YES];
    
    distanceOfCookie = [self returnCookieLocation];

    cookie.position = ccp(cookieman.position.x+cookieman.boundingBox.size.width/2+distanceOfCookie-10, cookieman.position.y+cookieman.boundingBox.size.height/2);
    
    cookie.visible = YES;
    button.visible = YES;
    arrow.visible = YES;
    
}

-(void) exitGame {
    
    button = nil;
    arrow = nil;
    backclouds1 = nil;
    backclouds2 = nil;
    backfarhills1 = nil;
    backfarhills2 = nil;
    backclosehills1 = nil;
    backclosehills2 = nil;
    backfloor1 = nil;
    backfloor2 = nil;
    flower1 = nil;
    flower2 = nil;
    flower3 = nil;
    flower4 = nil;
    flower5 = nil;
    flower6 = nil;
    cookie = nil;
    idleAction = nil;
    moveAction = nil;
    blinkAction = nil;
    cookieAction = nil;
    grabAndBiteAction = nil;
    chewAction = nil;
    actionState = nil;
    cookieman = nil;
    font = nil;
    restart = nil;
    defaults = nil;
    
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene] withTransition:[CCTransition transitionFadeWithDuration:1]];
    [self unscheduleAllSelectors];
    [self stopAllActions];
    [self removeAllChildrenWithCleanup:YES];
}

@end
