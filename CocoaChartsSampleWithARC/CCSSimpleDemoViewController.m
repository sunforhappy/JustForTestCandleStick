//
//  CCSSimpleDemoViewController.m
//  CocoaChartsSample
//
//  Created by limc on 12/26/13.
//  Copyright (c) 2013 limc. All rights reserved.
//

#import "CCSSimpleDemoViewController.h"
#import "CCSColoredStickChartData.h"
#import "CCSCandleStickChartData.h"
#import "CCSTitledLine.h"
#import "CCSLineData.h"
#import "CCSMACDData.h"

#import "ta_libc.h"
#import "CCSTALibUtils.h"
#import "CCSStringUtils.h"

#define WR_NONE_DISPLAY 101

@implementation OHLCVDData
@synthesize open = _open;
@synthesize high = _high;
@synthesize low = _low;
@synthesize close = _close;
@synthesize vol = _vol;
@synthesize date = _date;
@synthesize current = _current;
@synthesize change = _change;
@synthesize preclose = _preclose;


@end

@interface CCSSimpleDemoViewController ()


@end

@implementation CCSSimpleDemoViewController

/******************************************************************************
 *  Override From NSObject
 ******************************************************************************/

CGFloat  MARGIN_TOP;
CGFloat  DEVICE_HEIGHT;
CGFloat  DEVICE_WIDTH;
- (id)init{
    self = [super init];
    if (self) {
        CGRect r = [ UIScreen mainScreen ].applicationFrame;
        DEVICE_WIDTH = r.size.width;
        DEVICE_HEIGHT = r.size.height;
        MARGIN_TOP = 22;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"%@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
}
- (void)viewDidLoad {
    [super viewDidLoad];
 //   NSLog(@"%@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);

    [self loadData];
 //   NSLog(@"loadData %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    [self initCandleStickChart];
 //   NSLog(@"initCandleStickChart %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    [self initControllers];
 //   NSLog(@"initControllers %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    [self initStickChart];
 //   NSLog(@"initStickChart %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    [self initMACDChart];
//    NSLog(@"initMACDChart %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    [self initKDJChart];
 //   NSLog(@"initKDJChart %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    [self initRSIChart];
 //   NSLog(@"initRSIChart %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    [self initWRChart];
 //   NSLog(@"initWRChart %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    [self initCCIChart];
  //  NSLog(@"initCCIChart %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    [self initBOLLChart];
  //  NSLog(@"initBOLLChart %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);

    self.scrollViewBottomChart.contentSize = CGSizeMake(self.scrollViewBottomChart.frame.size.width * 7, self.self.scrollViewBottomChart.frame.size.height);

    //如果k线中已有数据，显示最后一根
    if ([self.candleStickChart.stickData count] > 0) {
        self.candleStickChart.selectedStickIndex = [self.candleStickChart.stickData count] - 1;
        [self candleStickChartTouch:self];
    }

    //[self clearChart];
    self.candleStickChart.multipleTouchEnabled = YES;
    [self positioningViews];
    [self.view setBackgroundColor:[UIColor blackColor]];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self onRotateScreen];
}

- (void) onRotateScreen
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.height < screenSize.width   ) {
        screenSize = CGSizeMake(screenSize.height, screenSize.width);
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortrait) {
        DEVICE_WIDTH = screenSize.width;
        DEVICE_HEIGHT = screenSize.height;
        MARGIN_TOP = 22;
    }
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        DEVICE_WIDTH = screenSize.height;
        DEVICE_HEIGHT = screenSize.width;
        MARGIN_TOP = 0;
    }

    [self positioningViews ];
}

- (void)loadData {
    NSString *fileName = @"N225.xml";
    NSArray *fileComponents = [fileName componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0]
                                                         ofType:[fileComponents objectAtIndex:1]];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSXMLParser *parser = [[[NSXMLParser alloc] init] initWithContentsOfURL:url];
    parser.delegate = self;
    [parser parse];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    if ([elementName isEqualToString:@"item"]) {
        OHLCVDData *data = [[OHLCVDData alloc] init];

        data.open = [attributeDict objectForKey:@"open"];
        data.high = [attributeDict objectForKey:@"high"];
        data.low = [attributeDict objectForKey:@"low"];
        data.close = [attributeDict objectForKey:@"close"];
        data.vol = [attributeDict objectForKey:@"vol"];
        data.date = [attributeDict objectForKey:@"date"];
        data.current = [attributeDict objectForKey:@"current"];
        data.preclose = [attributeDict objectForKey:@"preclose"];
        data.change = [attributeDict objectForKey:@"change"];

        self.oHLCVDData = data;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"item"]) {
        if (self.chartData == nil) {
            self.chartData = [[NSMutableArray alloc] init];
        }

        [self.chartData addObject:self.oHLCVDData];
    }
}
- (void) positioningViews
{

    _candleStickChart.frame = CGRectMake(0, MARGIN_TOP, DEVICE_WIDTH, DEVICE_HEIGHT/2);
    _scrollViewBottomChart.frame = CGRectMake(0, _candleStickChart.frame.size.height+ MARGIN_TOP, DEVICE_WIDTH, DEVICE_HEIGHT/4);
    _scrollViewBottomChart.contentSize = CGSizeMake(_scrollViewBottomChart.frame.size.width * 7, _scrollViewBottomChart.frame.size.height);
    CGPoint offset;
    offset.y =0;
    offset.x = _segBottomChartType.selectedSegmentIndex * _scrollViewBottomChart.frame.size.width;
    _scrollViewBottomChart.contentOffset   = offset;
    _stickChart.frame = CGRectMake(0, 0, DEVICE_WIDTH, _scrollViewBottomChart.frame.size.height);
    _macdChart.frame = CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, _scrollViewBottomChart.frame.size.height);
    _kdjChart.frame = CGRectMake(DEVICE_WIDTH*2, 0, DEVICE_WIDTH, _scrollViewBottomChart.frame.size.height);
    _rsiChart.frame = CGRectMake(DEVICE_WIDTH*3, 0, DEVICE_WIDTH, _scrollViewBottomChart.frame.size.height);
    _wrChart.frame = CGRectMake(DEVICE_WIDTH*4, 0, DEVICE_WIDTH, _scrollViewBottomChart.frame.size.height);
    _cciChart.frame = CGRectMake(DEVICE_WIDTH*5, 0, DEVICE_WIDTH, _scrollViewBottomChart.frame.size.height);
    _bollChart.frame = CGRectMake(DEVICE_WIDTH*6, 0, DEVICE_WIDTH, _scrollViewBottomChart.frame.size.height);

    _segChartType.frame = CGRectMake(0, MARGIN_TOP + _candleStickChart.frame.size.height +  _scrollViewBottomChart.frame.size.height
                                     + 5, 200, 33);
    _segBottomChartType.frame = CGRectMake(0, MARGIN_TOP + MARGIN_TOP + _candleStickChart.frame.size.height +  _scrollViewBottomChart.frame.size.height + 40, 320, 33);
}

