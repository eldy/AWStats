#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Calendar Auto Plugin for AWStats
# 根据用户语言自动显示不同历法的日期
# 支持：日本年号、佛历、民国纪年、甲子纪年、檀君纪年、
#       伊斯兰历、波斯历、缅甸历、维克拉姆历、萨卡历、
#       埃塞俄比亚历、孟加拉历、蒙古历（生肖）、希伯来历
# 使用 PO 文件中的翻译键，无任何硬编码文字
#-----------------------------------------------------------------------------
use utf8;
#use Encode;

binmode(STDOUT, ':encoding(utf-8)');
binmode(STDERR, ':encoding(utf-8)');

push @INC, "${DIR}/plugins";
no strict "refs";

my $PluginNeedAWStatsVersion="8.0";
my $PluginHooksFunctions="FormatDate FormatMonth FormatYear GetDaysInMonth GetMaxMonth is_valid_calendar_day";
my $PluginName = "localdate";
my $PluginImplements = "o";

use vars qw/
%TmpDateCache
%TmpMonthCache
%TmpYearCache
%TmpDaysCache
$CalendarMode
/;

# 天干地支（用于甲子纪年）
my @tiangan = qw(甲 乙 丙 丁 戊 己 庚 辛 壬 癸);
my @dizhi   = qw(子 丑 寅 卯 辰 巳 午 未 申 酉 戌 亥);
my @shengxiao = qw(鼠 牛 虎 兔 龙 蛇 马 羊 猴 鸡 狗 猪);

# 越南语生肖（兔→猫）
my @shengxiao_vi = qw(鼠 牛 虎 猫 龙 蛇 马 羊 猴 鸡 狗 猪);

# 希伯来月份名称（用于伊斯兰历风格显示）
my @hebrew_months = qw(
    Nisan Iyar Sivan Tammuz Av Elul
    Tishrei Cheshvan Kislev Tevet Shevat Adar
);
my @hebrew_months_leap = qw(
    Nisan Iyar Sivan Tammuz Av Elul
    Tishrei Cheshvan Kislev Tevet Shevat AdarI AdarII
);

# 每个年号包含：序号、起始年份、起始月份、起始日期
# 日本年号列表（从令和开始，按时间顺序）
# 未来新年号只需在这里填写正确数据并取消前面的注释
# 并在 awstats-ja.po 文件中添加对应的翻译键（calendar_era_序号）

# 各年号には以下の情報が含まれます：インデックス、開始年、開始月、開始日
# 日本の年号リスト（令和から開始、時系列順）
# 将来の新年号は、以下の正しいデータを入力し、対応する行のコメントを解除するだけです
# さらに、awstats-ja.po ファイルに対応する翻訳キーを追加してください（calendar_era_2、calendar_era_3、calendar_era_4、calendar_era_5...）

# Each era contains: index, start year, start month, start day
# Japanese era list (starting from Reiwa, in chronological order)
# For future new eras, just fill in the correct data below and uncomment the corresponding lines
# Also add corresponding translation keys in the awstats-ja.po file (calendar_era_2, calendar_era_3, calendar_era_4, calendar_era_5...)
my @japanese_eras = (
    { index => 1, start_year => 2019, start_month => 5, start_day => 1 },
    #{ index => 2, start_year => 203x, start_month => 6, start_day => 8 },
    #{ index => 3, start_year => 206x, start_month => 5, start_day => 9 },
    #{ index => 4, start_year => 210x, start_month => 5, start_day => 9 },
    #{ index => 5, start_year => 213x, start_month => 5, start_day => 9 },
    #{ index => 6, start_year => 216x, start_month => 5, start_day => 9 },
    #{ index => 7, start_year => 220x, start_month => 5, start_day => 9 },
);

