//
//  FilterViewController.m
//  Yelp
//
//  Created by Weiyan Lin on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FilterViewController.h"
#import "SwitchCell.h"

@interface FilterViewController ()<UITableViewDataSource,UITableViewDelegate,SwitchCellDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,strong) NSMutableDictionary *filters;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic,strong) NSArray *distanceOptions;
@property (nonatomic,strong) NSArray *sortOptions;

@property (nonatomic, strong) NSMutableDictionary *expanded;
@property (nonatomic, strong) NSMutableArray *categorySelection;
@property (nonatomic,strong) NSArray *filtersOption;



-(void) initCategories;
-(void) initDistance;
-(void) initSort;

@end

@implementation FilterViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil   {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        
        
        [self initCategories];
        [self initSort];
        [self initDistance];
        
        self.title = @"Filter";
        self.filtersOption = @[@{@"title":@"Most Popular",
                           @"data": @[@{@"name":@"Offering a Deal", @"key": @"deals_filter"}],
                           @"type": @"toggle"
                           },
                         @{@"title": @"Distance",
                           @"data": self.distanceOptions,
                           @"type": @"single",
                           @"key": @"radius_filter"
                           },
                         @{@"title": @"Sort by",
                           @"data": self.sortOptions,
                           @"type": @"single",
                           @"key": @"sort"
                           },
                         @{@"title": @"Categories",
                           @"data": self.categories,
                           @"type": @"multiple",
                           @"key": @"category_filter"
                           }
                         ];
        self.expanded = [[NSMutableDictionary alloc] init];
        self.categorySelection = [[NSMutableArray alloc] init];
        self.filters = [[NSMutableDictionary alloc] init];
    }
    return self;
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    if (self.filters == nil) {
        self.filters = [NSMutableDictionary dictionary];
    }
    
    if ([self.filters objectForKey:@"category_filter"] != nil) {
        NSString *commaSeparated = [self.filters objectForKey:@"category_filter"];
        NSArray *array = [commaSeparated componentsSeparatedByString:@","];
        self.categorySelection = [NSMutableArray arrayWithArray:array];
    }
    
    [self.tableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(cancel)];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Apply"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(onApplyButton)];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = searchButton;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib: [UINib nibWithNibName:@"SwitchCell" bundle:nil]
         forCellReuseIdentifier:@"SwitchCell"];
    
    
    
}

//- (void)search {
//    // Clean up filter values here:
//    // - Pass in a comma separated list of `category_filter`
//    // - Remove `radius_filter` if its value is `auto`
//    [self.categorySelection removeObject:@""];
//    self.filters[@"category_filter"] = [self.categorySelection componentsJoinedByString:@","];
//    if ([self.filters[@"radius_filter"] isEqual:@"auto"]) {
//        [self.filters removeObjectForKey:@"radius_filter"];
//    }
//    
//    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
//    [store setObject:self.filters forKey:@"savedFilters"];
//    [store synchronize];
//    
//    if([self.tableView.delegate respondsToSelector:@selector(filterSelectionDone:)]) {
//        [self.tableView.delegate filterSelectionDone:self.filters];
//    }
//    
//    [self dismissViewControllerAnimated:YES completion:nil];
//}


- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - tableView methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filtersOption.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *filterGroup = self.filtersOption[section];
    if ([self.expanded[@(section)] boolValue]) {
        return ((NSArray *)self.filtersOption[section][@"data"]).count;
    } else if ([filterGroup[@"type"] isEqual: @"multiple"]) {
        return 5;
    } else {
        return 1;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // Display group text
    UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 300, 35)];
    sectionTitle.text = [self.filtersOption[section][@"title"] uppercaseString];
    sectionTitle.font = [sectionTitle.font fontWithSize:13];
    sectionTitle.textColor = [UIColor darkGrayColor];
    UIView *view = [[UIView alloc] init];
    [view addSubview:sectionTitle];
    
    return view;
}




