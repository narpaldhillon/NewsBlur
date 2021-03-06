//
//  NewsBlurAppDelegate.h
//  NewsBlur
//
//  Created by Samuel Clay on 6/16/10.
//  Copyright NewsBlur 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsBlurViewController;
@class FeedDetailViewController;
@class StoryDetailViewController;
@class LoginViewController;
@class LogoutDelegate;
@class OriginalStoryViewController;

@interface NewsBlurAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    NewsBlurViewController *feedsViewController;
    FeedDetailViewController *feedDetailViewController;
    StoryDetailViewController *storyDetailViewController;
    LoginViewController *loginViewController;
    LogoutDelegate *logoutDelegate;
    OriginalStoryViewController *originalStoryViewController;
    
    NSString * activeUsername;
    NSDictionary * activeFeed;
    NSArray * activeFeedStories;
    NSDictionary * activeStory;
    NSURL * activeOriginalStoryURL;
    int storyCount;
    NSMutableArray * recentlyReadStories;
    NSIndexPath * activeFeedIndexPath;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet NewsBlurViewController *feedsViewController;
@property (nonatomic, retain) IBOutlet FeedDetailViewController *feedDetailViewController;
@property (nonatomic, retain) IBOutlet StoryDetailViewController *storyDetailViewController;
@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;
@property (nonatomic, retain) IBOutlet LogoutDelegate *logoutDelegate;
@property (nonatomic, retain) IBOutlet OriginalStoryViewController *originalStoryViewController;


@property (readwrite, retain) NSString * activeUsername;
@property (readwrite, retain) NSDictionary * activeFeed;
@property (readwrite, retain) NSArray * activeFeedStories;
@property (readwrite, retain) NSDictionary * activeStory;
@property (readwrite, retain) NSURL * activeOriginalStoryURL;
@property (readwrite) int storyCount;
@property (readwrite, retain) NSMutableArray * recentlyReadStories;
@property (readwrite, retain) NSIndexPath * activeFeedIndexPath;

- (void)showLogin;
- (void)loadFeedDetailView;
- (void)loadStoryDetailView;
- (void)reloadFeedsView;
- (void)hideNavigationBar:(BOOL)animated;
- (void)showNavigationBar:(BOOL)animated;
- (void)setTitle:(NSString *)title;
- (void)showOriginalStory:(NSURL *)url;
- (void)closeOriginalStory;
- (int)indexOfNextStory;
- (int)indexOfPreviousStory;
- (int)indexOfActiveStory;
- (void)setStories:(NSArray *)activeFeedStoriesValue;
- (void)addStories:(NSArray *)stories;
- (void)markActiveStoryRead;
- (void)markActiveFeedAllRead;
+ (int)computeStoryScore:(NSDictionary *)intelligence;

@end