#-----------------------------------------------------------------------------
# 初始化
#-----------------------------------------------------------------------------
sub Init_localdate {
    my $InitParams = shift;
    
    my $checkversion = &Check_Plugin_Version($PluginNeedAWStatsVersion);
    
    print STDERR "[localdate] Plugin Init called\n";
    print STDERR "[localdate] InitParams: '$InitParams'\n";
    print STDERR "[localdate] AWStats version check: " . ($checkversion ? $checkversion : "OK") . "\n";
    
    %TmpDateCache = ();
    %TmpMonthCache = ();
    %TmpYearCache = ();
    %TmpDaysCache = ();
    $CalendarMode = $InitParams || 'auto';
    
    print STDERR "[localdate] CalendarMode set to: $CalendarMode\n";
    print STDERR "[localdate] Plugin loaded successfully!\n";
    print STDERR "[localdate] Hooks registered: $PluginHooksFunctions\n";
    
    return ($checkversion ? $checkversion : "$PluginHooksFunctions");
}

#-----------------------------------------------------------------------------
# 根据语言获取历法类型
#-----------------------------------------------------------------------------
sub get_calendar_type {
    my $lang = shift;
    
    # 强制模式
    if ($CalendarMode eq 'japanese')      { return 'japanese'; }
    if ($CalendarMode eq 'buddhist')      { return 'buddhist'; }
    if ($CalendarMode eq 'minguo')        { return 'minguo'; }
    if ($CalendarMode eq 'dangun')        { return 'dangun'; }
    if ($CalendarMode eq 'islamic')       { return 'islamic'; }
    if ($CalendarMode eq 'persian')       { return 'persian'; }
    if ($CalendarMode eq 'burmese')       { return 'burmese'; }
    if ($CalendarMode eq 'vikram')        { return 'vikram'; }
    if ($CalendarMode eq 'saka')          { return 'saka'; }
    if ($CalendarMode eq 'ethiopian')     { return 'ethiopian'; }
    if ($CalendarMode eq 'bangladesh')    { return 'bangladesh'; }
    if ($CalendarMode eq 'hebrew')        { return 'hebrew'; }
    if ($CalendarMode eq 'mongolian')     { return 'mongolian'; }
    
    # 自动模式
    if ($lang eq 'ja' || $lang eq 'jp') {
        return 'japanese';
    }
    if ($lang eq 'th' || $lang eq 'km' || $lang eq 'lo') {
        return 'buddhist';
    }
    if ($lang eq 'zh-tw' || $lang eq 'zh-hk' || $lang eq 'zh-mo' || $lang eq 'tw') {
        return 'minguo';
    }
    if ($lang eq 'zh-cn' || $lang eq 'zh-sg' || $lang eq 'cn') {
        return 'ganzhi';
    }
    if ($lang eq 'mn') {
        return 'mongolian';
    }
    if ($lang eq 'ko') {
        return 'dangun';
    }
    if ($lang eq 'vi') {
        return 'vietnamese';
    }
    
    # 其他语言历法
    if ($lang eq 'ar' || $lang eq 'sa' || $lang eq 'ug') {
        return 'islamic';
    }
    if ($lang eq 'fa' || $lang eq 'ir') {
        return 'persian';
    }
    if ($lang eq 'my' || $lang eq 'mm') {
        return 'burmese';
    }
    if ($lang eq 'ne' || $lang eq 'np') {
        return 'vikram';
    }
    if ($lang eq 'hi' || $lang eq 'in') {
        return 'saka';
    }
    if ($lang eq 'am' || $lang eq 'et') {
        return 'ethiopian';
    }
    if ($lang eq 'bn' || $lang eq 'bd') {
        return 'bangladesh';
    }
    if ($lang eq 'he' || $lang eq 'iw') {
        return 'hebrew';
    }
    if ($lang eq 'ur' || $lang eq 'pk') {
        return 'islamic';
    }
    
    return 'gregorian';
}

#-----------------------------------------------------------------------------
# 公历年份转甲子纪年（中国/越南通用）
# 1984年是甲子年（天干索引0，地支索引0）
#-----------------------------------------------------------------------------
sub gregorian_to_ganzhi {
    my ($year, $lang) = @_;
    my $gan_index = ($year - 4) % 10;
    my $zhi_index = ($year - 4) % 12;
    my $gan = $tiangan[$gan_index];
    my $zhi = $dizhi[$zhi_index];
    
    my $shengxiao;
    if ($lang eq 'vi') {
        $shengxiao = $shengxiao_vi[$zhi_index];
    } else {
        $shengxiao = $shengxiao[$zhi_index];
    }
    
    return ($gan, $zhi, $shengxiao);
}

