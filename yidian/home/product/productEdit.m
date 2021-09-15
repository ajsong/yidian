//
//  productEdit.m
//  yidian
//
//  Created by ajsong on 16/1/5.
//  Copyright (c) 2016年 ajsong. All rights reserved.
//

#import "Global.h"
#import "productEdit.h"
#import "MLSelectPhoto.h"
#import "GlobalDelegate.h"
#import "shopCommission.h"
#import "productPicMemo.h"
#import "productGoods.h"

#define IMAGE_WIDTH 50 //小图片宽度
#define MAX_IMAGE_COUNT 9 //最多图片数
#define MAX_SPECS_GROUP 9 //最多规格数

@interface productEdit ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MLSelectPhotoDelegate,AJPickerViewDelegate,GlobalDelegate,SubviewsDragSortDelegate,MJPhotoBrowserDelegate>{
	NSMutableArray *_ms;
	UIScrollView *_scroll;
	AJPickerView *_pickerView;
	
	UIView *_imagesView;
	NSMutableArray *_assets;
	NSMutableArray *_assetsIndex;
	NSMutableArray *_images;
	NSMutableArray *_imageUrls;
	NSMutableArray *_imageMemos;
	
	UITextField *_name;
	SpecialTextField *_packages;
	SpecialTextField *_shipping_fee;
	NSString *_commission_template_id;
	NSString *_type_id;
	SpecialTextView *_description;
	
	UILabel *_commissionLabel;
	UILabel *_typeLabel;
	
	SpecialTextField *_price;
	SpecialTextField *_special_price;
	SpecialTextField *_stocks;
	
	UILabel *_packageLabel;
	NSString *_packages_goods_id;
	NSString *_packages_goods_name;
}
@end

@implementation productEdit

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = _data.isDictionary ? @"编辑商品" : @"发布商品";
	self.view.backgroundColor = BACKCOLOR;
	
	_assets = [[NSMutableArray alloc]init];
	_assetsIndex = [[NSMutableArray alloc]init];
	_images = [[NSMutableArray alloc]init];
	_imageUrls = [[NSMutableArray alloc]init];
	_imageMemos = [[NSMutableArray alloc]init];
	
	_commission_template_id = _data.isDictionary ? _data[@"commission_template_id"] : @"";
	_type_id = _data.isDictionary ? _data[@"type_id"] : @"";
	_packages_goods_id = _data.isDictionary ? _data[@"packages_goods_id"] : @"";
	_packages_goods_name = _data.isDictionary ? _data[@"packages_goods_name"] : @"";
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"提交" textColor:NAVTEXTCOLOR fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
	
	_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.height);
	[self.view addSubview:_scroll];
	
	_pickerView = [[AJPickerView alloc]init];
	_pickerView.delegate = self;
	
	[ProgressHUD show:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadData];
	});
}

#pragma mark - loadData
- (void)loadData{
	_ms = [[NSMutableArray alloc]init];
	[Common getApiWithParams:@{@"app":@"eshop", @"act":@"types"} success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		if ([json[@"data"] isArray]) {
			NSMutableArray *data = [[NSMutableArray alloc]init];
			NSArray *list = json[@"data"];
			for (int i=0; i<list.count; i++) {
				[_ms addObject:list[i]];
				[data addObject:list[i][@"name"]];
			}
			_pickerView.data = data;
		}
		//NSLog(@"%@", _ms);
		[self loadViews];
	} fail:^(NSMutableDictionary *json) {
		[self loadViews];
	}];
}

