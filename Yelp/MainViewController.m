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

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate,FiltersViewControllerDelegate,UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) UISearchBar *vb;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic,strong) NSArray *businesses;
@property (nonatomic, strong) NSString *searchTerm;


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
    self.searchTerm = @"";
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
    self.navigationController.navigationBar.barTintColor = [[UIColor alloc ]initWithRed:(CGFloat)0.76
                                                                          green:(CGFloat)0.07
                                                                           blue:(CGFloat)0.0
                                                                          alpha:(CGFloat)0.0];
    self.navigationController.navigationBar.translucent = NO;
    
    
    [self setupUI];
   
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.searchTerm = textField.text;
    [self fetchBusinessWithQuery:textField.text  params:nil];
    return YES;
}

- (void)setupUI {
    UITextField *searchField = [[UITextField alloc] initWithFrame:CGRectMake(5.0, 10.0, 200, 28.0)];
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 45.0)];
    searchBarView.autoresizingMask = 0;
    
    searchField.delegate = self;
    searchField.keyboardType = UIKeyboardTypeWebSearch;
    searchField.placeholder = @"Search";
    searchField.text = self.searchTerm;
    searchField.font = [UIFont systemFontOfSize:14];
    searchField.backgroundColor = [UIColor whiteColor];
    searchField.tintColor = [UIColor grayColor];
    searchField.borderStyle = UITextBorderStyleRoundedRect;
    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [searchBarView addSubview:searchField];
    self.navigationItem.titleView = searchBarView;
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Filter"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(onFilterButton)];
    
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Map"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(Map)];
    self.navigationItem.leftBarButtonItem = filterButton;
    self.navigationItem.rightBarButtonItem = mapButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
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
    
    [self fetchBusinessWithQuery:self.searchTerm params:filters];
    
    NSLog(@"fire new network event %@",filters);
    
}


@end