#-----------------------------------------------------------------------------
# 日本年号转换
# 根据公历日期返回年号序号和年号内年份
#-----------------------------------------------------------------------------
sub convert_japanese {
    my ($year, $month, $day) = @_;
    
    for my $era (reverse @japanese_eras) {
        if ($year > $era->{start_year} ||
            ($year == $era->{start_year} && 
             ($month > $era->{start_month} ||
              ($month == $era->{start_month} && $day >= $era->{start_day})))) {
            my $era_year = $year - $era->{start_year} + 1;
            return ($era->{index}, $era_year);
        }
    }
    return (0, $year);
}

#-----------------------------------------------------------------------------
# 佛历转换（泰国、柬埔寨、老挝）
# 佛历 = 公历 + 543
#-----------------------------------------------------------------------------
sub convert_buddhist {
    my ($year, $month, $day) = @_;
    return ($year + 543);
}

#-----------------------------------------------------------------------------
# 民国纪年转换（台湾）
# 民国 = 公历 - 1911
#-----------------------------------------------------------------------------
sub convert_minguo {
    my ($year, $month, $day) = @_;
    return ($year - 1911);
}

#-----------------------------------------------------------------------------
# 檀君纪年转换（韩国）
# 檀君纪年 = 公历 + 2333
#-----------------------------------------------------------------------------
sub convert_dangun {
    my ($year, $month, $day) = @_;
    return ($year + 2333);
}

#-----------------------------------------------------------------------------
# 伊斯兰历转换（纯阴历，近似计算）
# 伊斯兰历 ≈ (公历 - 622) × 1.0309
#-----------------------------------------------------------------------------
sub convert_islamic {
    my ($year, $month, $day) = @_;
    my $islamic_year = int(($year - 622) * 1.0309);
    return ($islamic_year);
}

#-----------------------------------------------------------------------------
# 波斯历转换（太阳历）
# 波斯历 = 公历 - 621（3月20/21日春分后）
#-----------------------------------------------------------------------------
sub convert_persian {
    my ($year, $month, $day) = @_;
    
    if ($month > 3 || ($month == 3 && $day >= 20)) {
        return ($year - 621);
    } else {
        return ($year - 622);
    }
}

#-----------------------------------------------------------------------------
# 缅甸历转换
# 缅甸历 = 公历 - 638
# 公元638年为缅甸历元年
#-----------------------------------------------------------------------------
sub convert_burmese {
    my ($year, $month, $day) = @_;
    return ($year - 638);
}

#-----------------------------------------------------------------------------
# 维克拉姆历转换（尼泊尔）
# 维克拉姆历 = 公历 + 56（4月13/14日后+57）
# 公元前57年为维克拉姆历元年
#-----------------------------------------------------------------------------
sub convert_vikram {
    my ($year, $month, $day) = @_;
    
    # 4月中旬（约4月13/14日）为维克拉姆历新年
    if ($month > 4 || ($month == 4 && $day >= 13)) {
        return ($year + 57);
    } else {
        return ($year + 56);
    }
}

#-----------------------------------------------------------------------------
# 萨卡历转换（印度）
# 萨卡历 = 公历 - 78（3月21/22日后）
# 公元78年为萨卡历元年
#-----------------------------------------------------------------------------
sub convert_saka {
    my ($year, $month, $day) = @_;
    
    # 3月21/22日为萨卡历新年
    if ($month > 3 || ($month == 3 && $day >= 21)) {
        return ($year - 78);
    } else {
        return ($year - 79);
    }
}

#-----------------------------------------------------------------------------
# 埃塞俄比亚历转换
# 埃塞俄比亚历 = 公历 - 8（9月11/12日后）
# 公元8年为埃塞俄比亚历元年
#-----------------------------------------------------------------------------
sub convert_ethiopian {
    my ($year, $month, $day) = @_;
    
    # 9月11/12日为埃塞俄比亚历新年
    if ($month > 9 || ($month == 9 && $day >= 11)) {
        return ($year - 8);
    } else {
        return ($year - 9);
    }
}