- (void)loadViews{
	if (!_ms.isArray) {
		[ProgressHUD showError:@"缺少商品分类元数据"];
		return;
	}
	
	[_scroll removeAllSubviews];
	
	UIFont *font = FONT(14);
	
	CGFloat g = floor((SCREEN_WIDTH-IMAGE_WIDTH*5)/6);
	_imagesView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
	_imagesView.backgroundColor = WHITE;
	[_scroll addSubview:_imagesView];
	UIImageView *plus = [[UIImageView alloc]initWithFrame:CGRectMake(g, g, IMAGE_WIDTH, IMAGE_WIDTH)];
	plus.image = IMG(@"p-plus");
	plus.tag = 99;
	[_imagesView addSubview:plus];
	[plus click:^(UIView *view, UIGestureRecognizer *sender) {
		[self selectImage];
	}];
	_imagesView.height = plus.bottom;
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, _imagesView.bottom, SCREEN_WIDTH, 30)];
	view.backgroundColor = WHITE;
	view.element[@"marginTop"] = @0;
	[_scroll addSubview:view];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, view.width-10, view.height)];
	label.text = @"提示：长按图片可排序，点击查看大图与填写描述";
	label.textColor = COLOR999;
	label.font = FONT(11);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+8, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	view.element[@"marginTop"] = @8;
	[_scroll addSubview:view];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
	label.text = @"标题";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_name = [[UITextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-15, view.height)];
	_name.placeholder = @"请输入标题";
	_name.text = _data.isDictionary ? _data[@"name"] : @"";
	_name.textColor = [UIColor blackColor];
	_name.font = font;
	_name.backgroundColor = [UIColor clearColor];
	[view addSubview:_name];
	
	//================================================
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, [_data[@"specs"] isArray] ? 0 : 44*3)];
	view.element[@"marginTop"] = @0;
	view.clipsToBounds = YES;
	view.tag = 89;
	[_scroll addSubview:view];
	
	UIView *row = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	row.backgroundColor = WHITE;
	[view addSubview:row];
	[row addGeWithType:GeLineTypeTop color:BACKCOLOR wide:1];
	[row addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, row.height)];
	label.text = @"价格";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[row addSubview:label];
	_price = [[SpecialTextField alloc]initWithFrame:CGRectMake(label.right, 0, row.width-label.right-15, row.height)];
	_price.placeholder = @"请输入价格";
	_price.text = _data.isDictionary ? _data[@"price"] : @"";
	_price.textColor = [UIColor blackColor];
	_price.font = font;
	_price.backgroundColor = [UIColor clearColor];
	_price.keyboardType = UIKeyboardTypeDecimalPad;
	[row addSubview:_price];
	
	row = [[UIView alloc]initWithFrame:CGRectMake(0, row.bottom, row.width, 44)];
	row.backgroundColor = WHITE;
	[view addSubview:row];
	[row addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"促销价";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[row addSubview:label];
	_special_price = [[SpecialTextField alloc]initWithFrame:_price.frame];
	_special_price.placeholder = @"可选择输入促销价";
	_special_price.text = _data.isDictionary ? _data[@"special_price"] : @"";
	_special_price.textColor = [UIColor blackColor];
	_special_price.font = font;
	_special_price.backgroundColor = [UIColor clearColor];
	_special_price.keyboardType = UIKeyboardTypeDecimalPad;
	[row addSubview:_special_price];
	
	row = [[UIView alloc]initWithFrame:CGRectMake(0, row.bottom, row.width, 44)];
	row.backgroundColor = WHITE;
	[view addSubview:row];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"库存";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[row addSubview:label];
	_stocks = [[SpecialTextField alloc]initWithFrame:_price.frame];
	_stocks.placeholder = @"请输入库存";
	_stocks.text = _data.isDictionary ? _data[@"stocks"] : @"1";
	_stocks.textColor = [UIColor blackColor];
	_stocks.font = font;
	_stocks.backgroundColor = [UIColor clearColor];
	_stocks.keyboardType = UIKeyboardTypeNumberPad;
	[row addSubview:_stocks];
	//================================================
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 0)];
	view.element[@"marginTop"] = @0;
	view.tag = 90;
	view.clipsToBounds = YES;
	[_scroll addSubview:view];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+8, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	view.element[@"marginTop"] = @8;
	[_scroll addSubview:view];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, view.width-15, view.height)];
	label.text = @"＋添加商品规格";
	label.textColor = COLORRGB(@"2b7fd4");
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self addSpecsGroupWithData:nil];
	}];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+8, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	view.element[@"marginTop"] = @8;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
	label.text = @"运费";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_shipping_fee = [[SpecialTextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-15, view.height)];
	_shipping_fee.placeholder = @"请输入运费";
	_shipping_fee.text = _data.isDictionary ? _data[@"shipping_fee"] : @"";
	_shipping_fee.textColor = [UIColor blackColor];
	_shipping_fee.font = font;
	_shipping_fee.backgroundColor = [UIColor clearColor];
	_shipping_fee.keyboardType = UIKeyboardTypeDecimalPad;
	[view addSubview:_shipping_fee];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	view.element[@"marginTop"] = @0;
	[_scroll addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
	label.text = @"商品包装";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	UISwitch *_switch = [[UISwitch alloc]init];
	_switch.on = [_data[@"packages"]intValue]>0;
	_switch.tag = 1000;
	[view addSubview:_switch];
	[_switch addTarget:self action:@selector(togglePackage:) forControlEvents:UIControlEventValueChanged];
	_switch.top = (view.height-_switch.height)/2;
	_switch.left = view.width-_switch.width-15;
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, [_data[@"packages"]intValue]>0?44*2:0)];
	view.backgroundColor = WHITE;
	view.clipsToBounds = YES;
	view.element[@"marginTop"] = @0;
	view.tag = 1001;
	[_scroll addSubview:view];
	
	row = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
	[view addSubview:row];
	[row addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, 44)];
	label.text = @"对应商品";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[row addSubview:label];
	UIImageView *push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
	push.image = IMG(@"push");
	[view addSubview:push];
	_packageLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right, 0, push.left-label.right, label.height)];
	_packageLabel.text = _packages_goods_name;
	_packageLabel.textColor = COLOR666;
	_packageLabel.textAlignment = NSTextAlignmentRight;
	_packageLabel.font = FONT(13);
	_packageLabel.backgroundColor = [UIColor clearColor];
	[row addSubview:_packageLabel];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self backgroundTap];
		productGoods *e = [[productGoods alloc]init];
		e.delegate = self;
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	row = [[UIView alloc]initWithFrame:CGRectMake(0, row.bottom, SCREEN_WIDTH, 44)];
	[view addSubview:row];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, row.height)];
	label.text = @"商品数量";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[row addSubview:label];
	_packages = [[SpecialTextField alloc]initWithFrame:CGRectMake(label.right, 0, view.width-label.right-15, label.height)];
	_packages.placeholder = @"请输入该包装含有的商品数量";
	_packages.text = (_data.isDictionary && [_data[@"packages"]intValue]>0) ? STRING(_data[@"packages"]) : @"";
	_packages.textColor = [UIColor blackColor];
	_packages.font = font;
	_packages.backgroundColor = [UIColor clearColor];
	_packages.keyboardType = UIKeyboardTypeNumberPad;
	[row addSubview:_packages];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+8, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	view.element[@"marginTop"] = @8;
	[_scroll addSubview:view];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
	label.text = @"分利设置";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
	push.image = IMG(@"push");
	[view addSubview:push];
	_commissionLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right, 0, push.left-label.right, view.height)];
	_commissionLabel.text = _data.isDictionary ? _data[@"commission_template_name"] : @"";
	_commissionLabel.textColor = COLOR666;
	_commissionLabel.textAlignment = NSTextAlignmentRight;
	_commissionLabel.font = FONT(13);
	_commissionLabel.backgroundColor = [UIColor clearColor];
	[view addSubview:_commissionLabel];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self backgroundTap];
		shopCommission *e = [[shopCommission alloc]init];
		e.delegate = self;
		[self.navigationController pushViewController:e animated:YES];
	}];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+8, SCREEN_WIDTH, 44)];
	view.backgroundColor = WHITE;
	view.element[@"marginTop"] = @8;
	[_scroll addSubview:view];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, view.height)];
	label.text = @"商品分类";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44, 0, 44, 44)];
	push.image = IMG(@"push");
	[view addSubview:push];
	_typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right, 0, push.left-label.right, view.height)];
	_typeLabel.text = _data.isDictionary ? _data[@"type_name"] : @"";
	_typeLabel.textColor = COLOR666;
	_typeLabel.textAlignment = NSTextAlignmentRight;
	_typeLabel.font = FONT(13);
	_typeLabel.backgroundColor = [UIColor clearColor];
	[view addSubview:_typeLabel];
	[view click:^(UIView *view, UIGestureRecognizer *sender) {
		[self backgroundTap];
		[_pickerView show];
	}];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom+8, SCREEN_WIDTH, 44+100)];
	view.backgroundColor = WHITE;
	view.element[@"marginTop"] = @8;
	[_scroll addSubview:view];
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, 44)];
	label.text = @"商品描述";
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_description = [[SpecialTextView alloc]initWithFrame:CGRectMake(0, label.bottom, SCREEN_WIDTH, 100)];
	_description.placeholder = @"请输入描述";
	_description.text = _data.isDictionary ? _data[@"description"] : @"";
	_description.textColor = [UIColor blackColor];
	_description.font = font;
	_description.backgroundColor = [UIColor clearColor];
	[view addSubview:_description];
	_description.padding = UIEdgeInsetsMake(0, 10, 15, 10);
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(15, view.bottom+10, SCREEN_WIDTH-15*2, 0)];
	label.text = @"注：填写价格请严格遵守法律规定、遵循市场规律，确保可以提供该价格的合法依据或可供比较的出处，不得虚构原价。";
	label.textColor = COLOR999;
	label.font = FONT(12);
	label.backgroundColor = [UIColor clearColor];
	[_scroll addSubview:label];
	[label autoHeight];
	
	_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom+10);
	
	if (_data.isDictionary) {
		if ([_data[@"pics"] isArray]) {
			NSArray *list = _data[@"pics"];
			NSMutableArray *images = [[NSMutableArray alloc]init];
			NSMutableArray *subviews = [[NSMutableArray alloc]init];
			for (int i=0; i<list.count; i++) {
				if (i>=9) break;
				UIView *view = [[UIView alloc]initWithFrame:CGRectMake(g, g, IMAGE_WIDTH, IMAGE_WIDTH)];
				view.tag = 100 + i;
				UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_WIDTH)];
				img.image = IMG(@"nopic");
				img.tag = 10+i;
				[view addSubview:img];
				[img cacheImageWithUrl:list[i][@"pic"] placeholder:nil completion:^(UIImage *image, NSData *imageData, BOOL exist, BOOL isCache) {
					if (exist) {
						image.element[@"first"] = @YES;
						[_images addObject:image];
					} else {
						image = IMG(@"nopic");
						image.element[@"first"] = @YES;
						img.image = IMG(@"nopic");
						[_images addObject:image];
					}
				}];
				UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(view.width-20-2, 2, 20, 20)];
				btn.titleLabel.font = FONT(16);
				btn.backgroundColor = MAINSUBCOLOR;
				[btn setTitle:@"－" forState:UIControlStateNormal];
				[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
				btn.layer.masksToBounds = YES;
				btn.layer.cornerRadius = btn.height/2;
				btn.alpha = 0.8;
				[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
					[self deleteImage:view];
				}];
				[view addSubview:btn];
				[subviews addObject:view];
				[_imageUrls addObject:list[i][@"pic"]];
				[_imageMemos addObject:[list[i][@"memo"]isset]?list[i][@"memo"]:@""];
				
				MJPhoto *photo = [[MJPhoto alloc] init];
				photo.url = list[i][@"pic"];
				photo.content = list[i][@"memo"];
				photo.srcImageView = img;
				[images addObject:photo];
				
				[img click:^(UIView *view, UIGestureRecognizer *sender) {
					MJPhotoBrowser *browser = [[MJPhotoBrowser alloc]init];
					UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
					UIButton *btn = [[UIButton alloc]initWithFrame:btnView.bounds];
					btn.titleLabel.font = FONT(15);
					btn.backgroundColor = [UIColor clearColor];
					[btn setTitle:@"描述" forState:UIControlStateNormal];
					[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
					[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
						productPicMemo *e = [[productPicMemo alloc]init];
						e.data = @{@"memo":photo.content.length?photo.content:@""};
						e.browser = browser;
						e.delegate = self;
						[self.navigationController pushViewController:e animated:YES];
					}];
					[btnView addSubview:btn];
					browser.currentPhotoIndex = img.tag - 10;
					browser.photos = images;
					browser.showInfo = YES;
					browser.btnView = btnView;
					browser.delegate = self;
					//[browser show];
					[self.navigationController pushViewController:browser animated:YES];
				}];
			}
			if (subviews.count<9) {
				UIImageView *plus = [[UIImageView alloc]initWithFrame:CGRectMake(g, g, IMAGE_WIDTH, IMAGE_WIDTH)];
				plus.image = IMG(@"p-plus");
				plus.tag = 99;
				[plus click:^(UIView *view, UIGestureRecognizer *sender) {
					[self selectImage];
				}];
				[subviews addObject:plus];
			}
			[_imagesView removeAllSubviews];
			[_imagesView autoLayoutSubviews:subviews marginPT:g marginPL:g marginPR:0];
			[_imagesView subviewsDragSortWithTarget:self withOut:[_imagesView viewWithTag:99]];
			[self animateNextView:_imagesView height:_imagesView.lastSubview.bottom completion:nil];
		}
		
		if ([_data[@"specs"] isArray]) {
			NSArray *list = _data[@"specs"];
			for (int i=0; i<list.count; i++) {
				[self addSpecsGroupWithData:list[i]];
			}
		}
	}
}

