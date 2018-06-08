//
//  ViewController.m
//  RunloopAddBigImage
//
//  Created by lemo on 2018/6/8.
//  Copyright © 2018年 wangli. All rights reserved.
//

#import "ViewController.h"

typedef void(^RunloopBlock)(void);

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSMutableArray *tasks;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tasks = [NSMutableArray array];
    
    [NSTimer scheduledTimerWithTimeInterval:0.00001 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    

    _identifier = @"TableViewCell";

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    //1, xib创建cell
//    [_tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:_identifier];
    [self.view addSubview:_tableView];
    
    [self addRunloopObserver];
}

- (void)timerMethod {
   //啥都不做
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    //2, 用代码添加有明显的卡顿
//    [self addImage1:cell];
//    [self addImage2:cell];
//    [self addImage3:cell];
    
    //3, runloop 优化
    [self addtask:^{
        [self addImage1:cell];
    }];
    [self addtask:^{
        [self addImage2:cell];
    }];
    [self addtask:^{
        [self addImage3:cell];
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1010;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)addtask:(RunloopBlock)block {
    [self.tasks addObject:block];
    // 4,self.tasks.count之前的判断是大于一屏能放的图片数量,这会导致第一屏不显示,如果增加到两倍多几个就可以正常显示
    if (self.tasks.count > 54) {
        [self.tasks removeObjectAtIndex:0];
    }
}

- (void)addRunloopObserver {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    static CFRunLoopObserverRef runloopObserver;
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)self,
        &CFRetain,
        &CFRelease,
        NULL
    };
    
    runloopObserver = CFRunLoopObserverCreate(NULL,
                                              kCFRunLoopBeforeWaiting,
                                              YES,
                                              0,
                                              &callBack,
                                              &context);
    CFRunLoopAddObserver(runloop,
                         runloopObserver,
                         kCFRunLoopDefaultMode);
    CFRelease(runloopObserver);
}

static void callBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    ViewController *vc = (__bridge ViewController *)info;
    if (vc.tasks.count) {
        RunloopBlock block = vc.tasks.firstObject;
        block();
        [vc.tasks removeObjectAtIndex:0];
        
    }
    
}
- (void)addImage1:(UITableViewCell *)cell {
    UIImage *image = [UIImage imageNamed:@"spaceship.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 0, 100, 80);
    [cell addSubview:imageView];
}

- (void)addImage2:(UITableViewCell *)cell {
    UIImage *image = [UIImage imageNamed:@"spaceship.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(110, 0, 100, 80);
    [cell addSubview:imageView];

}

- (void)addImage3:(UITableViewCell *)cell {
    UIImage *image = [UIImage imageNamed:@"spaceship.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(220, 0, 100, 80);
    [cell addSubview:imageView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