#-----------------------------------------------------------------------------
# 孟加拉历转换
# 孟加拉历 = 公历 - 593
# 公元593年为孟加拉历元年
#-----------------------------------------------------------------------------
sub convert_bangladesh {
    my ($year, $month, $day) = @_;
    return ($year - 593);
}

#-----------------------------------------------------------------------------
# 希伯来历闰年判断（19年周期，第3、6、8、11、14、17、19年为闰年）
#-----------------------------------------------------------------------------
sub is_hebrew_leap_year {
    my $year = shift;
    my $position = $year % 19;
    return ($position == 0 || $position == 3 || $position == 6 ||
            $position == 8 || $position == 11 || $position == 14 ||
            $position == 17);
}

#-----------------------------------------------------------------------------
# 希伯来历月份天数
# 普通年：353-355天，闰年：383-385天
#-----------------------------------------------------------------------------
sub get_hebrew_month_days {
    my ($month, $year) = @_;
    my $is_leap = is_hebrew_leap_year($year);
    
    # 月份天数表（希伯来历月份从1开始：Nisan=1）
    my @days_common = (30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29);
    my @days_leap   = (30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29);
    
    if ($is_leap) {
        return $days_leap[$month - 1] if $month <= 13;
    } else {
        return $days_common[$month - 1] if $month <= 12;
    }
    return 30;
}

#-----------------------------------------------------------------------------
# 公历转希伯来历（简化算法，用于年份转换）
# 希伯来历元年 = 公历 3761年（公元前3761年）
# 新年在9月左右，需要根据月份调整
#-----------------------------------------------------------------------------
sub convert_hebrew {
    my ($year, $month, $day) = @_;
    
    # 希伯来历元年对应公历3761年
    # 新年在公历9月左右，所以9月前用去年年份，9月后用今年年份
    my $hebrew_year = $year + 3760;
    if ($month < 9) {
        $hebrew_year--;
    }
    
    return ($hebrew_year);
}

#-----------------------------------------------------------------------------
# 获取年号显示名称（使用翻译键）
# 参数：年号序号（数字）、年号内年份、语言
#-----------------------------------------------------------------------------
sub get_era_name {
    my ($era_index, $era_year, $lang) = @_;
    
    return "" unless $era_index && $era_index > 0;
    
    my $era_name = _t("calendar_era_$era_index");
    
    if ($era_year == 1) {
        return $era_name . _t("calendar_era_first_year");
    } else {
        return $era_name . $era_year . _t("Year");
    }
}

#-----------------------------------------------------------------------------
# 格式化数字（添加千位分隔符）
#-----------------------------------------------------------------------------
sub format_number {
    my $num = shift;
    return Format_Number($num);
}

#-----------------------------------------------------------------------------
# 公历闰年判断
#-----------------------------------------------------------------------------
sub is_leap_year_gregorian {
    my $year = shift;
    return ($year % 4 == 0 && $year % 100 != 0) || ($year % 400 == 0);
}

#-----------------------------------------------------------------------------
# 公历月份天数
#-----------------------------------------------------------------------------
sub get_gregorian_days {
    my ($month, $year) = @_;
    my @days_in_month = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    if ($month == 2 && is_leap_year_gregorian($year)) {
        return 29;
    }
    return $days_in_month[$month - 1];
}

#-----------------------------------------------------------------------------
# 伊斯兰历月份天数
# 奇数月30天，偶数月29天（实际与月亮观测有关，此为近似计算）
#-----------------------------------------------------------------------------
sub get_islamic_days {
    my ($month, $year) = @_;
    if ($month % 2 == 1) {
        return 30;
    } else {
        return 29;
    }
}