- (void)addSpecsGroupWithData:(NSDictionary*)data{
	[self backgroundTap];
	UIView *view = [_scroll viewWithTag:90];
	if (view.subviews.count >= MAX_SPECS_GROUP) {
		[ProgressHUD showError:STRINGFORMAT(@"最多只能添加%d组规格", MAX_SPECS_GROUP)];
		return;
	}
	
	UIView *view89 = [_scroll viewWithTag:89];
	[self animateNextView:view89 height:0 completion:^{
		UIFont *font = FONT(14);
		
		UIView *subview = [[UIView alloc]initWithFrame:CGRectMake(-SCREEN_WIDTH, view.lastSubview.bottom, SCREEN_WIDTH, 44*4+8)];
		//subview.clipsToBounds = YES;
		subview.element[@"marginTop"] = @0;
		[view addSubview:subview];
		
		UIView *row = [[UIView alloc]initWithFrame:CGRectMake(0, 8, subview.width-26/2-3, 44)];
		row.backgroundColor = WHITE;
		[subview addSubview:row];
		[row addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 85, row.height)];
		label.text = @"规格名称";
		label.textColor = [UIColor blackColor];
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[row addSubview:label];
		SpecialTextField *element = [[SpecialTextField alloc]initWithFrame:CGRectMake(label.right, 0, row.width-label.right-15, row.height)];
		element.placeholder = @"请输入规格名称";
		element.text = data.isDictionary ? data[@"spec"] : @"";
		element.textColor = [UIColor blackColor];
		element.font = font;
		element.backgroundColor = [UIColor clearColor];
		element.tag = 10;
		[row addSubview:element];
		
		row = [[UIView alloc]initWithFrame:CGRectMake(0, row.bottom, row.width, 44)];
		row.backgroundColor = WHITE;
		[subview addSubview:row];
		[row addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"价格";
		label.textColor = [UIColor blackColor];
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[row addSubview:label];
		element = [[SpecialTextField alloc]initWithFrame:element.frame];
		element.placeholder = @"请输入价格";
		element.text = data.isDictionary ? data[@"price"] : @"";
		element.textColor = [UIColor blackColor];
		element.font = font;
		element.backgroundColor = [UIColor clearColor];
		element.keyboardType = UIKeyboardTypeDecimalPad;
		element.tag = 11;
		[row addSubview:element];
		
		row = [[UIView alloc]initWithFrame:CGRectMake(0, row.bottom, row.width, 44)];
		row.backgroundColor = WHITE;
		[subview addSubview:row];
		[row addGeWithType:GeLineTypeBottom color:BACKCOLOR wide:1];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"促销价";
		label.textColor = [UIColor blackColor];
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[row addSubview:label];
		element = [[SpecialTextField alloc]initWithFrame:element.frame];
		element.placeholder = @"可选择输入促销价";
		element.text = data.isDictionary ? data[@"special_price"] : @"";
		element.textColor = [UIColor blackColor];
		element.font = font;
		element.backgroundColor = [UIColor clearColor];
		element.keyboardType = UIKeyboardTypeDecimalPad;
		element.tag = 12;
		[row addSubview:element];
		
		row = [[UIView alloc]initWithFrame:CGRectMake(0, row.bottom, row.width, 44)];
		row.backgroundColor = WHITE;
		[subview addSubview:row];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"库存";
		label.textColor = [UIColor blackColor];
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		[row addSubview:label];
		element = [[SpecialTextField alloc]initWithFrame:element.frame];
		element.placeholder = @"请输入库存";
		element.text = data.isDictionary ? data[@"stocks"] : @"1";
		element.textColor = [UIColor blackColor];
		element.font = font;
		element.backgroundColor = [UIColor clearColor];
		element.keyboardType = UIKeyboardTypeNumberPad;
		element.tag = 13;
		[row addSubview:element];
		
		UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(subview.width-32, 8+(44*4-32)/2, 32, 32)];
		btn.backgroundColor = BACKCOLOR;
		btn.layer.masksToBounds = YES;
		btn.layer.cornerRadius = btn.height/2;
		[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
			UIButton *btn = sender;
			[self deleteSpecsGroup:btn.superview];
		}];
		[subview addSubview:btn];
		label = [[UILabel alloc]initWithFrame:CGRectMake(3, 3, btn.width-6, btn.height-6)];
		label.text = @"－";
		label.textColor = [UIColor whiteColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(16);
		label.backgroundColor = MAINSUBCOLOR;
		label.layer.masksToBounds = YES;
		label.layer.cornerRadius = label.height/2;
		[btn addSubview:label];
		
		[UIView animateWithDuration:0.3 animations:^{
			subview.left = 0;
		}];
		[self animateNextView:view height:subview.bottom completion:nil];
	}];
}