//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
//    cell.titleLabel.text = self.categories[indexPath.row][@"name"];
//    
//    cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
//    
//    cell.delegate = self;
//    
//    return cell;
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    
    BOOL sectionExpanded = [self.expanded[@(indexPath.section)] boolValue];
    
    NSDictionary *filterGroup = self.filtersOption[indexPath.section];
    NSArray *filterOptions = filterGroup[@"data"];
    NSDictionary *currentRowOption = filterOptions[indexPath.row];
    
    cell.textLabel.text = currentRowOption[@"name"];
    
    if ([filterGroup[@"type"] isEqual: @"toggle"]) {
        // Show toggle button
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        BOOL selected = [self.filters objectForKey:currentRowOption[@"key"]] != nil;
        [switchView setOn:selected animated:NO];
        [switchView addTarget:self
                       action:@selector(toggleChanged:)
             forControlEvents:UIControlEventValueChanged];
    } else if ([filterGroup[@"type"] isEqual: @"multiple"]) {
        // Show checkbox; pretend category is the only multiple option
        if ([self.categorySelection containsObject:currentRowOption[@"value"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (!sectionExpanded && indexPath.row == 4) {
            cell.textLabel.text = @"See All";
        }
    } else if ([filterGroup[@"type"] isEqual: @"single"]) {
        NSString *selectedValue = [self.filters objectForKey:filterGroup[@"key"]];
        if (sectionExpanded) {
            if ([selectedValue isEqual:currentRowOption[@"value"]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            cell.textLabel.text = [self findNameInDictionary:filterOptions withValue:selectedValue];
        }
    }
    return cell;
}

- (void)toggleChanged:(id)sender {
    BOOL state = [sender isOn];
    if (state) {
        // This works only because there's only one toggle filter.
        // Generalize this later.
        self.filters[@"deals_filter"] = @"true";
    } else {
        [self.filters removeObjectForKey:@"deals_filter"];
    }
}

- (id)findNameInDictionary:(NSArray *)array withValue:(NSString *)value {
    id match = array[0][@"name"];
    for (NSDictionary *item in array) {
        if ([item[@"value"] isEqual:value]) {
            match = item[@"name"];
            break;
        }
    }
    return match;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *filterGroup = self.filtersOption[indexPath.section];
    NSArray *filterOptions = filterGroup[@"data"];
    NSDictionary *currentRowOption = filterOptions[indexPath.row];
    
    BOOL sectionExpanded = [self.expanded[@(indexPath.section)] boolValue];
    BOOL disableCollapse = sectionExpanded && [filterGroup[@"type"] isEqual: @"multiple"];
    
    // Record selection only when it's already expanded
    if (sectionExpanded) {
        if ([filterGroup[@"type"] isEqual: @"single"]) {
            [self.filters setObject: currentRowOption[@"value"] forKey:filterGroup[@"key"]];
        } else if ([filterGroup[@"type"] isEqual: @"multiple"]) {
            if ([self.categorySelection containsObject:currentRowOption[@"code"]]) {
                [self.categorySelection removeObject:currentRowOption[@"code"]];

            } else {
                [self.categorySelection addObject:currentRowOption[@"code"]];
            }
        }
    }
    
    if (!disableCollapse) {
        self.expanded[@(indexPath.section)] = @(!sectionExpanded);
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}



#pragma mark - Switch cell delegate methods
-(void) switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (value) {
        [self.selectedCategories addObject:self.categories[indexPath.row]];
    } else {
        [self.selectedCategories removeObject:self.categories[indexPath.row]];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//-(NSDictionary *) filters{
//    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
//    if (self.selectedCategories.count > 0){
//        NSMutableArray *names = [NSMutableArray array];
//        for (NSDictionary *category in self.selectedCategories){
//            [names addObject:category[@"code"]];
//            
//        }
//        NSString *categoryFilter = [names componentsJoinedByString:@","];
//        [filters setObject:categoryFilter forKey:@"category_filter"];
//        
//    }
//    
//    return filters;
//}

- (void) onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) onApplyButton{
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    if (self.categorySelection.count > 0){
        NSMutableArray *names = [NSMutableArray array];
        for (NSString *category in self.categorySelection){
            [names addObject:category];
    
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
            
    }

    [self.delegate filtersViewController:self didChangeFilters:filters];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) initDistance{
    self.distanceOptions = @[
                             @{@"name": @"Auto", @"value": @"auto"},
                             @{@"name": @"1 mile", @"value": @"1"},
                             @{@"name": @"5 miles", @"value": @"5"},
                             @{@"name": @"10 miles", @"value":@"10" },
                             @{@"name": @"20 miles", @"value":@"20" }
                             ];
    
};

-(void) initSort{
    self.sortOptions = @[
                         @{@"name": @"Best match", @"value": @"0"},
                         @{@"name": @"Distance", @"value": @"1"},
                         @{@"name": @"Highest rated", @"value": @"2"}
                         ];
};

-(void) initCategories{
    self.categories =@[
  @{@"name" : @"French", @"code": @"french" },
  @{@"name" : @"Caribbean", @"code": @"caribbean" },
  @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
  @{@"name" : @"Chinese", @"code": @"chinese" },
  @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
  @{@"name" : @"Afghan", @"code": @"afghani" },
  @{@"name" : @"African", @"code": @"african" },
  @{@"name" : @"American, New", @"code": @"newamerican" },
  @{@"name" : @"Arabian", @"code": @"arabian" },
  @{@"name" : @"Argentine", @"code": @"argentine" },
  @{@"name" : @"Armenian", @"code": @"armenian" },
  @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
  @{@"name" : @"Asturian", @"code": @"asturian" },
  @{@"name" : @"Australian", @"code": @"australian" },
  @{@"name" : @"Austrian", @"code": @"austrian" },
  @{@"name" : @"Baguettes", @"code": @"baguettes" },
  @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
  @{@"name" : @"Barbeque", @"code": @"bbq" },
  @{@"name" : @"Basque", @"code": @"basque" },
  @{@"name" : @"Bavarian", @"code": @"bavarian" },
  @{@"name" : @"Beer Garden", @"code": @"beergarden" },
  @{@"name" : @"Beer Hall", @"code": @"beerhall" },
  @{@"name" : @"Beisl", @"code": @"beisl" },
  @{@"name" : @"Belgian", @"code": @"belgian" },
  @{@"name" : @"Bistros", @"code": @"bistros" },
  @{@"name" : @"Black Sea", @"code": @"blacksea" },
  @{@"name" : @"Brasseries", @"code": @"brasseries" },
  @{@"name" : @"Brazilian", @"code": @"brazilian" },
  @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
  @{@"name" : @"British", @"code": @"british" },
  @{@"name" : @"Buffets", @"code": @"buffets" },
  @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
  @{@"name" : @"Burgers", @"code": @"burgers" },
  @{@"name" : @"Burmese", @"code": @"burmese" },
  @{@"name" : @"Cafes", @"code": @"cafes" },
  @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
  @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
  @{@"name" : @"Cambodian", @"code": @"cambodian" },
  @{@"name" : @"Canadian", @"code": @"New)" },
  @{@"name" : @"Canteen", @"code": @"canteen" },
  @{@"name" : @"Catalan", @"code": @"catalan" },
  @{@"name" : @"Chech", @"code": @"chech" },
  @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
  @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
  @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
  @{@"name" : @"Chilean", @"code": @"chilean" },
  @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
  @{@"name" : @"Corsican", @"code": @"corsican" },
  @{@"name" : @"Creperies", @"code": @"creperies" },
  @{@"name" : @"Cuban", @"code": @"cuban" },
  @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
  @{@"name" : @"Cypriot", @"code": @"cypriot" },
  @{@"name" : @"Czech", @"code": @"czech" },
  @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
  @{@"name" : @"Danish", @"code": @"danish" },
  @{@"name" : @"Delis", @"code": @"delis" },
  @{@"name" : @"Diners", @"code": @"diners" },
  @{@"name" : @"Dumplings", @"code": @"dumplings" },
  @{@"name" : @"Eastern European", @"code": @"eastern_european" },
  @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
  @{@"name" : @"Fast Food", @"code": @"hotdogs" },
  @{@"name" : @"Filipino", @"code": @"filipino" },
  @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
  @{@"name" : @"Fondue", @"code": @"fondue" },
  @{@"name" : @"Food Court", @"code": @"food_court" },
  @{@"name" : @"Food Stands", @"code": @"foodstands" },
  @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
  @{@"name" : @"Galician", @"code": @"galician" },
  @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
  @{@"name" : @"Georgian", @"code": @"georgian" },
  @{@"name" : @"German", @"code": @"german" },
  @{@"name" : @"Giblets", @"code": @"giblets" },
  @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
  @{@"name" : @"Greek", @"code": @"greek" },
  @{@"name" : @"Halal", @"code": @"halal" },
  @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
  @{@"name" : @"Heuriger", @"code": @"heuriger" },
  @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
  @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
  @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
  @{@"name" : @"Hot Pot", @"code": @"hotpot" },
  @{@"name" : @"Hungarian", @"code": @"hungarian" },
  @{@"name" : @"Iberian", @"code": @"iberian" },
  @{@"name" : @"Indian", @"code": @"indpak" },
  @{@"name" : @"Indonesian", @"code": @"indonesian" },
  @{@"name" : @"International", @"code": @"international" },
  @{@"name" : @"Irish", @"code": @"irish" },
  @{@"name" : @"Island Pub", @"code": @"island_pub" },
  @{@"name" : @"Israeli", @"code": @"israeli" },
  @{@"name" : @"Italian", @"code": @"italian" },
  @{@"name" : @"Japanese", @"code": @"japanese" },
  @{@"name" : @"Jewish", @"code": @"jewish" },
  @{@"name" : @"Kebab", @"code": @"kebab" },
  @{@"name" : @"Korean", @"code": @"korean" },
  @{@"name" : @"Kosher", @"code": @"kosher" },
  @{@"name" : @"Kurdish", @"code": @"kurdish" },
  @{@"name" : @"Laos", @"code": @"laos" },
  @{@"name" : @"Laotian", @"code": @"laotian" },
  @{@"name" : @"Latin American", @"code": @"latin" },
  @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
  @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
  @{@"name" : @"Malaysian", @"code": @"malaysian" },
  @{@"name" : @"Meatballs", @"code": @"meatballs" },
  @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
  @{@"name" : @"Mexican", @"code": @"mexican" },
  @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
  @{@"name" : @"Milk Bars", @"code": @"milkbars" },
  @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
  @{@"name" : @"Modern European", @"code": @"modern_european" },
  @{@"name" : @"Mongolian", @"code": @"mongolian" },
  @{@"name" : @"Moroccan", @"code": @"moroccan" },
  @{@"name" : @"New Zealand", @"code": @"newzealand" },
  @{@"name" : @"Night Food", @"code": @"nightfood" },
  @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
  @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
  @{@"name" : @"Oriental", @"code": @"oriental" },
  @{@"name" : @"Pakistani", @"code": @"pakistani" },
  @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
  @{@"name" : @"Parma", @"code": @"parma" },
  @{@"name" : @"Persian/Iranian", @"code": @"persian" },
  @{@"name" : @"Peruvian", @"code": @"peruvian" },
  @{@"name" : @"Pita", @"code": @"pita" },
  @{@"name" : @"Pizza", @"code": @"pizza" },
  @{@"name" : @"Polish", @"code": @"polish" },
  @{@"name" : @"Portuguese", @"code": @"portuguese" },
  @{@"name" : @"Potatoes", @"code": @"potatoes" },
  @{@"name" : @"Poutineries", @"code": @"poutineries" },
  @{@"name" : @"Pub Food", @"code": @"pubfood" },
  @{@"name" : @"Rice", @"code": @"riceshop" },
  @{@"name" : @"Romanian", @"code": @"romanian" },
  @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
  @{@"name" : @"Rumanian", @"code": @"rumanian" },
  @{@"name" : @"Russian", @"code": @"russian" },
  @{@"name" : @"Salad", @"code": @"salad" },
  @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
  @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
  @{@"name" : @"Scottish", @"code": @"scottish" },
  @{@"name" : @"Seafood", @"code": @"seafood" },
  @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
  @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
  @{@"name" : @"Singaporean", @"code": @"singaporean" },
  @{@"name" : @"Slovakian", @"code": @"slovakian" },
  @{@"name" : @"Soul Food", @"code": @"soulfood" },
  @{@"name" : @"Soup", @"code": @"soup" },
  @{@"name" : @"Southern", @"code": @"southern" },
  @{@"name" : @"Spanish", @"code": @"spanish" },
  @{@"name" : @"Steakhouses", @"code": @"steak" },
  @{@"name" : @"Sushi Bars", @"code": @"sushi" },
  @{@"name" : @"Swabian", @"code": @"swabian" },
  @{@"name" : @"Swedish", @"code": @"swedish" },
  @{@"name" : @"Swiss Food", @"code": @"swissfood" },
  @{@"name" : @"Tabernas", @"code": @"tabernas" },
  @{@"name" : @"Tapas Bars", @"code": @"tapas" },
  @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
  @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
  @{@"name" : @"Thai", @"code": @"thai" },
  @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
  @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
  @{@"name" : @"Trattorie", @"code": @"trattorie" },
  @{@"name" : @"Turkish", @"code": @"turkish" },
  @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
  @{@"name" : @"Uzbek", @"code": @"uzbek" },
  @{@"name" : @"Vegan", @"code": @"vegan" },
  @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
  @{@"name" : @"Venison", @"code": @"venison" },
  @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
  @{@"name" : @"Wok", @"code": @"wok" },
  @{@"name" : @"Wraps", @"code": @"wraps" },
  @{@"name" : @"Yugoslav", @"code": @"yugoslav" }];
    
    
}

@end