#-----------------------------------------------------------------------------
# 波斯历月份天数
# 前6个月31天，后5个月30天，最后一个月闰年30天平年29天
#-----------------------------------------------------------------------------
sub get_persian_days {
    my ($month, $year) = @_;
    
    if ($month <= 6) {
        return 31;
    } elsif ($month <= 11) {
        return 30;
    } else {
        my $persian_year = $year - 621;
        my $is_leap = (($persian_year - 1375) % 33) == 0 || 
                      (($persian_year - 1375 + 1) % 33) == 0;
        return $is_leap ? 30 : 29;
    }
}

#-----------------------------------------------------------------------------
# 埃塞俄比亚历月份天数
# 前12个月30天，第13个月闰年6天平年5天
#-----------------------------------------------------------------------------
sub get_ethiopian_days {
    my ($month, $year) = @_;
    
    if ($month <= 12) {
        return 30;
    } else {
        my $eth_year = convert_ethiopian($year, $month, 1);
        my $is_leap = ($eth_year % 4 == 0);
        return $is_leap ? 6 : 5;
    }
}

#-----------------------------------------------------------------------------
# 希伯来历月份天数（调用已有函数）
#-----------------------------------------------------------------------------
sub get_hebrew_days {
    my ($month, $year) = @_;
    return get_hebrew_month_days($month, $year);
}

#-----------------------------------------------------------------------------
# 获取最大月份数（埃塞俄比亚历返回13，希伯来历闰年返回13）
#-----------------------------------------------------------------------------
sub GetMaxMonth_localdate {
    my ($lang, $year) = @_;
    $year = $YearRequired unless $year;
    
    my $calendar_type = get_calendar_type($lang);
    return 13 if $calendar_type eq 'ethiopian';
    if ($calendar_type eq 'hebrew') {
        my $hebrew_year = convert_hebrew($year, 1, 1);
        return is_hebrew_leap_year($hebrew_year) ? 13 : 12;
    }
    return 12;
}

#-----------------------------------------------------------------------------
# 获取指定历法的月份天数
# 参数：月份（1-12/13）、公历年份、语言
# 返回：该月天数
#-----------------------------------------------------------------------------
sub get_calendar_days {
    my ($month, $year, $lang) = @_;
    
    my $calendar_type = get_calendar_type($lang);
    
    if ($calendar_type eq 'islamic') {
        return get_islamic_days($month, $year);
    }
    elsif ($calendar_type eq 'persian') {
        return get_persian_days($month, $year);
    }
    elsif ($calendar_type eq 'ethiopian') {
        return get_ethiopian_days($month, $year);
    }
    elsif ($calendar_type eq 'hebrew') {
        my $hebrew_year = convert_hebrew($year, $month, 1);
        return get_hebrew_days($month, $hebrew_year);
    }
    else {
        return get_gregorian_days($month, $year);
    }
}

#-----------------------------------------------------------------------------
# 钩子：获取指定月份的天数（供 HTMLMainDaily 调用）
# 参数：月份（1-12/13）、公历年份、语言
# 返回：该月天数
#-----------------------------------------------------------------------------
sub GetDaysInMonth_localdate {
    my ($month, $year, $lang) = @_;
    
    my $cache_key = "${year}_${month}_${lang}";
    return $TmpDaysCache{$cache_key} if $TmpDaysCache{$cache_key};
    
    my $days = get_calendar_days($month, $year, $lang);
    $TmpDaysCache{$cache_key} = $days;
    
    return $days;
}