- (void)deleteSpecsGroup:(UIView*)subview{
	UIView *view = [_scroll viewWithTag:90];
	
	[UIView animateWithDuration:0.3 animations:^{
		subview.left = SCREEN_WIDTH;
	}];
	
	[self animateNextView:subview height:0 completion:^{
		[subview removeFromSuperview];
		if (!view.subviews.count) {
			UIView *view89 = [_scroll viewWithTag:89];
			[self animateNextView:view89 height:44*3 completion:nil];
		}
	}];
	[self animateNextView:view height:view.lastSubview.bottom completion:nil];
}

#pragma mark - 显示包装数
- (void)togglePackage:(UISwitch*)sender{
	UIView *view = [_scroll viewWithTag:1001];
	if (sender.on && !view.frame.size.height) {
		[self animateNextView:view height:44*2 completion:nil];
	} else if (!sender.on && view.frame.size.height) {
		[self animateNextView:view height:0 completion:nil];
	}
}

#pragma mark - 选择图片
- (void)selectImage{
	if (_images.count>=MAX_IMAGE_COUNT) {
		[ProgressHUD showError:STRINGFORMAT(@"最多只能选择%d张图片", MAX_IMAGE_COUNT)];
		return;
	}
	UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"您上传的内容将受到监控，如果发现违规，将做下架或关店处理" delegate:self
											 cancelButtonTitle:@"取消"
										destructiveButtonTitle:nil
											 otherButtonTitles:@"从相册选择", @"拍照", nil];
	[sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
	if (buttonIndex==0) {
		[self pickImageFromAlbum];
	} else if (buttonIndex==1) {
		[self pickImageFromCamera];
	} else {
		return;
	}
}

