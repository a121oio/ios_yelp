//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "businessCell.h"
#import "FilterViewController.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate,FiltersViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) UISearchBar *vb;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic,strong) NSArray *businesses;

-(void) fetchBusinessWithQuery:(NSString *)query params: (NSDictionary *) params;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self fetchBusinessWithQuery:@"Restaurants" params:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.myTableView  registerNib:[UINib nibWithNibName:@"businessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    self.title = @"Yelp";
 
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationController.navigationBar.translucent = NO;
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    self.vb = [[UISearchBar alloc]init];
    self.vb.text = @"steak";
    self.navigationItem.titleView = self.vb;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section   {
    return self.businesses.count;
    
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    businessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;
    
    
}

-(void) onFilterButton {
    FilterViewController  *vc = [[FilterViewController alloc] init];
    
    
    vc.delegate = self;
    
    UINavigationController *nvc = [[ UINavigationController alloc]initWithRootViewController:vc];
    
    [self presentViewController:nvc animated:YES completion:nil];
    
}

-(void) fetchBusinessWithQuery:(NSString *)query params:(NSDictionary *)params{
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
        NSArray *businessDictionary = response[@"businesses"];
        
        self.businesses = [Business businessesWithDictionaries:businessDictionary];
        [self.myTableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
        
    }];
    
}
#pragma mark - Filter delegate methods

-(void) filtersViewController:(FilterViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters   {
    NSString * re = filters[@"category_filter"] ;
    re = [re stringByAppendingString:@","];
    re = [re stringByAppendingString: self.vb.text];
    
    [filters setValue:re forKey:@"category_filter"];
    
    [self fetchBusinessWithQuery:@"Restaurants" params:filters];
    
    NSLog(@"fire new network event %@",filters);
    
}


@end