#-----------------------------------------------------------------------------
# 钩子：格式化完整日期
# 使用 dateformat_long 或 dateformat_short
#-----------------------------------------------------------------------------
sub FormatDate_localdate {
    my ($timestamp, $lang, $option) = @_;
    
    if (!defined $TmpDateCache{'debug'}) {
        print STDERR "[localdate] FormatDate called first time\n";
        print STDERR "[localdate] timestamp: $timestamp, lang: $lang, option: $option\n";
        $TmpDateCache{'debug'} = 1;
    }
    
    my $format_type = (defined $option && $option == 0) ? 'long' : 'short';
    
    my $cache_key = "${timestamp}_${lang}_${format_type}";
    return $TmpDateCache{$cache_key} if $TmpDateCache{$cache_key};
    
    # 解析时间戳（格式：YYYYMMDDHHMMSS）
    my $year  = substr($timestamp, 0, 4);
    my $month = substr($timestamp, 4, 2);
    my $day   = substr($timestamp, 6, 2);
    my $hour  = substr($timestamp, 8, 2);
    my $min   = substr($timestamp, 10, 2);
    my $sec   = substr($timestamp, 12, 2);
    
    $month =~ s/^0//;
    $day   =~ s/^0//;
    
    my $calendar_type = get_calendar_type($lang);
    my $display_year = $year;
    my $era_name = "";
    
    if ($calendar_type eq 'japanese') {
        my ($era_index, $era_year) = convert_japanese($year, $month, $day);
        if ($era_index) {
            $display_year = $era_year;
            $era_name = get_era_name($era_index, $era_year, $lang);
        }
    }
    elsif ($calendar_type eq 'buddhist') {
        $display_year = convert_buddhist($year, $month, $day);
    }
    elsif ($calendar_type eq 'minguo') {
        $display_year = convert_minguo($year, $month, $day);
    }
    elsif ($calendar_type eq 'dangun') {
        $display_year = convert_dangun($year, $month, $day);
    }
    elsif ($calendar_type eq 'islamic') {
        $display_year = convert_islamic($year, $month, $day);
    }
    elsif ($calendar_type eq 'persian') {
        $display_year = convert_persian($year, $month, $day);
    }
    elsif ($calendar_type eq 'burmese') {
        $display_year = convert_burmese($year, $month, $day);
    }
    elsif ($calendar_type eq 'vikram') {
        $display_year = convert_vikram($year, $month, $day);
    }
    elsif ($calendar_type eq 'saka') {
        $display_year = convert_saka($year, $month, $day);
    }
    elsif ($calendar_type eq 'ethiopian') {
        $display_year = convert_ethiopian($year, $month, $day);
    }
    elsif ($calendar_type eq 'bangladesh') {
        $display_year = convert_bangladesh($year, $month, $day);
    }
    elsif ($calendar_type eq 'hebrew') {
        $display_year = convert_hebrew($year, $month, $day);
    }
    
    # 获取日期格式模板
    my $date_format = ($format_type eq 'short') ? _t("dateformat_short") : _t("dateformat_long");
    
    # 替换模板中的占位符
    my $result = $date_format;
    $result =~ s/yyyy/$display_year/g;
    $result =~ s/mm/sprintf("%02d", $month)/eg;
    $result =~ s/dd/sprintf("%02d", $day)/eg;
    $result =~ s/HH/$hour/eg;
    $result =~ s/MM/$min/eg;
    $result =~ s/SS/$sec/eg;
    
    # 如果有年号，在年份前添加
    if ($era_name) {
        my $year_unit = _t("Year");
        if ($year_unit) {
            $result =~ s/(\d+$year_unit)/$era_name$1/;
        } else {
            $result =~ s/(\d{4})/$era_name$1/;
        }
    }
    
    # 简体中文/越南语：附加甲子纪年（仅长格式）
    if (($calendar_type eq 'ganzhi' || $calendar_type eq 'vietnamese') && $format_type eq 'long') {
        my ($gan, $zhi, $shengxiao) = gregorian_to_ganzhi($year, $lang);
        my $year_unit = _t("Year");
        my $ganzhi = "${gan}${zhi}${shengxiao}$year_unit";
        $result .= " $ganzhi";
    }
    
    # 蒙古语：附加生肖年份（仅长格式）
    if ($calendar_type eq 'mongolian' && $format_type eq 'long') {
        my ($gan, $zhi, $shengxiao) = gregorian_to_ganzhi($year, $lang);
        my $year_unit = _t("Year");
        $result .= " $shengxiao$year_unit";
    }
    
    $TmpDateCache{$cache_key} = $result;
    return $result;
}

#-----------------------------------------------------------------------------
# 获取伊斯兰历月份名称
#-----------------------------------------------------------------------------
sub get_islamic_month_name {
    my ($month_num, $lang) = @_;
    
    my %islamic_months = (
        1 => "محرم",
        2 => "صفر",
        3 => "ربيع الأول",
        4 => "ربيع الآخر",
        5 => "جمادى الأولى",
        6 => "جمادى الآخرة",
        7 => "رجب",
        8 => "شعبان",
        9 => "رمضان",
        10 => "شوال",
        11 => "ذو القعدة",
        12 => "ذو الحجة",
    );
    
    return $islamic_months{$month_num} || "محرم";
}