#pragma mark - 从用户相册获取活动图片
- (void)pickImageFromAlbum{
	NSMutableArray *images = [NSMutableArray arrayWithArray:_images];
	NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc]init];
	for (int i=0; i<images.count; i++) {
		UIImage *image = images[i];
		if (![image.element[@"camera"] isset] && ![image.element[@"first"] isset]) {
			[indexSet addIndex:i];
		}
	}
	[images removeObjectsAtIndexes:indexSet];
	
	MLSelectPhotoPickerViewController *picker = [[MLSelectPhotoPickerViewController alloc] init];
	picker.selectPickers = _assets;
	picker.maxCount = 9 - images.count;
	picker.status = PickerViewShowStatusCameraRoll;
	picker.delegate = self;
	[picker showInController:self];
}

- (void)pickerViewControllerDoneAssets:(NSArray *)assets{
	[_assets removeAllObjects];
	[_assetsIndex removeAllObjects];
	
	NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc]init];
	for (int i=0; i<_images.count; i++) {
		UIImage *image = _images[i];
		if (![image.element[@"camera"] isset] && ![image.element[@"first"] isset]) {
			[indexSet addIndex:i];
		}
	}
	[_images removeObjectsAtIndexes:indexSet];
	[_imageUrls removeObjectsAtIndexes:indexSet];
	[_imageMemos removeObjectsAtIndexes:indexSet];
	
	NSMutableArray *images = [[NSMutableArray alloc]init];
	for (int i=0; i<assets.count; i++) {
		if (_images.count>=MAX_IMAGE_COUNT) break;
		MLSelectPhotoAssets *asset = assets[i];
		UIImage *image = asset.originImage;
		image = [image fitToSize:CGSizeMake(800, 800)];
		[_assets addObject:asset];
		[_assetsIndex addObject:image];
		[_images addObject:image];
		
		CGFloat rand = (arc4random() % 89999999) + 10000000;
		NSString *imageName = [NSString stringWithFormat:@"%.f", rand];
		[_imageUrls addObject:imageName];
		[_imageMemos addObject:@""];
		[images addObject:@{@"image":image, @"imageName":imageName}];
	}
	
	for (int i=0; i<images.count; i++) {
		UIImage *image = images[i][@"image"];
		NSString *imageName = images[i][@"imageName"];
		[image.imageQualityMiddle UploadToUpyun:@"uploadfiles/shop/product" imageName:imageName completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
			NSInteger index = [_imageUrls indexOfObject:imageName];
			if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:imageUrl];
		}];
	}
	
	[self addImage];
}