- (void)initControllers {

    _scrollViewBottomChart = [[UIScrollView alloc] init];
    _scrollViewBottomChart.frame = CGRectMake(0, _candleStickChart.frame.size.height+ MARGIN_TOP, DEVICE_WIDTH, DEVICE_HEIGHT/4);    _scrollViewBottomChart.bounces = NO;
    _scrollViewBottomChart.contentSize = CGSizeMake(DEVICE_WIDTH * 6, DEVICE_HEIGHT);
    _scrollViewBottomChart.pagingEnabled = YES;
    _scrollViewBottomChart.delegate = self;


    _segChartType = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"移动k线", @"移动光标",  nil]];
    _segChartType.frame = CGRectMake(0, MARGIN_TOP + _candleStickChart.frame.size.height +  _scrollViewBottomChart.frame.size.height
                                     + 5, 200, 33);    _segChartType.segmentedControlStyle = UISegmentedControlStyleBar;
    [_segChartType addTarget:self action:@selector(segChartTypeValueChanged:) forControlEvents:UIControlEventValueChanged];

    _segBottomChartType = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"VOL", @"MACD", @"KDJ", @"RSI", @"WR", @"CCI", @"BOLL", nil]];
    _segBottomChartType.frame = CGRectMake(0, MARGIN_TOP + MARGIN_TOP + _candleStickChart.frame.size.height +  _scrollViewBottomChart.frame.size.height + 40, 320, 33);
    _segBottomChartType.segmentedControlStyle = UISegmentedControlStyleBar;
    _segBottomChartType.selectedSegmentIndex = 0; 
    [_segBottomChartType addTarget:self action:@selector(segBottomChartTypeTypeValueChaged:) forControlEvents:UIControlEventValueChanged];



    self.segChartType = _segChartType;
    self.segBottomChartType = _segBottomChartType;
    self.scrollViewBottomChart = _scrollViewBottomChart;
    [self.view addSubview:_segChartType];
    [self.view addSubview:_segBottomChartType];
    [self.view addSubview:_scrollViewBottomChart];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.title = @"Simple Demo";
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    self.lblTitle = nil;
    self.lblOpen = nil;
    self.lblHigh = nil;
    self.lblLow = nil;
    self.lblClose = nil;
    self.lblVolume = nil;
    self.lblDate = nil;
    self.lblChange = nil;
    self.lblPreClose = nil;
    self.lblSubTitle1 = nil;
    self.lblSubTitle2 = nil;
    self.lblSubTitle3 = nil;
    self.lblSubTitle4 = nil;
    self.lblSubTitle5 = nil;
    self.lblSubTitle6 = nil;
    self.lblSubTitle7 = nil;
    self.lblSubTitle8 = nil;
    self.lblSubTitle9 = nil;
    self.lblSubTitle10 = nil;
    self.segChartType = nil;
    self.segBottomChartType = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];

    self.lblTitle = nil;
    self.lblOpen = nil;
    self.lblHigh = nil;
    self.lblLow = nil;
    self.lblClose = nil;
    self.lblVolume = nil;
    self.lblDate = nil;
    self.lblChange = nil;
    self.lblPreClose = nil;
    self.lblSubTitle1 = nil;
    self.lblSubTitle2 = nil;
    self.lblSubTitle3 = nil;
    self.lblSubTitle4 = nil;
    self.lblSubTitle5 = nil;
    self.lblSubTitle6 = nil;
    self.lblSubTitle7 = nil;
    self.lblSubTitle8 = nil;
    self.lblSubTitle9 = nil;
    self.lblSubTitle10 = nil;
    self.segChartType = nil;
    self.segBottomChartType = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

/******************************************************************************
 *  Public/Protected Method Implementation.
 ******************************************************************************/

//- (void)setIndexDaylistData:(IndexDaylistData *)data {
//    [_indexDaylistData autorelease];
//    _indexDaylistData = [data retain];
//
//    NSLog(@"%@", data);
//    if (data != NULL) {
//        self.lblOpen.textColor = [UIColor blackColor];
//        self.lblOpen.text = @"-";
//        self.lblClose.textColor = [UIColor blackColor];
//        self.lblClose.text = @"-";
//        self.lblHigh.textColor = [UIColor blackColor];
//        self.lblHigh.text = @"-";
//        self.lblLow.textColor = [UIColor blackColor];
//        self.lblLow.text = @"-";
//        self.lblVolume.textColor = [UIColor blackColor];
//        self.lblVolume.text = @"-";
//        self.lblDate.textColor = [UIColor blackColor];
//        self.lblDate.text = @"-";
//        self.lblChange.text = @"";
//        self.lblPreClose.text = @"";
//        self.lblSubTitle1.text = @"";
//        self.lblSubTitle1.textColor = [UIColor blackColor];
//        self.lblSubTitle2.text = @"";
//        self.lblSubTitle2.textColor = [UIColor blackColor];
//        self.lblSubTitle3.text = @"";
//        self.lblSubTitle3.textColor = [UIColor blackColor];
//        self.lblSubTitle4.text = @"";
//        self.lblSubTitle4.textColor = [UIColor blackColor];
//        self.lblSubTitle5.text = @"";
//        self.lblSubTitle5.textColor = [UIColor blackColor];
//        self.lblSubTitle6.text = @"";
//        self.lblSubTitle6.textColor = [UIColor blackColor];
//        self.lblSubTitle7.text = @"";
//        self.lblSubTitle7.textColor = [UIColor blackColor];
//        self.lblSubTitle8.text = @"";
//        self.lblSubTitle8.textColor = [UIColor blackColor];
//        self.lblSubTitle9.text = @"";
//        self.lblSubTitle9.textColor = [UIColor blackColor];
//        self.lblSubTitle10.text = @"";
//        self.lblSubTitle10.textColor = [UIColor blackColor];
//        [self initCandleStickChartData];
//        [self initStickChartData];
//        [self initMACDChartData];
//        [self initKDJChartData];
//        [self initRSIChartData];
//        [self initWRChartData];
//        [self initCCIChartData];
//        [self initBOLLChartData];
//
//        if ([self.candleStickChart.stickData count] > 0) {
//            self.candleStickChart.selectedStickIndex = [self.candleStickChart.stickData count] - 1;
//            [self candleStickChartTouch:self];
//        }
//
//    }
//
//}


- (void)segChartTypeValueChanged:(UISegmentedControl *)segmentedControl {
    if (0 == segmentedControl.selectedSegmentIndex) {
        [self.candleStickChart setMoveCandleStick];
//        [_stickChart setMoveCandleStick];
//        [_macdChart setMoveCandleStick];
//        [_kdjChart setMoveCandleStick];
//        [_rsiChart setMoveCandleStick];
//        [_wrChart setMoveCandleStick];
//        [_cciChart setMoveCandleStick];
//        [_bollChart setMoveCandleStick];

     } else if (1 == segmentedControl.selectedSegmentIndex) {
         [self.candleStickChart setMoveCross];
//         [_stickChart setMoveCross];
//         [_macdChart setMoveCross];
//         [_kdjChart setMoveCross];
//         [_rsiChart setMoveCross];
//         [_wrChart setMoveCross];
//         [_cciChart setMoveCross];
//         [_bollChart setMoveCross];

    }
}