#-----------------------------------------------------------------------------
# 获取希伯来历月份名称
#-----------------------------------------------------------------------------
sub get_hebrew_month_name {
    my ($month_num, $lang, $year) = @_;
    my $is_leap = 0;
    if ($year) {
        $is_leap = is_hebrew_leap_year($year);
    }
    my $month_key = sprintf("%02d", $month_num);
    if ($is_leap && $month_num <= 13) {
        return _t("month_$month_key") || $hebrew_months_leap[$month_num - 1];
    } else {
        return _t("month_$month_key") || $hebrew_months[$month_num - 1];
    }
}

#-----------------------------------------------------------------------------
# 钩子：格式化月份
#-----------------------------------------------------------------------------
sub FormatMonth_localdate {
    my ($month_num, $year, $lang, $skip_ganzhi) = @_;
    
    my $cache_key = "${year}_${month_num}_${lang}_${skip_ganzhi}";
    return $TmpMonthCache{$cache_key} if $TmpMonthCache{$cache_key};
    
    $month_num =~ s/^0//;
    
    my $month_key = sprintf("%02d", $month_num);
    
    my $calendar_type = get_calendar_type($lang);
    my $display_year = $year;
    my $era_name = "";
    
    if ($calendar_type eq 'japanese') {
        my ($era_index, $era_year) = convert_japanese($year, $month_num, 1);
        if ($era_index) {
            $display_year = $era_year;
            $era_name = get_era_name($era_index, $era_year, $lang);
        }
    }
    elsif ($calendar_type eq 'buddhist') {
        $display_year = convert_buddhist($year, $month_num, 1);
    }
    elsif ($calendar_type eq 'minguo') {
        $display_year = convert_minguo($year, $month_num, 1);
    }
    elsif ($calendar_type eq 'dangun') {
        $display_year = convert_dangun($year, $month_num, 1);
    }
    elsif ($calendar_type eq 'islamic') {
        $display_year = convert_islamic($year, $month_num, 1);
    }
    elsif ($calendar_type eq 'persian') {
        $display_year = convert_persian($year, $month_num, 1);
    }
    elsif ($calendar_type eq 'burmese') {
        $display_year = convert_burmese($year, $month_num, 1);
    }
    elsif ($calendar_type eq 'vikram') {
        $display_year = convert_vikram($year, $month_num, 1);
    }
    elsif ($calendar_type eq 'saka') {
        $display_year = convert_saka($year, $month_num, 1);
    }
    elsif ($calendar_type eq 'ethiopian') {
        $display_year = convert_ethiopian($year, $month_num, 1);
    }
    elsif ($calendar_type eq 'bangladesh') {
        $display_year = convert_bangladesh($year, $month_num, 1);
    }
    elsif ($calendar_type eq 'hebrew') {
        $display_year = convert_hebrew($year, $month_num, 1);
    }

    my $month_name;
    if ($calendar_type eq 'islamic') {
        $month_name = get_islamic_month_name($month_num, $lang);
    } elsif ($calendar_type eq 'hebrew') {
        my $hebrew_year = convert_hebrew($year, $month_num, 1);
        $month_name = get_hebrew_month_name($month_num, $lang, $hebrew_year);
    } else {
        $month_name = _t("month_$month_key");
    }
    
    my $month_format = _t("date_format_month");
    
    my $result;
    if ($era_name) {
        my $year_with_era = $era_name . $display_year;
        $result = sprintf($month_format, $month_name, $year_with_era);
    } else {
        $result = sprintf($month_format, $month_name, $display_year);
    }
    
    if (!$skip_ganzhi && ($calendar_type eq 'ganzhi' || $calendar_type eq 'vietnamese')) {
        my ($gan, $zhi, $shengxiao) = gregorian_to_ganzhi($year, $lang);
        my $year_unit = _t("Year");
        my $ganzhi = "${gan}${zhi}${shengxiao}$year_unit";
        $result .= " $ganzhi";
    }
    
    if (!$skip_ganzhi && $calendar_type eq 'mongolian') {
        my ($gan, $zhi, $shengxiao) = gregorian_to_ganzhi($year, $lang);
        my $year_unit = _t("Year");
        $result .= " $shengxiao$year_unit";
    }
    
    $TmpMonthCache{$cache_key} = $result;
    return $result;
}