#pragma mark - 从摄像头获取活动图片
- (void)pickImageFromCamera{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	imagePicker.allowsEditing = YES;
	[self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - 获取图片交互
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage]; //UIImagePickerControllerEditedImage
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
		//UIImage *OriginalImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil); //保存到相册
	}
	image = [image fitToSize:CGSizeMake(800, 800)];
	//[Global saveImageToTmp:image withName:@"image.png"];
	[self dismissViewControllerAnimated:YES completion:nil];
	[self uploadImage:image];
}

#pragma mark - 上传图片
- (void)uploadImage:(UIImage*)image{
	image.element[@"camera"] = @YES;
	[_images addObject:image];
	
	CGFloat rand = (arc4random() % 89999999) + 10000000;
	NSString *imageName = [NSString stringWithFormat:@"%.f", rand];
	[_imageUrls addObject:imageName];
	[_imageMemos addObject:@""];
	[image.imageQualityMiddle UploadToUpyun:@"uploadfiles/shop/product" imageName:imageName completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
		NSInteger index = [_imageUrls indexOfObject:imageName];
		if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:imageUrl];
	}];
	
	[self addImage];
}

#pragma mark - 图片操作
- (void)addImage{
	[_imagesView removeAllSubviews];
	if (_images.count) {
		CGFloat g = floor((SCREEN_WIDTH-IMAGE_WIDTH*5)/6);
		NSMutableArray *images = [[NSMutableArray alloc]init];
		NSMutableArray *subviews = [[NSMutableArray alloc]init];
		for (int i=0; i<_images.count; i++) {
			UIView *view = [[UIView alloc]initWithFrame:CGRectMake(g, g, IMAGE_WIDTH, IMAGE_WIDTH)];
			view.tag = 100 + i;
			UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_WIDTH)];
			img.contentMode = UIViewContentModeScaleAspectFill;
			img.clipsToBounds = YES;
			img.image = _images[i];
			img.tag = 10 + i;
			[view addSubview:img];
			UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(view.width-20-2, 2, 20, 20)];
			btn.titleLabel.font = FONT(16);
			btn.backgroundColor = MAINSUBCOLOR;
			[btn setTitle:@"－" forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			btn.layer.masksToBounds = YES;
			btn.layer.cornerRadius = btn.height/2;
			btn.alpha = 0.8;
			[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
				[self deleteImage:view];
			}];
			[view addSubview:btn];
			[subviews addObject:view];
			
			MJPhoto *photo = [[MJPhoto alloc] init];
			photo.image = _images[i];
			photo.srcImageView = img;
			[images addObject:photo];
			
			[img click:^(UIView *view, UIGestureRecognizer *sender) {
				MJPhotoBrowser *browser = [[MJPhotoBrowser alloc]init];
				UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
				UIButton *btn = [[UIButton alloc]initWithFrame:btnView.bounds];
				btn.titleLabel.font = FONT(15);
				btn.backgroundColor = [UIColor clearColor];
				[btn setTitle:@"描述" forState:UIControlStateNormal];
				[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
				//[btn setBackgroundImage:IMG(@"<#NSString#>") forState:UIControlStateNormal];
				[btn addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
					productPicMemo *e = [[productPicMemo alloc]init];
					e.data = @{@"memo":photo.content.length?photo.content:@""};
					e.browser = browser;
					e.delegate = self;
					[self.navigationController pushViewController:e animated:YES];
				}];
				[btnView addSubview:btn];
				browser.currentPhotoIndex = img.tag - 10;
				browser.photos = images;
				browser.showInfo = YES;
				browser.btnView = btnView;
				browser.delegate = self;
				//[browser show];
				[self.navigationController pushViewController:browser animated:YES];
			}];
		}
		
		if (_images.count<9) {
			UIImageView *plus = [[UIImageView alloc]initWithFrame:CGRectMake(g, g, IMAGE_WIDTH, IMAGE_WIDTH)];
			plus.image = IMG(@"p-plus");
			plus.tag = 99;
			[plus click:^(UIView *view, UIGestureRecognizer *sender) {
				[self selectImage];
			}];
			[subviews addObject:plus];
		}
		
		[_imagesView autoLayoutSubviews:subviews marginPT:g marginPL:g marginPR:0];
		[_imagesView subviewsDragSortWithTarget:self withOut:[_imagesView viewWithTag:99]];
	}
	
	[self animateNextView:_imagesView height:_imagesView.lastSubview.bottom completion:nil];
}

