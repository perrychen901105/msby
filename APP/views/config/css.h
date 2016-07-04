/*!
 @header css.h
 @abstract 样式表常量及有关UI界面相关宏方法
 @author .
 @version 1.00 2015/01/01  (1.00)
 */

#ifndef CSS_h
#define CSS_h



/**
 *  所有涉及颜色，字体，字体大小必须按格式调用
 */
#define kShadowAlpha    0.6

/**
 *  颜色样式表
 *  根据UI色表定义
 */

//新规范色
#define qwColor1    0x1975cf    // 原来的3色 基础色
#define qwColor2    0xff9402    // 用于按钮，优惠信息，交互反馈色
#define qwColor3    0xff5000    // 用于疯抢，优惠，未读消息背景色等标签底色
#define qwColor4    0xffffff    // 用于反白
#define qwColor5    0x00a0ff    // 用于链接
#define qwColor6    0x333333    // 用于标题，正文
#define qwColor7    0x666666    // 用于菜单，列表文字
#define qwColor8    0x999999    // 用于说明文字，提示文案
#define qwColor9    0xcccccc    // 用于搜索框，输入框默认提示，次要文字，无效文字
#define qwColor10   0xe4e4e4    // 用于分割线，按钮描边
#define qwColor11   0xf6f8fb    // 用于cell背景色
#define qwColor12   0xff6600    // 其他 橘黄
#define qwColor13   0x70bcee    // 其他 淡蓝
#define qwColor14   0x8ccf70    // 其他 淡绿
#define qwColor15   0xffbe5a    // 其他 淡黄
#define qwColor16   0xfef7db    // 其他 超淡黄
#define qwColor17   0x000000    // 深黑
#define qwColor18   0xfafafa    // 淡灰
#define qwColor19   0xfffdf6    // 超超超淡黄
#define qwColor20   0xc2c2c2
#define qwColor21   0xf2f4f7    // 用于大背景色
#define qwColor22   0xc0c5d0    // 用于空态页文字
#define qwColor23   0xfff7dc    // 用于公告提示背景色
#define qwColor24   0x9e8052    // 用于公告提示文字
#define qwColor25   0xfcfcfc    // 用于输入框背景色
#define qwColor26   0xfda1a4    // 淡红





/**
 *  文字样式表
 */
#define kFont1 @"Helvetica"
#define kFont2 @"Helvetica-Bold"


/**
 *  文字大小
 */
#define kFontS1     15
#define kFontS2     17
#define kFontS3     16
#define kFontS4     14
#define kFontS5     12
#define kFontS6     11
#define kFontS7     65
#define kFontS8     27
#define kFontS9     9       //add by lijian at 2.2.4
#define kFontS10    20      //add by lijian at 2.2.4
#define kFontS11    13      //add by perry at 3.0.0
#define kFontS12    25
#define kFontS13    18
#define kFontS14    57


#endif




#define HIGH_RESOLUTION             ([UIScreen mainScreen].bounds.size.height > 480)

#define TAG_BASE            100000

#define NAV_H               44
#define TAB_H               49

#define MAX_SIZE 130 //　图片最大显示大小