#-----------------------------------------------------------------------------
# 钩子：格式化年份
# 使用 date_format_year
#-----------------------------------------------------------------------------
sub FormatYear_localdate {
    my ($year, $lang) = @_;
    
    my $cache_key = "${year}_${lang}";
    return $TmpYearCache{$cache_key} if $TmpYearCache{$cache_key};
    
    my $calendar_type = get_calendar_type($lang);
    my $display_year = $year;
    my $era_name = "";
    
    if ($calendar_type eq 'japanese') {
        my ($era_index, $era_year) = convert_japanese($year, 1, 1);
        if ($era_index) {
            $display_year = $era_year;
            $era_name = get_era_name($era_index, $era_year, $lang);
        }
    }
    elsif ($calendar_type eq 'buddhist') {
        $display_year = convert_buddhist($year, 1, 1);
    }
    elsif ($calendar_type eq 'minguo') {
        $display_year = convert_minguo($year, 1, 1);
    }
    elsif ($calendar_type eq 'dangun') {
        $display_year = convert_dangun($year, 1, 1);
    }
    elsif ($calendar_type eq 'islamic') {
        $display_year = convert_islamic($year, 1, 1);
    }
    elsif ($calendar_type eq 'persian') {
        $display_year = convert_persian($year, 1, 1);
    }
    elsif ($calendar_type eq 'burmese') {
        $display_year = convert_burmese($year, 1, 1);
    }
    elsif ($calendar_type eq 'vikram') {
        $display_year = convert_vikram($year, 1, 1);
    }
    elsif ($calendar_type eq 'saka') {
        $display_year = convert_saka($year, 1, 1);
    }
    elsif ($calendar_type eq 'ethiopian') {
        $display_year = convert_ethiopian($year, 1, 1);
    }
    elsif ($calendar_type eq 'bangladesh') {
        $display_year = convert_bangladesh($year, 1, 1);
    }
    elsif ($calendar_type eq 'hebrew') {
        $display_year = convert_hebrew($year, 1, 1);
    }
    
    my $year_format = _t("date_format_year");
    
    my $result;
    if ($era_name) {
        my $year_with_era = $era_name . $display_year;
        $result = sprintf($year_format, $year_with_era);
    } else {
        $result = sprintf($year_format, $display_year);
    }
    
    # 简体中文/越南语：附加甲子纪年
    if (($calendar_type eq 'ganzhi' || $calendar_type eq 'vietnamese')) {
        my ($gan, $zhi, $shengxiao) = gregorian_to_ganzhi($year, $lang);
        my $year_unit = _t("Year");
        my $ganzhi = "${gan}${zhi}${shengxiao}$year_unit";
        $result .= " $ganzhi";
    }
    
    # 蒙古语：附加生肖年份
    if ($calendar_type eq 'mongolian') {
        my ($gan, $zhi, $shengxiao) = gregorian_to_ganzhi($year, $lang);
        my $year_unit = _t("Year");
        $result .= " $shengxiao$year_unit";
    }
    
    $TmpYearCache{$cache_key} = $result;
    return $result;
}
#-----------------------------------------------------------------------------
# 验证日历日期是否有效
# 参数：年、月、日、该月天数
# 返回：1=有效，0=无效
#-----------------------------------------------------------------------------
sub is_valid_calendar_day {
    my ($year, $month, $day, $days_in_month) = @_;
    
    # 基本范围检查
    return 0 if $year < 1;
    return 0 if $month < 1;
    return 0 if $day < 1;
    return 0 if $day > $days_in_month;
    
    return 1;
}

1;