- (void)deleteImage:(UIView*)view{
	CGFloat g = floor((SCREEN_WIDTH-IMAGE_WIDTH*5)/6);
	NSInteger index = view.tag - 100;
	[view scaleAnimateWithTime:0.3 percent:0.001 completion:^{
		[view removeFromSuperview];
		for (int i=0; i<_imagesView.subviews.count; i++) {
			UIView *view = _imagesView.subviews[i];
			if (view.tag != 99) {
				view.tag = 100 + i;
			}
		}
		NSInteger asstesIndex = [_assetsIndex indexOfObject:_images[index]];
		if (asstesIndex != NSNotFound) {
			[_assets removeObjectAtIndex:asstesIndex];
			[_assetsIndex removeObjectAtIndex:asstesIndex];
		}
		[_images removeObjectAtIndex:index];
		[_imageUrls removeObjectAtIndex:index];
		[_imageMemos removeObjectAtIndex:index];
		
		if (![_imagesView viewWithTag:99]) {
			UIImageView *plus = [[UIImageView alloc]initWithFrame:CGRectMake(g, g, IMAGE_WIDTH, IMAGE_WIDTH)];
			plus.image = IMG(@"p-plus");
			plus.tag = 99;
			[plus click:^(UIView *view, UIGestureRecognizer *sender) {
				[self selectImage];
			}];
			[_imagesView addSubview:plus];
		}
		
		[_imagesView autoLayoutSubviewsAgainWithX:g y:g marginPT:g marginPL:g marginPR:0];
		[self animateNextView:_imagesView height:_imagesView.lastSubview.bottom completion:nil];
	}];
}
#pragma mark -

- (void)subviewsDragSortStateStart:(UIView *)view{
	[_scroll bringSubviewToFront:_imagesView];
}
- (void)subviewsDragSortStateChanged:(UIView *)view fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
	fromIndex -= 100;
	toIndex -= 100;
	id obj;
	
	obj = _images[fromIndex];
	[_images removeObjectAtIndex:fromIndex];
	[_images insertObject:obj atIndex:toIndex];
	
	obj = _imageUrls[fromIndex];
	[_imageUrls removeObjectAtIndex:fromIndex];
	[_imageUrls insertObject:obj atIndex:toIndex];
	
	obj = _imageMemos[fromIndex];
	[_imageMemos removeObjectAtIndex:fromIndex];
	[_imageMemos insertObject:obj atIndex:toIndex];
}
- (void)subviewsDragSortStateEnd:(UIView *)view{
	[_scroll sendSubviewToBack:_imagesView];
}
#pragma mark -