- (void)segBottomChartTypeTypeValueChaged:(UISegmentedControl *)segmentedControl {
    self.lblSubTitle3.text = @"";
    self.lblSubTitle3.textColor = [UIColor blackColor];
    self.lblSubTitle4.text = @"";
    self.lblSubTitle5.textColor = [UIColor blackColor];
    self.lblSubTitle5.text = @"";
    self.lblSubTitle6.textColor = [UIColor blackColor];
    self.lblSubTitle6.text = @"";
    self.lblSubTitle6.textColor = [UIColor blackColor];
    self.lblSubTitle7.text = @"";
    self.lblSubTitle7.textColor = [UIColor blackColor];
    self.lblSubTitle8.text = @"";
    self.lblSubTitle8.textColor = [UIColor blackColor];
    self.lblSubTitle9.text = @"";
    self.lblSubTitle9.textColor = [UIColor blackColor];
    self.lblSubTitle10.text = @"";
    self.lblSubTitle10.textColor = [UIColor blackColor];

    // 得到每页宽度
    CGFloat pageWidth = self.scrollViewBottomChart.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    int page = (int) floor((self.scrollViewBottomChart.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (segmentedControl.selectedSegmentIndex != page) {
        //滚动相应的距离
        self.scrollViewBottomChart.contentOffset = CGPointMake(pageWidth * segmentedControl.selectedSegmentIndex, self.scrollViewBottomChart.contentOffset.y);
    }

    self.candleStickChart.bollingerBandStyle = CCSBollingerBandStyleNone;

    if (0 == self.segBottomChartType.selectedSegmentIndex) {
        self.stickChart.displayFrom = self.candleStickChart.displayFrom;
        self.stickChart.displayNumber = self.candleStickChart.displayNumber;
        [self.stickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = ChartViewTypeVOL;
    } else if (1 == self.segBottomChartType.selectedSegmentIndex) {
        self.macdChart.displayFrom = self.candleStickChart.displayFrom;;
        self.macdChart.displayNumber = self.candleStickChart.displayNumber;
        [self.macdChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = ChartViewTypeMACD;
    } else if (2 == self.segBottomChartType.selectedSegmentIndex) {
        self.kdjChart.displayFrom = self.candleStickChart.displayFrom;;
        self.kdjChart.displayNumber = self.candleStickChart.displayNumber;
        [self.kdjChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = ChartViewTypeKDJ;
    } else if (3 == self.segBottomChartType.selectedSegmentIndex) {
        self.rsiChart.displayFrom = self.candleStickChart.displayFrom;;
        self.rsiChart.displayNumber = self.candleStickChart.displayNumber;
        [self.rsiChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = ChartViewTypeRSI;
    } else if (4 == self.segBottomChartType.selectedSegmentIndex) {
        self.wrChart.displayFrom = self.candleStickChart.displayFrom;;
        self.wrChart.displayNumber = self.candleStickChart.displayNumber;
        [self.wrChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = ChartViewTypeWR;
    } else if (5 == self.segBottomChartType.selectedSegmentIndex) {
        self.cciChart.displayFrom = self.candleStickChart.displayFrom;;
        self.cciChart.displayNumber = self.candleStickChart.displayNumber;
        [self.cciChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = ChartViewTypeCCI;
    } else if (6 == self.segBottomChartType.selectedSegmentIndex) {
        self.bollChart.displayFrom = self.candleStickChart.displayFrom;;
        self.bollChart.displayNumber = self.candleStickChart.displayNumber;
        [self.bollChart performSelector:@selector(setNeedsDisplay) withObject:nil];

        self.candleStickChart.bollingerBandStyle = CCSBollingerBandStyleBand;
        self.bottomChartType = ChartViewTypeBOLL;
    }

    [self.candleStickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
}


- (void)candleStickChartTouch:(id)sender {
    NSInteger i = self.candleStickChart.selectedStickIndex;

    if (self.candleStickChart.stickData && [self.candleStickChart.stickData count] > 0) {
        CCSCandleStickChartData *ohlc = [self.candleStickChart.stickData objectAtIndex:i];
        CCSCandleStickChartData *lastohlc;
        //第一根k线时，处理前日比
        if (i == 0) {
            lastohlc = [[CCSCandleStickChartData alloc] initWithOpen:0 high:0 low:0 close:ohlc.close - ohlc.change date:@""];
        } else {
            lastohlc = [self.candleStickChart.stickData objectAtIndex:i - 1];
        }

        //设置标签值
        self.lblOpen.text = [[[NSString stringWithFormat:@"%f", ohlc.open] decimal:2] zero];
        self.lblHigh.text = [[[NSString stringWithFormat:@"%f", ohlc.high] decimal:2] zero];
        self.lblLow.text = [[[NSString stringWithFormat:@"%f", ohlc.low] decimal:2] zero];
        self.lblClose.text = [[[NSString stringWithFormat:@"%f", ohlc.close] decimal:2] zero];

        self.lblChange.text = [NSString stringWithFormat:@"%@(%@%%)",
                               [[NSString stringWithFormat:@"%f", ohlc.change] decimalWithSign:2],
                               [[NSString stringWithFormat:@"%f", ohlc.change * 100 / lastohlc.close] decimalWithSign:2]];

        self.lblPreClose.text = [NSString stringWithFormat:@"前日終値:%@", [[[NSString stringWithFormat:@"%f", lastohlc.close] decimal:2] zero]];

        self.lblDate.text = ohlc.date;

        //设置标签文本颜色
        if (ohlc.open == 0) {
            self.lblOpen.textColor = [UIColor blackColor];
        } else {
            //设置标签文本颜色
            self.lblOpen.textColor = ohlc.open != lastohlc.close ? ohlc.open > lastohlc.close ? [UIColor redColor] : [UIColor blueColor] : [UIColor blackColor];
        }

        if (ohlc.high == 0) {
            self.lblHigh.textColor = [UIColor blackColor];
        } else {
            //设置标签文本颜色
            self.lblHigh.textColor = ohlc.high != lastohlc.close ? ohlc.high > lastohlc.close ? [UIColor redColor] : [UIColor blueColor] : [UIColor blackColor];
        }

        if (ohlc.low == 0) {
            self.lblLow.textColor = [UIColor blackColor];
        } else {
            self.lblLow.textColor = ohlc.low != lastohlc.close ? ohlc.low > lastohlc.close ? [UIColor redColor] : [UIColor blueColor] : [UIColor blackColor];
        }

        if (ohlc.close == 0) {
            self.lblClose.textColor = [UIColor blackColor];
        } else {
            self.lblClose.textColor = ohlc.close != lastohlc.close ? ohlc.close > lastohlc.close ? [UIColor redColor] : [UIColor blueColor] : [UIColor blackColor];
        }

        if (ohlc.change == 0) {
            self.lblChange.textColor = [UIColor blackColor];
        } else {
            self.lblChange.textColor = ohlc.close != lastohlc.close ? ohlc.close > lastohlc.close ? [UIColor redColor] : [UIColor blueColor] : [UIColor blackColor];
        }

    }

    if (self.stickChart.stickData && [self.stickChart.stickData count] > 0) {
        //成交量
        self.lblVolume.text = [[[NSString stringWithFormat:@"%-2.0f", ((CCSStickChartData *) [self.stickChart.stickData objectAtIndex:i]).high] decimal] zero];
    }

    if (self.candleStickChart.linesData && [self.candleStickChart.linesData count] > 0) {

        //均线数据
        CCSTitledLine *ma5 = [self.candleStickChart.linesData objectAtIndex:0];
        CCSTitledLine *ma10 = [self.candleStickChart.linesData objectAtIndex:1];

        //MA5
        if (ma5 && ma5.data && [ma5.data count] > 0) {
            if (((CCSLineData *) [ma5.data objectAtIndex:i]).value != 0) {
                self.lblSubTitle1.text = [NSString stringWithFormat:@"%@: %@", ma5.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [ma5.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
            } else {
                self.lblSubTitle1.text = @"";
            }
            self.lblSubTitle1.textColor = ma5.color;
        }

        //MA10
        if (ma10 && ma10.data && [ma10.data count] > 0) {
            if (((CCSLineData *) [ma10.data objectAtIndex:i]).value != 0) {
                self.lblSubTitle2.text = [NSString stringWithFormat:@"%@: %@", ma10.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [ma10.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
            } else {
                self.lblSubTitle2.text = @"";
            }
            self.lblSubTitle2.textColor = ma10.color;
        }

        if (ChartViewTypeVOL == self.bottomChartType) {
            if (self.stickChart.stickData && [self.stickChart.stickData count] > 0) {
                self.lblSubTitle6.text = [NSString stringWithFormat:@"VOL: %@", self.lblVolume.text];
            }

        } else if (ChartViewTypeMACD == self.bottomChartType) {
            if (self.macdChart.stickData && [self.macdChart.stickData count] > 0) {

                CCSMACDData *macdData = [self.macdChart.stickData objectAtIndex:i];
                if (macdData.diff != 0) {
                    self.lblSubTitle6.text = [NSString stringWithFormat:@"DIFF: %@", [[[NSString stringWithFormat:@"%f", (macdData.diff / self.macdChart.axisCalc)] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle6.text = @"";
                }
                self.lblSubTitle6.textColor = self.macdChart.diffLineColor;

                if (macdData.dea != 0) {
                    self.lblSubTitle7.text = [NSString stringWithFormat:@"DEA: %@", [[[NSString stringWithFormat:@"%f", (macdData.dea / self.macdChart.axisCalc)] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle7.text = @"";
                }
                self.lblSubTitle7.textColor = self.macdChart.deaLineColor;

                if (macdData.macd != 0) {
                    self.lblSubTitle8.text = [NSString stringWithFormat:@"MACD: %@", [[[NSString stringWithFormat:@"%f", (macdData.macd / self.macdChart.axisCalc)] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle8.text = @"";
                }
                self.lblSubTitle8.textColor = self.macdChart.macdLineColor;

            }
        } else if (ChartViewTypeKDJ == self.bottomChartType) {
            //均线数据
            CCSTitledLine *lineK = [self.kdjChart.linesData objectAtIndex:0];
            CCSTitledLine *lineD = [self.kdjChart.linesData objectAtIndex:1];
            CCSTitledLine *lineJ = [self.kdjChart.linesData objectAtIndex:2];

            //K
            if (lineK && lineK.data && [lineK.data count] > 0) {
                if (((CCSLineData *) [lineK.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle6.text = [NSString stringWithFormat:@"%@: %@", lineK.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [lineK.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle6.text = @"";
                }
                self.lblSubTitle6.textColor = lineK.color;
            }

            //D
            if (lineD && lineD.data && [lineD.data count] > 0) {
                if (((CCSLineData *) [lineD.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle7.text = [NSString stringWithFormat:@"%@: %@", lineD.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [lineD.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle7.text = @"";
                }
                self.lblSubTitle7.textColor = lineD.color;
            }

            //J
            if (lineJ && lineJ.data && [lineJ.data count] > 0) {
                if (((CCSLineData *) [lineJ.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle8.text = [NSString stringWithFormat:@"%@: %@", lineJ.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [lineJ.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle8.text = @"";
                }
                self.lblSubTitle8.textColor = lineJ.color;
            }
        } else if (ChartViewTypeRSI == self.bottomChartType) {
            //均线数据
            CCSTitledLine *line6 = [self.rsiChart.linesData objectAtIndex:0];
            CCSTitledLine *line12 = [self.rsiChart.linesData objectAtIndex:1];
            CCSTitledLine *line24 = [self.rsiChart.linesData objectAtIndex:2];

            //6
            if (line6 && line6.data && [line6.data count] > 0) {
                if (((CCSLineData *) [line6.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle6.text = [NSString stringWithFormat:@"%@: %@", line6.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [line6.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle6.text = @"";
                }
                self.lblSubTitle6.textColor = line6.color;
            }

            //12
            if (line12 && line12.data && [line12.data count] > 0) {
                if (((CCSLineData *) [line12.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle7.text = [NSString stringWithFormat:@"%@: %@", line12.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [line12.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle7.text = @"";
                }
                self.lblSubTitle7.textColor = line12.color;
            }

            //24
            if (line24 && line24.data && [line24.data count] > 0) {
                if (((CCSLineData *) [line24.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle8.text = [NSString stringWithFormat:@"%@: %@", line24.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [line24.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle8.text = @"";
                }
                self.lblSubTitle8.textColor = line24.color;
            }
        } else if (ChartViewTypeWR == self.bottomChartType) {
            //均线数据
            CCSTitledLine *lineWR = [self.wrChart.linesData objectAtIndex:0];

            //WR
            if (lineWR && lineWR.data && [lineWR.data count] > 0) {
                if (((CCSLineData *) [lineWR.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle6.text = [NSString stringWithFormat:@"%@: %@", lineWR.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [lineWR.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle6.text = @"";
                }
                self.lblSubTitle6.textColor = lineWR.color;
            }

            self.lblSubTitle7.text = @"";
            self.lblSubTitle8.text = @"";

        } else if (ChartViewTypeCCI == self.bottomChartType) {
            //均线数据
            CCSTitledLine *lineCCI = [self.cciChart.linesData objectAtIndex:0];

            if (lineCCI && lineCCI.data && [lineCCI.data count] > 0) {
                if (((CCSLineData *) [lineCCI.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle6.text = [NSString stringWithFormat:@"%@: %@", lineCCI.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [lineCCI.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle6.text = @"";
                }
                self.lblSubTitle6.textColor = lineCCI.color;
            }

            self.lblSubTitle7.text = @"";
            self.lblSubTitle8.text = @"";

        } else if (ChartViewTypeBOLL == self.bottomChartType) {
            //均线数据
            CCSTitledLine *upper = [self.candleStickChart.bollingerBandData objectAtIndex:0];
            CCSTitledLine *lower = [self.candleStickChart.bollingerBandData objectAtIndex:1];
            CCSTitledLine *boll = [self.candleStickChart.bollingerBandData objectAtIndex:2];

            //UPPER
            if (upper && upper.data && [upper.data count] > 0) {
                if (((CCSLineData *) [upper.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle3.text = [NSString stringWithFormat:@"%@: %@", upper.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [upper.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle3.text = @"";
                }
                self.lblSubTitle3.textColor = upper.color;

                self.lblSubTitle6.textColor = self.lblSubTitle3.textColor;
                self.lblSubTitle6.text = self.lblSubTitle3.text;
            }

            //LOWER
            if (lower && lower.data && [lower.data count] > 0) {
                if (((CCSLineData *) [lower.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle4.text = [NSString stringWithFormat:@"%@: %@", lower.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [lower.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle4.text = @"";
                }
                self.lblSubTitle4.textColor = lower.color;

                self.lblSubTitle7.textColor = self.lblSubTitle4.textColor;
                self.lblSubTitle7.text = self.lblSubTitle4.text;
            }

            //BOLL
            if (boll && boll.data && [boll.data count] > 0) {
                if (((CCSLineData *) [boll.data objectAtIndex:i]).value != 0) {
                    self.lblSubTitle5.text = [NSString stringWithFormat:@"%@: %@", boll.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [boll.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
                } else {
                    self.lblSubTitle5.text = @"";
                }
                self.lblSubTitle5.textColor = boll.color;

                self.lblSubTitle8.textColor = self.lblSubTitle5.textColor;
                self.lblSubTitle8.text = self.lblSubTitle5.text;
            }
        }
    }

    //成交量图设置线条
    //[self.stickChart setSelectedPointAddReDraw:self.candleStickChart.singleTouchPoint];

}

/******************************************************************************
 *  Private Method Implementation.
 ******************************************************************************/

- (void)initStickChartData {
    if (self.chartData != NULL) {
        NSMutableArray *stickDatas = [[NSMutableArray alloc] initWithCapacity:[self.chartData count]];

        for (NSInteger i = [self.chartData count] - 1; i >= 0; i--) {
            OHLCVDData *item = [self.chartData objectAtIndex:i];
            CCSColoredStickChartData *stickData = [[CCSColoredStickChartData alloc] init];
            stickData.high = [item.vol doubleValue];
            stickData.low = 0;
            stickData.date = [item.date dateWithFormat:@"yyyyMMdd" target:@"yyyy/MM/dd"];

            if ([item.close doubleValue] > [item.open doubleValue]) {
                stickData.fillColor = [UIColor redColor];
                stickData.borderColor = [UIColor redColor];
            } else if ([item.close doubleValue] < [item.open doubleValue]) {
                stickData.fillColor = [UIColor blueColor];
                stickData.borderColor = [UIColor blueColor];
            } else {
                stickData.fillColor = [UIColor blackColor];
                stickData.borderColor = [UIColor blackColor];
            }
            //增加数据
            [stickDatas addObject:stickData];
        }

        self.stickChart.stickData = stickDatas;
        self.stickChart.singleTouchPoint = CGPointMake(-1, -1);

        [self.stickChart setNeedsDisplay];
    }
}

- (void)initStickChart {
    CCSColoredStickChart *stickchart = [[CCSColoredStickChart alloc] initWithFrame:CGRectMake(0, 0, self.scrollViewBottomChart.frame.size.width, self.scrollViewBottomChart.frame.size.height)];
    stickchart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.stickChart = stickchart;

    //初始化数据
    [self initStickChartData];

    //设置stickData
    self.stickChart.minDisplayNumber = 25;
    self.stickChart.maxValue = 800000;
    self.stickChart.minValue = 0;
    self.stickChart.axisMarginLeft = 50;
    self.stickChart.displayCrossYOnTouch = NO;
    self.stickChart.displayCrossXOnTouch = NO;
    self.stickChart.stickFillColor = [UIColor colorWithRed:0.7 green:0.7 blue:0 alpha:0.8];

    self.stickChart.axisXColor = [UIColor darkGrayColor];
    self.stickChart.axisYColor = [UIColor darkGrayColor];
    self.stickChart.latitudeColor = [UIColor darkGrayColor];
    self.stickChart.longitudeColor = [UIColor darkGrayColor];
    self.stickChart.latitudeFontColor = [UIColor darkGrayColor];
    self.stickChart.longitudeFontColor = [UIColor darkGrayColor];
    self.stickChart.axisMarginLeft = 2;
    self.stickChart.axisMarginRight = 58;
    self.stickChart.axisMarginTop = 1;
    self.stickChart.axisYPosition = CCSGridChartYAxisPositionRight;
    self.stickChart.displayNumber = 50;
    self.stickChart.displayFrom = 99;


    self.stickChart.backgroundColor = [UIColor clearColor];

    [self.scrollViewBottomChart addSubview:self.stickChart];
}

- (void)initMACDChartData {
    if (self.chartData != NULL) {
        NSMutableArray *stickDatas = [[NSMutableArray alloc] initWithCapacity:[self.chartData count]];
        for (NSInteger i = [self.chartData count] - 1; i >= 0; i--) {
            OHLCVDData *item = [self.chartData objectAtIndex:i];
            CCSCandleStickChartData *stickData = [[CCSCandleStickChartData alloc] init];
            stickData.open = [item.open doubleValue];
            stickData.high = [item.high doubleValue];
            stickData.low = [item.low doubleValue];
            stickData.close = [item.close doubleValue];
            stickData.change = 0;
            stickData.date = [item.date dateWithFormat:@"yyyyMMdd" target:@"yyyy/MM/dd"];
            //增加数据
            [stickDatas addObject:stickData];
        }

        self.macdChart.stickData = [self computeMACDData:self.chartData];
        self.macdChart.singleTouchPoint = CGPointMake(-1, -1);

        [self.macdChart setNeedsDisplay];
    }
}

- (void)initMACDChart {
    CCSMACDChart *macdchart = [[CCSMACDChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    macdchart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.macdChart = macdchart;

    //初始化数据
    [self initMACDChartData];

    //设置stickData
    self.macdChart.minDisplayNumber = 25;
    self.macdChart.maxValue = 800000;
    self.macdChart.minValue = 0;
    self.macdChart.axisMarginLeft = 50;
    self.macdChart.displayCrossYOnTouch = NO;
    self.macdChart.displayCrossXOnTouch = NO;
    self.macdChart.stickFillColor = [UIColor colorWithRed:0.7 green:0.7 blue:0 alpha:0.8];

    self.macdChart.axisXColor = [UIColor darkGrayColor];
    self.macdChart.axisYColor = [UIColor darkGrayColor];
    self.macdChart.latitudeColor = [UIColor darkGrayColor];
    self.macdChart.longitudeColor = [UIColor darkGrayColor];
    self.macdChart.latitudeFontColor = [UIColor darkGrayColor];
    self.macdChart.longitudeFontColor = [UIColor darkGrayColor];
    self.macdChart.axisMarginLeft = 2;
    self.macdChart.axisMarginRight = 58;
    self.macdChart.axisMarginTop = 1;
    self.macdChart.axisYPosition = CCSGridChartYAxisPositionRight;

    self.macdChart.maxValue = 300000;
    self.macdChart.minValue = -300000;
    self.macdChart.maxSticksNum = 100;
    self.macdChart.displayCrossXOnTouch = NO;
    self.macdChart.displayCrossYOnTouch = NO;
    self.macdChart.latitudeNum = 2;
    self.macdChart.longitudeNum = 3;
    self.macdChart.backgroundColor = [UIColor blackColor];
    self.macdChart.macdDisplayType = CCSMACDChartDisplayTypeLineStick;
    self.macdChart.positiveStickColor = [UIColor redColor];
    self.macdChart.negativeStickColor = [UIColor blueColor];
    self.macdChart.macdLineColor = [UIColor cyanColor];
    self.macdChart.deaLineColor = [UIColor greenColor];
    self.macdChart.diffLineColor = [UIColor purpleColor];
    self.macdChart.displayNumber = 50;
    self.macdChart.displayFrom = 99;
    self.macdChart.axisCalc = 1000000;

    self.macdChart.backgroundColor = [UIColor clearColor];

    [self.scrollViewBottomChart addSubview:self.macdChart];
}

- (void)initKDJChartData {
    if (self.chartData != NULL) {

        self.kdjChart.linesData = [self computeKDJData:self.chartData];
        self.kdjChart.singleTouchPoint = CGPointMake(-1, -1);

        [self.kdjChart setNeedsDisplay];
    }
}

- (void)initKDJChart {
    CCSSlipLineChart *kdjchart = [[CCSSlipLineChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width * 2, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    kdjchart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.kdjChart = kdjchart;

    //初始化数据
    [self initKDJChartData];

    //设置stickData
    self.kdjChart.minDisplayNumber = 25;
    self.kdjChart.axisXColor = [UIColor darkGrayColor];
    self.kdjChart.axisYColor = [UIColor darkGrayColor];
    self.kdjChart.latitudeColor = [UIColor darkGrayColor];
    self.kdjChart.longitudeColor = [UIColor darkGrayColor];
    self.kdjChart.latitudeFontColor = [UIColor darkGrayColor];
    self.kdjChart.longitudeFontColor = [UIColor darkGrayColor];
    self.kdjChart.axisMarginLeft = 2;
    self.kdjChart.axisMarginRight = 58;
    self.kdjChart.axisMarginTop = 1;
    self.kdjChart.axisYPosition = CCSGridChartYAxisPositionRight;
    self.kdjChart.displayCrossXOnTouch = NO;
    self.kdjChart.displayCrossYOnTouch = NO;
    self.kdjChart.latitudeNum = 2;
    self.kdjChart.longitudeNum = 3;
    self.kdjChart.displayNumber = 50;
    self.kdjChart.displayFrom = 99;
    self.kdjChart.backgroundColor = [UIColor clearColor];

    [self.scrollViewBottomChart addSubview:self.kdjChart];
}

- (void)initRSIChart {
    CCSSlipLineChart *rsiChart = [[CCSSlipLineChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width * 3, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    rsiChart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.rsiChart = rsiChart;

    //初始化数据
    [self initRSIChartData];

    //设置stickData
    self.rsiChart.minDisplayNumber = 25;
    self.rsiChart.axisXColor = [UIColor darkGrayColor];
    self.rsiChart.axisYColor = [UIColor darkGrayColor];
    self.rsiChart.latitudeColor = [UIColor darkGrayColor];
    self.rsiChart.longitudeColor = [UIColor darkGrayColor];
    self.rsiChart.latitudeFontColor = [UIColor darkGrayColor];
    self.rsiChart.longitudeFontColor = [UIColor darkGrayColor];
    self.rsiChart.axisMarginLeft = 2;
    self.rsiChart.axisMarginRight = 58;
    self.rsiChart.axisMarginTop = 1;
    self.rsiChart.axisYPosition = CCSGridChartYAxisPositionRight;
    self.rsiChart.displayCrossXOnTouch = NO;
    self.rsiChart.displayCrossYOnTouch = NO;
    self.rsiChart.latitudeNum = 2;
    self.rsiChart.longitudeNum = 3;
    self.rsiChart.displayNumber = 50;
    self.rsiChart.displayFrom = 99;
    self.rsiChart.backgroundColor = [UIColor clearColor];

    [self.scrollViewBottomChart addSubview:self.rsiChart];
}

- (void)initRSIChartData {
    if (self.chartData != NULL) {

        NSMutableArray *linesData = [[NSMutableArray alloc] init];
        [linesData addObject:[self computeRSIData:self.chartData period:6]];
        [linesData addObject:[self computeRSIData:self.chartData period:12]];
        [linesData addObject:[self computeRSIData:self.chartData period:24]];

        self.rsiChart.linesData = linesData;
        self.rsiChart.singleTouchPoint = CGPointMake(-1, -1);

        [self.rsiChart setNeedsDisplay];
    }
}

- (void)initWRChart {
    CCSSlipLineChart *wrChart = [[CCSSlipLineChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width * 4, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    wrChart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.wrChart = wrChart;

    //初始化数据
    [self initWRChartData];

    //设置stickData
    self.wrChart.minDisplayNumber = 25;
    self.wrChart.axisXColor = [UIColor darkGrayColor];
    self.wrChart.axisYColor = [UIColor darkGrayColor];
    self.wrChart.latitudeColor = [UIColor darkGrayColor];
    self.wrChart.longitudeColor = [UIColor darkGrayColor];
    self.wrChart.latitudeFontColor = [UIColor darkGrayColor];
    self.wrChart.longitudeFontColor = [UIColor darkGrayColor];
    self.wrChart.axisMarginLeft = 2;
    self.wrChart.axisMarginRight = 58;
    self.wrChart.axisMarginTop = 1;
    self.wrChart.axisYPosition = CCSGridChartYAxisPositionRight;
    self.wrChart.displayCrossXOnTouch = NO;
    self.wrChart.displayCrossYOnTouch = NO;
    self.wrChart.latitudeNum = 2;
    self.wrChart.longitudeNum = 3;
    self.wrChart.displayNumber = 50;
    self.wrChart.displayFrom = 99;
    self.wrChart.noneDisplayValue = WR_NONE_DISPLAY;
    self.wrChart.backgroundColor = [UIColor clearColor];
    // self.wrChart.noneDisplayValue = 9999;

    [self.scrollViewBottomChart addSubview:self.wrChart];
}

- (void)initWRChartData {
    if (self.chartData != NULL) {
        self.wrChart.linesData = [self computeWRData:self.chartData period:6];
        self.wrChart.singleTouchPoint = CGPointMake(-1, -1);

        [self.wrChart setNeedsDisplay];
    }
}

- (void)initCCIChart {
    CCSSlipLineChart *cciChart = [[CCSSlipLineChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width * 5, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    cciChart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.cciChart = cciChart;

    //初始化数据
    [self initCCIChartData];

    //设置stickData
    self.cciChart.minDisplayNumber = 25;
    self.cciChart.axisXColor = [UIColor darkGrayColor];
    self.cciChart.axisYColor = [UIColor darkGrayColor];
    self.cciChart.latitudeColor = [UIColor darkGrayColor];
    self.cciChart.longitudeColor = [UIColor darkGrayColor];
    self.cciChart.latitudeFontColor = [UIColor darkGrayColor];
    self.cciChart.longitudeFontColor = [UIColor darkGrayColor];
    self.cciChart.axisMarginLeft = 2;
    self.cciChart.axisMarginRight = 58;
    self.cciChart.axisMarginTop = 1;
    self.cciChart.axisYPosition = CCSGridChartYAxisPositionRight;
    self.cciChart.displayCrossXOnTouch = NO;
    self.cciChart.displayCrossYOnTouch = NO;
    self.cciChart.latitudeNum = 2;
    self.cciChart.longitudeNum = 3;
    self.cciChart.displayNumber = 50;
    self.cciChart.displayFrom = 99;
    self.cciChart.backgroundColor = [UIColor clearColor];

    [self.scrollViewBottomChart addSubview:self.cciChart];
}

- (void)initCCIChartData {
    if (self.chartData != NULL) {

        self.cciChart.linesData = [self computeCCIData:self.chartData period:14];
        self.cciChart.singleTouchPoint = CGPointMake(-1, -1);

        [self.cciChart setNeedsDisplay];
    }
}

- (void)initBOLLChart {
    CCSSlipLineChart *bollChart = [[CCSSlipLineChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width * 6, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    bollChart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.bollChart = bollChart;

    //初始化数据
    [self initBOLLChartData];

    //设置stickData
    self.bollChart.minDisplayNumber = 25;
    self.bollChart.axisXColor = [UIColor darkGrayColor];
    self.bollChart.axisYColor = [UIColor darkGrayColor];
    self.bollChart.latitudeColor = [UIColor darkGrayColor];
    self.bollChart.longitudeColor = [UIColor darkGrayColor];
    self.bollChart.latitudeFontColor = [UIColor darkGrayColor];
    self.bollChart.longitudeFontColor = [UIColor darkGrayColor];
    self.bollChart.axisMarginLeft = 2;
    self.bollChart.axisMarginRight = 58;
    self.bollChart.axisMarginTop = 1;
    self.bollChart.axisYPosition = CCSGridChartYAxisPositionRight;
    self.bollChart.displayCrossXOnTouch = NO;
    self.bollChart.displayCrossYOnTouch = NO;
    self.bollChart.latitudeNum = 2;
    self.bollChart.longitudeNum = 3;
    self.bollChart.displayNumber = 50;
    self.bollChart.displayFrom = 99;
    self.bollChart.backgroundColor = [UIColor clearColor];

    [self.scrollViewBottomChart addSubview:self.bollChart];
}

- (void)initBOLLChartData {
    if (self.chartData != NULL) {
        self.bollChart.linesData = [self computeBOLLData:self.chartData];
        self.bollChart.singleTouchPoint = CGPointMake(-1, -1);

        [self.bollChart setNeedsDisplay];
    }
}

- (void)initCandleStickChartData {
    if (self.chartData != NULL) {
        NSMutableArray *stickDatas = [[NSMutableArray alloc] initWithCapacity:[self.chartData count]];
       // NSLog(@"initCandleStickChartData step 1 %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);

        for (NSInteger i = [self.chartData count] - 1; i >= 0; i--) {
            OHLCVDData *item = [self.chartData objectAtIndex:i];
            CCSCandleStickChartData *stickData = [[CCSCandleStickChartData alloc] init];
            stickData.open = [item.open doubleValue];
            stickData.high = [item.high doubleValue];
            stickData.low = [item.low doubleValue];
            stickData.close = [item.close doubleValue];
            stickData.change = 0;
            stickData.date = [item.date dateWithFormat:@"yyyyMMdd" target:@"yyyy/MM/dd"];
            //增加数据
            [stickDatas addObject:stickData];
            //  NSLog(@"initCandleStickChartData step loop %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);

        }
        NSMutableArray *maLines = [[NSMutableArray alloc] init];
        [maLines addObject:[self computeMAData:self.chartData period:5]];
        [maLines addObject:[self computeMAData:self.chartData period:25]];

        self.candleStickChart.stickData = stickDatas;
        self.candleStickChart.linesData = maLines;
        self.candleStickChart.bollingerBandData = [self computeBOLLData:self.chartData];

        self.candleStickChart.singleTouchPoint = CGPointMake(-1, -1);

        [self.candleStickChart setNeedsDisplay];
    //    NSLog(@"initCandleStickChartData step end %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);

    }
}

- (void)initCandleStickChart {
    CCSBOLLMASlipCandleStickChart *candleStickChart = [[CCSBOLLMASlipCandleStickChart alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, DEVICE_WIDTH, DEVICE_HEIGHT / 2)];

    self.candleStickChart = candleStickChart;
 //   NSLog(@"before initCandleStickChartData %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    [self initCandleStickChartData];
 //   NSLog(@"after initCandleStickChartData %@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
    //设置stickData
    candleStickChart.maxValue = 340;
    candleStickChart.minValue = 240;
    candleStickChart.axisCalc = 1;
    candleStickChart.displayLongitudeTitle = NO;
    candleStickChart.axisMarginBottom = 0;
    candleStickChart.minDisplayNumber = 25;
    candleStickChart.axisMarginLeft = 50;
    candleStickChart.userInteractionEnabled = YES;

    candleStickChart.axisXColor = [UIColor darkGrayColor];
    candleStickChart.axisYColor = [UIColor darkGrayColor];
    candleStickChart.latitudeColor = [UIColor darkGrayColor];
    candleStickChart.longitudeColor = [UIColor darkGrayColor];
    candleStickChart.latitudeFontColor = [UIColor darkGrayColor];
    candleStickChart.longitudeFontColor = [UIColor darkGrayColor];
    candleStickChart.axisMarginLeft = 2;
    candleStickChart.axisMarginRight = 58;
    candleStickChart.axisMarginBottom = 0;
    candleStickChart.axisMarginTop = 1;
    candleStickChart.axisYPosition = CCSGridChartYAxisPositionRight;
    candleStickChart.displayNumber = 50;
    candleStickChart.displayFrom = 99;
    candleStickChart.bollingerBandStyle = CCSBollingerBandStyleNone;

    candleStickChart.chartDelegate = self;

    [candleStickChart addTarget:self action:@selector(candleStickChartTouch:) forControlEvents:UIControlEventAllTouchEvents];

    self.candleStickChart.backgroundColor = [UIColor clearColor];

    [self.view addSubview:candleStickChart];
}

- (void)clearChart {
    self.lblOpen.textColor = [UIColor blackColor];
    self.lblOpen.text = @"-";
    self.lblClose.textColor = [UIColor blackColor];
    self.lblClose.text = @"-";
    self.lblHigh.textColor = [UIColor blackColor];
    self.lblHigh.text = @"-";
    self.lblLow.textColor = [UIColor blackColor];
    self.lblLow.text = @"-";
    self.lblVolume.textColor = [UIColor blackColor];
    self.lblVolume.text = @"-";
    self.lblDate.textColor = [UIColor blackColor];
    self.lblDate.text = @"-";
    self.lblChange.text = @"";
    self.lblPreClose.text = @"";
    self.lblSubTitle1.text = @"";
    self.lblSubTitle1.textColor = [UIColor blackColor];
    self.lblSubTitle2.text = @"";
    self.lblSubTitle2.textColor = [UIColor blackColor];
    self.lblSubTitle3.text = @"";
    self.lblSubTitle3.textColor = [UIColor blackColor];
    self.lblSubTitle4.text = @"";
    self.lblSubTitle4.textColor = [UIColor blackColor];
    self.lblSubTitle5.text = @"";
    self.lblSubTitle5.textColor = [UIColor blackColor];
    self.lblSubTitle6.text = @"";
    self.lblSubTitle6.textColor = [UIColor blackColor];
    self.lblSubTitle7.text = @"";
    self.lblSubTitle7.textColor = [UIColor blackColor];
    self.lblSubTitle8.text = @"";
    self.lblSubTitle8.textColor = [UIColor blackColor];
    self.lblSubTitle9.text = @"";
    self.lblSubTitle9.textColor = [UIColor blackColor];
    self.lblSubTitle10.text = @"";
    self.lblSubTitle10.textColor = [UIColor blackColor];
    self.stickChart.stickData = nil;
    self.stickChart.singleTouchPoint = CGPointMake(-1, -1);
    [self.stickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    self.macdChart.stickData = nil;
    self.macdChart.singleTouchPoint = CGPointMake(-1, -1);
    [self.macdChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    self.kdjChart.linesData = nil;
    self.kdjChart.singleTouchPoint = CGPointMake(-1, -1);
    [self.kdjChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    self.rsiChart.linesData = nil;
    self.rsiChart.singleTouchPoint = CGPointMake(-1, -1);
    [self.rsiChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    self.cciChart.linesData = nil;
    self.cciChart.singleTouchPoint = CGPointMake(-1, -1);
    [self.cciChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    self.bollChart.linesData = nil;
    self.bollChart.singleTouchPoint = CGPointMake(-1, -1);
    [self.bollChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    self.candleStickChart.stickData = nil;
    self.candleStickChart.linesData = nil;
    self.candleStickChart.bollingerBandData = nil;
    self.candleStickChart.singleTouchPoint = CGPointMake(-1, -1);
    [self.candleStickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
}

/******************************************************************************
 *   Method of Chart Compute By TALib
 ******************************************************************************/

- (CCSTitledLine *)computeMAData:(NSArray *)items period:(int)period {
    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:item.close];
    }
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);

    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * items.count);

    TA_RetCode ta_retCode = TA_MA(0,
                                  (int) (items.count - 1),
                                  inCls,
                                  period,
                                  TA_MAType_SMA,
                                  &outBegIdx,
                                  &outNBElement,
                                  outReal);

    NSMutableArray *maData = [[NSMutableArray alloc] init];

    if (TA_SUCCESS == ta_retCode) {
        NSArray *arr = CArrayToNSArray(outReal, (int) items.count, outBegIdx, outNBElement);

        for (NSInteger index = 0; index < arrCls.count; index++) {
            OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
            [maData addObject:[[CCSLineData alloc] initWithValue:[[arr objectAtIndex:index] doubleValue] date:item.date]];
        }
    }

    freeAndSetNULL(inCls);
    freeAndSetNULL(outReal);

    CCSTitledLine *maline = [[CCSTitledLine alloc] init];

    if (5 == period) {
        maline.title = @"MA5";
    } else if (25 == period) {
        maline.title = @"MA25";
    }

    if (5 == period) {
        maline.color = [UIColor cyanColor];
    } else if (25 == period) {
        maline.color = [UIColor magentaColor];
    }

    maline.data = maData;

    return maline;
}

- (NSMutableArray *)computeMACDData:(NSArray *)items {
    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:item.close];
    }
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);

    int outBegIdx = 0, outNBElement = 0;
    double *outMACD = malloc(sizeof(double) * items.count);
    double *outMACDSignal = malloc(sizeof(double) * items.count);
    double *outMACDHist = malloc(sizeof(double) * items.count);

    TA_RetCode ta_retCode = TA_MACD(0,
                                    (int) (items.count - 1),
                                    inCls,
                                    12,
                                    26,
                                    9,
                                    &outBegIdx,
                                    &outNBElement,
                                    outMACD,
                                    outMACDSignal,
                                    outMACDHist);

    NSMutableArray *MACDData = [[NSMutableArray alloc] init];

    if (TA_SUCCESS == ta_retCode) {

        NSArray *arrMACDSignal = CArrayToNSArray(outMACDSignal, (int) items.count, outBegIdx, outNBElement);
        NSArray *arrMACD = CArrayToNSArray(outMACD, (int) items.count, outBegIdx, outNBElement);
        NSArray *arrMACDHist = CArrayToNSArray(outMACDHist, (int) items.count, outBegIdx, outNBElement);

        for (NSInteger index = 0; index < arrCls.count; index++) {
            //两倍表示MACD
            OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
            [MACDData addObject:[[CCSMACDData alloc] initWithDea:[(NSString *) [arrMACDSignal objectAtIndex:index] doubleValue] * 1000000
                                                            diff:[(NSString *) [arrMACD objectAtIndex:index] doubleValue] * 1000000
                                                            macd:[(NSString *) [arrMACDHist objectAtIndex:index] doubleValue] * 2 * 1000000
                                                            date:item.date]];
        }
    }

    freeAndSetNULL(inCls);
    freeAndSetNULL(outMACD);
    freeAndSetNULL(outMACDSignal);
    freeAndSetNULL(outMACDHist);

    return MACDData;
}

- (NSMutableArray *)computeKDJData:(NSArray *)items {
    NSMutableArray *arrHigval = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrHigval addObject:item.high];
    }
    double *inHigval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrHigval, inHigval);

    NSMutableArray *arrLowval = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrLowval addObject:item.low];
    }
    double *inLowval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrLowval, inLowval);

    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:item.close];
    }
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);

    int outBegIdx = 0, outNBElement = 0;
    double *outSlowK = malloc(sizeof(double) * items.count);
    double *outSlowD = malloc(sizeof(double) * items.count);

    TA_RetCode ta_retCode = TA_STOCH(0,
                                     (int) (items.count - 1),
                                     inHigval,
                                     inLowval,
                                     inCls,
                                     9,
                                     3,
                                     TA_MAType_EMA,
                                     3,
                                     TA_MAType_EMA,
                                     &outBegIdx,
                                     &outNBElement,
                                     outSlowK,
                                     outSlowD);

    NSMutableArray *slowKLineData = [[NSMutableArray alloc] init];
    NSMutableArray *slowDLineData = [[NSMutableArray alloc] init];
    NSMutableArray *slow3K2DLineData = [[NSMutableArray alloc] init];

    if (TA_SUCCESS == ta_retCode) {
        NSArray *arrSlowK = CArrayToNSArray(outSlowK, (int) items.count, outBegIdx, outNBElement);
        NSArray *arrSlowD = CArrayToNSArray(outSlowD, (int) items.count, outBegIdx, outNBElement);

        for (NSInteger index = 0; index < arrCls.count; index++) {
            OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
            [slowKLineData addObject:[[CCSLineData alloc] initWithValue:[[arrSlowK objectAtIndex:index] doubleValue] date:item.date]];
            [slowDLineData addObject:[[CCSLineData alloc] initWithValue:[[arrSlowD objectAtIndex:index] doubleValue] date:item.date]];

            double slowKLine3k2d = 3 * [[arrSlowK objectAtIndex:index] doubleValue] - 2 * [[arrSlowD objectAtIndex:index] doubleValue];
            [slow3K2DLineData addObject:[[CCSLineData alloc] initWithValue:slowKLine3k2d date:item.date]];
        }
    }

    freeAndSetNULL(inHigval);
    freeAndSetNULL(inLowval);
    freeAndSetNULL(inCls);
    freeAndSetNULL(outSlowK);
    freeAndSetNULL(outSlowD);

    CCSTitledLine *slowKLine = [[CCSTitledLine alloc] init];
    slowKLine.data = slowKLineData;
    slowKLine.color = [UIColor redColor];
    slowKLine.title = @"K";

    CCSTitledLine *slowDLine = [[CCSTitledLine alloc] init];
    slowDLine.data = slowDLineData;
    slowDLine.color = [UIColor greenColor];
    slowDLine.title = @"D";

    CCSTitledLine *slow3K2DLine = [[CCSTitledLine alloc] init];
    slow3K2DLine.data = slow3K2DLineData;
    slow3K2DLine.color = [UIColor blueColor];
    slow3K2DLine.title = @"J";

    NSMutableArray *kdjData = [[NSMutableArray alloc] init];
    [kdjData addObject:slowKLine];
    [kdjData addObject:slowDLine];
    [kdjData addObject:slow3K2DLine];

    return kdjData;
}

- (CCSTitledLine *)computeRSIData:(NSArray *)items period:(int)period {
    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:item.close];
    }
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);

    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * items.count);

    TA_RetCode ta_retCode = TA_RSI(0,
                                   (int) (items.count - 1),
                                   inCls,
                                   period,
                                   &outBegIdx,
                                   &outNBElement,
                                   outReal);

    NSMutableArray *rsiLineData = [[NSMutableArray alloc] init];

    if (TA_SUCCESS == ta_retCode) {
        NSArray *arr = CArrayToNSArray(outReal, (int) items.count, outBegIdx, outNBElement);

        for (NSInteger index = 0; index < arrCls.count; index++) {
            OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
            [rsiLineData addObject:[[CCSLineData alloc] initWithValue:[[arr objectAtIndex:index] doubleValue] date:item.date]];
        }
    }

    freeAndSetNULL(inCls);
    freeAndSetNULL(outReal);

    CCSTitledLine *rsiLine = [[CCSTitledLine alloc] init];
    rsiLine.title = [NSString stringWithFormat:@"RSI%d", period];

    rsiLine.data = rsiLineData;

    if (6 == period) {
        rsiLine.color = [UIColor redColor];
    } else if (12 == period) {
        rsiLine.color = [UIColor greenColor];
    } else if (24 == period) {
        rsiLine.color = [UIColor blueColor];
    }

    return rsiLine;
}

- (NSMutableArray *)computeWRData:(NSArray *)items period:(int)period {
    NSMutableArray *arrHigval = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrHigval addObject:item.high];
    }
    double *inHigval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrHigval, inHigval);

    NSMutableArray *arrLowval = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrLowval addObject:item.low];
    }
    double *inLowval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrLowval, inLowval);

    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:item.close];
    }
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);

    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * items.count);

    TA_RetCode ta_retCode = TA_WILLR(0,
                                     (int) (items.count - 1),
                                     inHigval,
                                     inLowval,
                                     inCls,
                                     10,
                                     &outBegIdx,
                                     &outNBElement,
                                     outReal);

    NSMutableArray *wrLineData = [[NSMutableArray alloc] init];

    if (TA_SUCCESS == ta_retCode) {
        NSArray *arrWR = CArrayToNSArrayWithParameter(outReal, (int) items.count, outBegIdx, outNBElement, -WR_NONE_DISPLAY);

        for (NSInteger index = 0; index < arrCls.count; index++) {
            OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
            [wrLineData addObject:[[CCSLineData alloc] initWithValue:-([[arrWR objectAtIndex:index] doubleValue]) date:item.date]];
        }
    }


    freeAndSetNULL(inHigval);
    freeAndSetNULL(inLowval);
    freeAndSetNULL(inCls);
    freeAndSetNULL(outReal);

    CCSTitledLine *wrLine = [[CCSTitledLine alloc] init];
    wrLine.data = wrLineData;
    wrLine.color = [UIColor redColor];
    wrLine.title = @"WR";

    NSMutableArray *wrData = [[NSMutableArray alloc] init];
    [wrData addObject:wrLine];

    return wrData;
}

- (NSMutableArray *)computeCCIData:(NSArray *)items period:(int)period {
    NSMutableArray *arrHigval = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrHigval addObject:item.high];
    }
    double *inHigval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrHigval, inHigval);

    NSMutableArray *arrLowval = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrLowval addObject:item.low];
    }
    double *inLowval = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrLowval, inLowval);

    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:item.close];
    }
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);

    int outBegIdx = 0, outNBElement = 0;
    double *outReal = malloc(sizeof(double) * items.count);

    TA_RetCode ta_retCode = TA_CCI(0,
                                   (int) (items.count - 1),
                                   inHigval,
                                   inLowval,
                                   inCls,
                                   period,
                                   &outBegIdx,
                                   &outNBElement,
                                   outReal);

    NSMutableArray *cciLineData = [[NSMutableArray alloc] init];

    if (TA_SUCCESS == ta_retCode) {
        NSArray *arrCCI = CArrayToNSArray(outReal, (int) items.count, outBegIdx, outNBElement);

        for (NSInteger index = 0; index < arrCls.count; index++) {
            OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
            [cciLineData addObject:[[CCSLineData alloc] initWithValue:[[arrCCI objectAtIndex:index] doubleValue] date:item.date]];
        }
    }

    freeAndSetNULL(inHigval);
    freeAndSetNULL(inLowval);
    freeAndSetNULL(inCls);
    freeAndSetNULL(outReal);

    CCSTitledLine *cciLine = [[CCSTitledLine alloc] init];
    cciLine.data = cciLineData;
    cciLine.color = [UIColor redColor];
    cciLine.title = @"CCI";

    NSMutableArray *wrData = [[NSMutableArray alloc] init];
    [wrData addObject:cciLine];

    return wrData;
}

- (NSMutableArray *)computeBOLLData:(NSArray *)items {
    NSMutableArray *arrCls = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < items.count; index++) {
        OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
        [arrCls addObject:item.close];
    }
    double *inCls = malloc(sizeof(double) * items.count);
    NSArrayToCArray(arrCls, inCls);

    int outBegIdx = 0, outNBElement = 0;
    double *outRealUpperBand = malloc(sizeof(double) * items.count);
    double *outRealBollBand = malloc(sizeof(double) * items.count);
    double *outRealLowerBand = malloc(sizeof(double) * items.count);

    TA_RetCode ta_retCode = TA_BBANDS(0,
                                      (int) (items.count - 1),
                                      inCls,
                                      20,
                                      2,
                                      2,
                                      TA_MAType_SMA,
                                      &outBegIdx,
                                      &outNBElement,
                                      outRealUpperBand,
                                      outRealBollBand,
                                      outRealLowerBand);

    NSMutableArray *bollLinedataUPPER = [[NSMutableArray alloc] init];
    NSMutableArray *bollLinedataLOWER = [[NSMutableArray alloc] init];
    NSMutableArray *bollLinedataBOLL = [[NSMutableArray alloc] init];

    if (TA_SUCCESS == ta_retCode) {
        NSArray *arrUPPER = CArrayToNSArray(outRealUpperBand, (int) items.count, outBegIdx, outNBElement);
        NSArray *arrBOLL = CArrayToNSArray(outRealBollBand, (int) items.count, outBegIdx, outNBElement);
        NSArray *arrLOWER = CArrayToNSArray(outRealLowerBand, (int) items.count, outBegIdx, outNBElement);

        for (NSInteger index = 0; index < arrCls.count; index++) {
            OHLCVDData *item = [items objectAtIndex:items.count - 1 - index];
            [bollLinedataUPPER addObject:[[CCSLineData alloc] initWithValue:[[arrUPPER objectAtIndex:index] doubleValue] date:item.date]];
            [bollLinedataLOWER addObject:[[CCSLineData alloc] initWithValue:[[arrLOWER objectAtIndex:index] doubleValue] date:item.date]];
            [bollLinedataBOLL addObject:[[CCSLineData alloc] initWithValue:[[arrBOLL objectAtIndex:index] doubleValue] date:item.date]];
        }
    }

    freeAndSetNULL(inCls);
    freeAndSetNULL(outRealUpperBand);
    freeAndSetNULL(outRealBollBand);
    freeAndSetNULL(outRealLowerBand);

    CCSTitledLine *bollLineUPPER = [[CCSTitledLine alloc] init];
    bollLineUPPER.data = bollLinedataUPPER;
    bollLineUPPER.color = [UIColor yellowColor];
    bollLineUPPER.title = @"UPPER";

    CCSTitledLine *bollLineLOWER = [[CCSTitledLine alloc] init];
    bollLineLOWER.data = bollLinedataLOWER;
    bollLineLOWER.color = [UIColor purpleColor];
    bollLineLOWER.title = @"LOWER";

    CCSTitledLine *bollLineBOLL = [[CCSTitledLine alloc] init];
    bollLineBOLL.data = bollLinedataBOLL;
    bollLineBOLL.color = [UIColor greenColor];
    bollLineBOLL.title = @"BOLL";

    NSMutableArray *bollBanddata = [[NSMutableArray alloc] init];

    [bollBanddata addObject:bollLineUPPER];
    [bollBanddata addObject:bollLineLOWER];
    [bollBanddata addObject:bollLineBOLL];

    return bollBanddata;
}

- (void)CCSChartBeTouchedOn:(CGPoint)point indexAt:(NSUInteger)index {
    if (0 == self.segBottomChartType.selectedSegmentIndex) {
        self.stickChart.singleTouchPoint = point;
        self.stickChart.selectedStickIndex = index;
        [self.stickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (1 == self.segBottomChartType.selectedSegmentIndex) {
        self.macdChart.singleTouchPoint = point;
        self.macdChart.selectedStickIndex = index;
        [self.macdChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (2 == self.segBottomChartType.selectedSegmentIndex) {
        self.kdjChart.singleTouchPoint = point;
        [self.kdjChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (3 == self.segBottomChartType.selectedSegmentIndex) {
        self.rsiChart.singleTouchPoint = point;
        [self.rsiChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (4 == self.segBottomChartType.selectedSegmentIndex) {
        self.wrChart.singleTouchPoint = point;
        [self.wrChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (5 == self.segBottomChartType.selectedSegmentIndex) {
        self.cciChart.singleTouchPoint = point;
        [self.cciChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (6 == self.segBottomChartType.selectedSegmentIndex) {
        self.bollChart.singleTouchPoint = point;
        [self.bollChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    }
}

- (void)CCSChartDisplayChangedFrom:(NSUInteger)from number:(NSUInteger)number; {
    if (0 == self.segBottomChartType.selectedSegmentIndex) {
        self.stickChart.displayFrom = from;
        self.stickChart.displayNumber = number;
        [self.stickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (1 == self.segBottomChartType.selectedSegmentIndex) {
        self.macdChart.displayFrom = from;
        self.macdChart.displayNumber = number;
        [self.macdChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (2 == self.segBottomChartType.selectedSegmentIndex) {
        self.kdjChart.displayFrom = from;
        self.kdjChart.displayNumber = number;
        [self.kdjChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (3 == self.segBottomChartType.selectedSegmentIndex) {
        self.rsiChart.displayFrom = from;
        self.rsiChart.displayNumber = number;
        [self.rsiChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (4 == self.segBottomChartType.selectedSegmentIndex) {
        self.wrChart.displayFrom = from;
        self.wrChart.displayNumber = number;
        [self.wrChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (5 == self.segBottomChartType.selectedSegmentIndex) {
        self.cciChart.displayFrom = from;
        self.cciChart.displayNumber = number;
        [self.cciChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    } else if (6 == self.segBottomChartType.selectedSegmentIndex) {
        self.bollChart.displayFrom = from;
        self.bollChart.displayNumber = number;
        [self.bollChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // 得到每页宽度
    CGFloat pageWidth = sender.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    int page = (int) floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    //判断是否page发生了变更
    if (self.segBottomChartType.selectedSegmentIndex != page) {
        //设置pageControl
        self.segBottomChartType.selectedSegmentIndex = page;
        [self.segBottomChartType setNeedsDisplay];
    }
}

@end