- (void)animateNextView:(UIView*)subview height:(CGFloat)height completion:(void (^)())completion{
	NSArray *nextViews = subview.nextViews;
	[UIView animateWithDuration:0.3 animations:^{
		subview.height = height;
		for (UIView *view in nextViews) {
			view.top = view.prevView.bottom + [view.element[@"marginTop"] floatValue];
		}
		_scroll.contentSize = CGSizeMake(_scroll.width, _scroll.lastSubview.bottom+8);
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

- (void)AJPickerView:(AJPickerView *)pickerView didSubmitRow:(NSInteger)row inComponent:(NSInteger)component{
	_typeLabel.text = _ms[row][@"name"];
	_type_id = _ms[row][@"id"];
}

- (void)GlobalExecuteWithData:(NSDictionary*)data{
	MJPhotoBrowser *browser = data[@"browser"];
	NSInteger index = browser.currentPhotoIndex;
	NSArray *photos = browser.photos;
	if (_imageMemos.count-1<index) return;
	[_imageMemos replaceObjectAtIndex:index withObject:data[@"memo"]];
	MJPhoto *photo = photos[index];
	photo.content = data[@"memo"];
	[browser reloadData];
}

- (void)GlobalExecuteWithData:(NSDictionary *)data caller:(UIViewController *)caller{
	_packages_goods_name = data[@"name"];
	_packages_goods_id = data[@"id"];
	_packageLabel.text = _packages_goods_name;
}

- (void)GlobalExecuteWithCaller:(UIViewController*)caller data:(NSDictionary*)data{
	_commissionLabel.text = data[@"name"];
	_commission_template_id = data[@"id"];
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)pass{
	if (!_name.text.length) {
		[ProgressHUD showError:@"请输入标题"];
		return;
	}
	UIView *view = [_scroll viewWithTag:90];
	NSArray *subviews = [view.firstSubview subviewsOfClass:[SpecialTextField class]];
	if (subviews.count) {
		for (SpecialTextField *element in subviews) {
			if (!element.text.length && element.tag!=12) {
				switch (element.tag) {
					case 10:[ProgressHUD showError:@"请输入规格名称"];break;
					case 11:[ProgressHUD showError:@"请输入价格"];break;
					//case 12:[ProgressHUD showError:@"请输入促销价"];break;
					case 13:[ProgressHUD showError:@"请输入库存"];break;
				}
				return;
				break;
			}
			switch (element.tag) {
				case 11:{
					if ([element.text floatValue]<=0 || [[element.text right:1] hasSuffix:@"."]) {
						[ProgressHUD showError:@"请输入正确的价格"];
						return;
					}
					break;
				}
				case 12:{
					if (element.text.length) {
						if ([element.text floatValue]<=0 || [[element.text right:1] hasSuffix:@"."]) {
							[ProgressHUD showError:@"请输入正确的促销价"];
							return;
						}
						if ([element.text floatValue]>=[[[element.superview.prevView viewWithTag:11] text] floatValue]) {
							[ProgressHUD showError:@"促销价不能高于或等于价格"];
							return;
						}
					}
					break;
				}
				case 13:{
					if ([element.text floatValue]<=0) {
						[ProgressHUD showError:@"请输入正确的库存"];
						return;
					}
					break;
				}
			}
		}
	} else {
		if ([_price.text floatValue]<=0 || [[_price.text right:1] hasSuffix:@"."]) {
			[ProgressHUD showError:@"请输入正确的价格"];
			return;
		}
		if (_special_price.text.length) {
			if ([_special_price.text floatValue]<=0 || [[_special_price.text right:1] hasSuffix:@"."]) {
				[ProgressHUD showError:@"请输入正确的促销价"];
				return;
			}
			if ([_special_price.text floatValue]>=[_price.text floatValue]) {
				[ProgressHUD showError:@"促销价不能高于或等于价格"];
				return;
			}
		}
		if (!_stocks.text.length) {
			[ProgressHUD showError:@"请输入库存"];
			return;
		}
	}
	UISwitch *_switch = (UISwitch*)[_scroll viewWithTag:1000];
	if (_switch.on) {
		if (!_packages.text.length || _packages.text.intValue<=0) {
			[ProgressHUD showError:@"包装内的商品数量不合法"];
			return;
		}
		if (!_packages_goods_id.length || _packages_goods_id.intValue<=0) {
			[ProgressHUD showError:@"请选择对应商品"];
			return;
		}
	}
	if (!_shipping_fee.text.length) {
		//[ProgressHUD showError:@"请输入运费"];
		//return;
	}
	if (!_commission_template_id.length) {
		[ProgressHUD showError:@"请选择分利模板"];
		return;
	}
	if (!_type_id.length) {
		[ProgressHUD showError:@"请选择商品分类"];
		return;
	}
	if (!_description.text.length) {
		[ProgressHUD showError:@"请输入商品描述"];
		return;
	}
	[ProgressHUD show:@"资料正在提交，请耐心等待"];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	if (_data.isDictionary) [postData setValue:_data[@"id"] forKey:@"goods_id"];
	[postData setValue:_name.text forKey:@"name"];
	[postData setValue:_shipping_fee.text forKey:@"shipping_fee"];
	[postData setValue:_commission_template_id forKey:@"commission_template_id"];
	[postData setValue:_type_id forKey:@"type_id"];
	[postData setValue:_description.text forKey:@"description"];
	[postData setValue:_switch.on?_packages.text:@"" forKey:@"packages"];
	[postData setValue:_switch.on?_packages_goods_id:@"" forKey:@"packages_goods_id"];
	
	NSMutableArray *specs = [[NSMutableArray alloc]init];
	if (subviews.count) {
		for (UIView *subview in view.subviews) {
			BOOL isFull = YES;
			for (int i=10; i<=13; i++) {
				SpecialTextField *element = (SpecialTextField*)[subview viewWithTag:i];
				if (!element.text.length && element.tag!=12) {
					isFull = NO;
					break;
				}
			}
			if (isFull) {
				NSMutableDictionary *subspecs = [[NSMutableDictionary alloc]init];
				for (int i=10; i<=13; i++) {
					SpecialTextField *element = (SpecialTextField*)[subview viewWithTag:i];
					switch (i) {
						case 10:[subspecs setObject:element.text forKey:@"spec"];break;
						case 11:[subspecs setObject:element.text forKey:@"price"];break;
						case 12:[subspecs setObject:element.text forKey:@"special_price"];break;
						case 13:[subspecs setObject:element.text forKey:@"stocks"];break;
					}
				}
				[specs addObject:subspecs];
			}
		}
	} else {
		NSMutableDictionary *subspecs = [[NSMutableDictionary alloc]init];
		[subspecs setObject:@"默认规格" forKey:@"spec"];
		[subspecs setObject:_price.text forKey:@"price"];
		[subspecs setObject:_special_price.text forKey:@"special_price"];
		[subspecs setObject:_stocks.text forKey:@"stocks"];
		[specs addObject:subspecs];
	}
	if (specs.count) [postData setValue:(@{@"specs":specs}).jsonString forKey:@"specs"];
	
	[self pass:postData];
}

- (void)pass:(NSMutableDictionary*)postData{
	BOOL isUploaded = YES;
	for (int i=0; i<_imageUrls.count; i++) {
		if (![_imageUrls[i] isUrl]) {
			[[_images[i] imageQualityMiddle] UploadToUpyun:@"uploadfiles/shop/product" imageName:_imageUrls[i] completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
				NSInteger index = [_imageUrls indexOfObject:imageName];
				if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:imageUrl];
			}];
			isUploaded = NO;
			break;
		}
	}
	if (isUploaded) {
		for (int i=0; i<_imageUrls.count; i++) {
			[postData setValue:_imageUrls[i] forKey:STRINGFORMAT(@"pic%d", i+1)];
			[postData setValue:_imageMemos[i] forKey:STRINGFORMAT(@"memo%d", i+1)];
		}
		[Common postApiWithParams:@{@"app":@"goods", @"act":@"create"} data:postData success:^(NSMutableDictionary *json) {
			[self.navigationController popViewControllerAnimated:YES];
		} fail:nil];
	} else {
		[self performSelector:@selector(pass:) withObject:postData afterDelay:1.0f];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
