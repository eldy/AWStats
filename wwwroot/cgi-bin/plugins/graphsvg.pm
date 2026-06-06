#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GraphSVG AWStats plugin
# Draws AWStats graphs as self-contained, inline SVG (no external service).
#
# This is a drop-in replacement for the "graphgooglechartapi" plugin, whose
# backends were shut down by Google: the Google Image Charts API used for the
# bar/column and pie charts was turned off in March 2019, and the Flash-based
# Google Visualization GeoMap used for the country map even earlier. As a
# result those graphs render as broken images on every modern report.
#
# GraphSVG implements the very same ShowGraph hook and graph types, but draws
# everything locally as inline SVG. Benefits:
#   * No external request, no JavaScript, no CDN -> graphs keep working
#     forever, offline, and inside static (BuildStaticPages) reports.
#   * No visitor data is ever sent to a third party (privacy / GDPR friendly).
#   * Vector output: crisp at any zoom, with native <title> hover tooltips.
#   * Compatible with both html and xhtml BuildReportFormat.
#
# The Google "geomap" country map cannot be reproduced without shipping a full
# world geometry; it is replaced here by a horizontal ranking bar chart of the
# top countries, which conveys the same information with zero extra data.
#-----------------------------------------------------------------------------
# Perl Required Modules: None
#-----------------------------------------------------------------------------
#
# Changelog
#
# 1.0 - Initial release. Bar/column, pie and ranking charts as inline SVG.
#-----------------------------------------------------------------------------

# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
# ----->
no strict "refs";


#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion = "7.0";
my $PluginHooksFunctions     = "Init ShowGraph";
my $PluginName               = "graphsvg";

# Geometry (in px). Width may be overridden per call by AWStats.
my $imagewidth    = 640;    # default chart width
my $barplotheight = 175;    # height of the bar/column plot area
my $pieradius     = 78;     # radius of pie charts
my $PI            = 3.14159265358979;

# Per-call state, filled in by ShowGraph_graphsvg().
my $title;
my $type;
my $blocklabel;
my $vallabel;
my $valcolor;
my $valmax;
my $valtotal;
my $valaverage;
my $valdata;
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$DirClasses
/;
# ----->

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_graphsvg {
	my $InitParams   = shift;
	my $checkversion = &Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	$DirClasses = $InitParams;
	# ----->

	return ( $checkversion ? $checkversion : "$PluginHooksFunctions" );
}

#-------------------------------------------------------
# PLUGIN FUNCTION: ShowGraph_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# Prints the proper chart depending on the $type provided
# Parameters: $title $type $imagewidth \@blocklabel \@vallabel \@valcolor
#             \@valmax \@valtotal \@valaverage \@valdata
# Input:      None
# Output:     Inline SVG
# Return:     0 OK, 1 Error
#-------------------------------------------------------
sub ShowGraph_graphsvg() {
	$title      = shift;
	$type       = shift;
	$imagewidth = shift;
	$blocklabel = shift;
	$vallabel   = shift;
	$valcolor   = shift;
	$valmax     = shift;
	$valtotal   = shift;
	$valaverage = shift;
	$valdata    = shift;

	# AWStats passes the relevant Show*Stats flag string (e.g. "HB") as the
	# width argument for the time graphs, exactly as the old Google plugin did.
	# Treat anything non-numeric or < 1 as "use the default width".
	if ( !defined $imagewidth || $imagewidth !~ /^\d+$/ || $imagewidth < 1 ) {
		$imagewidth = 640;
	}

	if (   $type eq 'month'
		|| $type eq 'daysofmonth'
		|| $type eq 'daysofweek'
		|| $type eq 'hours' )
	{
		# Keep the historical narrower week graph look.
		my $w =
		  ( $type eq 'daysofweek' )
		  ? int( $imagewidth * 0.75 )
		  : $imagewidth;
		print Graph_Bar($w);
	}
	elsif ($type eq 'cluster'
		|| $type eq 'filetypes'
		|| $type eq 'httpstatus'
		|| $type eq 'browsers'
		|| $type eq 'downloads'
		|| $type eq 'pages'
		|| $type eq 'oss'
		|| $type eq 'hosts' )
	{
		print Graph_Pie();
	}
	elsif ( $type eq 'countries_map' ) {
		print Graph_Rank();
	}
	else {
		debug( "Unknown type parameter in ShowGraph_graphsvg function: $type",
			1 );
	}

	return 0;
}

#-------------------------------------------------------
# Small helpers
#-------------------------------------------------------

# Escape a string for safe inclusion in SVG/XML text and attributes.
sub _esc {
	my $s = shift;
	$s = '' unless defined $s;
	$s =~ s/&/&amp;/g;
	$s =~ s/</&lt;/g;
	$s =~ s/>/&gt;/g;
	$s =~ s/"/&quot;/g;
	$s =~ s/'/&#39;/g;
	return $s;
}

# Normalise an AWStats colour (hex without '#') to a CSS colour.
sub _col {
	my ( $hex, $default ) = @_;
	$default = '4477DD' unless defined $default;
	$hex = '' unless defined $hex;
	$hex =~ s/[^0-9A-Fa-f]//g;
	$hex = $default unless ( length($hex) == 3 || length($hex) == 6 );
	return "#$hex";
}

sub _is_num {
	my $v = shift;
	return ( defined $v && $v =~ /^-?\d+(?:\.\d+)?$/ ) ? 1 : 0;
}

# A numeric value usable in maths: AWStats may pass "?" for empty averages.
sub _num {
	my $v = shift;
	return _is_num($v) ? $v + 0 : 0;
}

# Lighten ($f > 0) or darken ($f < 0) a hex colour. $f in [-1, 1].
sub _shade {
	my ( $hex, $f ) = @_;
	$hex = '' unless defined $hex;
	$hex =~ s/[^0-9A-Fa-f]//g;
	if ( length($hex) == 3 ) { $hex =~ s/(.)/$1$1/g; }
	return "#888888" unless length($hex) == 6;
	my @c = (
		hex( substr( $hex, 0, 2 ) ),
		hex( substr( $hex, 2, 2 ) ),
		hex( substr( $hex, 4, 2 ) )
	);
	foreach my $i ( 0 .. 2 ) {
		if ( $f >= 0 ) { $c[$i] = int( $c[$i] + ( 255 - $c[$i] ) * $f ); }
		else           { $c[$i] = int( $c[$i] * ( 1 + $f ) ); }
		$c[$i] = 0   if $c[$i] < 0;
		$c[$i] = 255 if $c[$i] > 255;
	}
	return sprintf( "#%02X%02X%02X", @c );
}

# Decode an AWStats block label. They may be encoded as "Jan\n2026" (two text
# rows) and may carry trailing markers: '!' = week-end, ':' = "current" (bold).
# Returns ($line1, $line2, $isweekend, $iscurrent).
sub _label {
	my $raw = shift;
	$raw = '' unless defined $raw;
	my $weekend = ( $raw =~ /!/ ) ? 1 : 0;
	my $current = ( $raw =~ /:/ ) ? 1 : 0;
	$raw =~ s/[!:]//g;
	my ( $l1, $l2 ) = split( /\n/, $raw, 2 );
	$l1 = '' unless defined $l1;
	$l2 = '' unless defined $l2;
	return ( $l1, $l2, $weekend, $current );
}

# Format a series value for display. The last series of every AWStats time
# graph is always bandwidth (bytes), so format it with Format_Bytes.
sub _fmtval {
	my ( $v, $isbytes ) = @_;
	if ($isbytes) { return Format_Bytes($v); }
	if ( $v == int($v) ) { return Format_Number( int($v) ); }
	return sprintf( "%.1f", $v );
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Graph_Bar
# Grouped column chart for the month / daysofmonth / daysofweek / hours graphs.
# Each series is scaled to its own (possibly shared) max, exactly like the old
# Google column chart, so series with very different units stay comparable.
#-------------------------------------------------------
sub Graph_Bar {
	my $W       = shift || 640;
	my $nblocks = scalar @$blocklabel;
	my $nseries = scalar @$valcolor;
	return '' if ( $nblocks < 1 || $nseries < 1 );

	# Per-series scale max: honour the value AWStats provides (it deliberately
	# shares one max across related series), else derive it from the data.
	my @smax;
	foreach my $s ( 0 .. $nseries - 1 ) {
		my $m =
		  ( $valmax && _num( $valmax->[$s] ) > 0 ) ? _num( $valmax->[$s] ) : 0;
		if ( $m <= 0 ) {
			foreach my $b ( 0 .. $nblocks - 1 ) {
				my $v = _num( $valdata->[ $b * $nseries + $s ] );
				$m = $v if $v > $m;
			}
		}
		$smax[$s] = ( $m > 0 ) ? $m : 1;
	}

	# Geometry.
	my $padL  = 8;
	my $padR  = 8;
	my $padT  = 10;
	my $plotH = $barplotheight;

	# Do any labels need a second text row?
	my $tworow = 0;
	foreach my $b ( 0 .. $nblocks - 1 ) {
		my ( undef, $l2 ) = _label( $blocklabel->[$b] );
		$tworow = 1 if length($l2);
	}
	my $xlabelH = $tworow ? 25 : 14;

	my $plotW   = $W - $padL - $padR;
	my $groupW  = $plotW / $nblocks;
	my $gGap    = ( $groupW > 6 ) ? $groupW * 0.18 : 0;
	my $barsW   = $groupW - $gGap;
	my $barW    = $barsW / $nseries;
	my $plotTop = $padT;
	my $plotBot = $padT + $plotH;

	# Legend layout (deterministic: fixed slot width, wrap into rows).
	my $slotW  = 150;
	my $perRow = int( $W / $slotW );
	$perRow = 1        if $perRow < 1;
	$perRow = $nseries if $perRow > $nseries;
	my $legRows   = int( ( $nseries + $perRow - 1 ) / $perRow );
	my $legendTop = $plotBot + $xlabelH + 6;
	my $H         = $legendTop + $legRows * 16 + 2;

	my @s;
	push @s,
	  sprintf(
'<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" font-family="Helvetica,Arial,sans-serif" font-size="10">',
		$W, $H, $W, $H );
	push @s,
	  sprintf( '<rect x="0" y="0" width="%d" height="%d" fill="#ffffff"/>',
		$W, $H );

	# Week-end column backgrounds.
	foreach my $b ( 0 .. $nblocks - 1 ) {
		my ( undef, undef, $we ) = _label( $blocklabel->[$b] );
		next unless $we;
		my $gx = $padL + $b * $groupW;
		push @s,
		  sprintf(
'<rect x="%.1f" y="%d" width="%.1f" height="%d" fill="%s" opacity="0.6"/>',
			$gx, $plotTop, $groupW, $plotH, _col( $color_weekend, 'EAEAEA' ) );
	}

	# Horizontal grid lines.
	foreach my $g ( 0 .. 4 ) {
		my $gy = $plotTop + $plotH * $g / 4;
		push @s,
		  sprintf(
'<line x1="%d" y1="%.1f" x2="%d" y2="%.1f" stroke="#e6e6e6" stroke-width="1"/>',
			$padL, $gy, $W - $padR, $gy );
	}

	# Baseline.
	push @s,
	  sprintf(
'<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="#9aa0a6" stroke-width="1"/>',
		$padL, $plotBot, $W - $padR, $plotBot );

	# Columns.
	foreach my $b ( 0 .. $nblocks - 1 ) {
		my $gx = $padL + $b * $groupW + $gGap / 2;
		foreach my $sx ( 0 .. $nseries - 1 ) {
			my $v = _num( $valdata->[ $b * $nseries + $sx ] );
			next if $v <= 0;
			my $h = ( $v / $smax[$sx] ) * $plotH;
			$h = $plotH if $h > $plotH;
			next if $h < 0.5;
			my $bx      = $gx + $sx * $barW;
			my $by      = $plotBot - $h;
			my $bw      = ( $barW > 1.4 ) ? $barW - 0.6 : $barW;
			my $isbytes = ( $sx == $nseries - 1 ) ? 1 : 0;
			my $lab =
			  ( $vallabel && defined $vallabel->[$sx] ) ? $vallabel->[$sx] : '';
			push @s,
			  sprintf(
'<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="%s"><title>%s: %s</title></rect>',
				$bx, $by, $bw, $h, _col( $valcolor->[$sx] ),
				_esc($lab), _esc( _fmtval( $v, $isbytes ) ) );
		}
	}

	# X axis labels.
	foreach my $b ( 0 .. $nblocks - 1 ) {
		my ( $l1, $l2, undef, $cur ) = _label( $blocklabel->[$b] );
		my $cx = $padL + $b * $groupW + $groupW / 2;
		my $fs = ( $groupW < 16 ) ? 8 : 9;
		my $wt = $cur ? ' font-weight="bold"' : '';
		my $ty = $plotBot + 11;
		push @s,
		  sprintf(
'<text x="%.1f" y="%d" text-anchor="middle" font-size="%d"%s fill="#3c4043">%s</text>',
			$cx, $ty, $fs, $wt, _esc($l1) );
		if ( length($l2) ) {
			push @s,
			  sprintf(
'<text x="%.1f" y="%d" text-anchor="middle" font-size="%d" fill="#70757a">%s</text>',
				$cx, $ty + 10, $fs, _esc($l2) );
		}
	}

	# Legend (colour swatch + series label + grand total).
	foreach my $sx ( 0 .. $nseries - 1 ) {
		my $row  = int( $sx / $perRow );
		my $colp = $sx % $perRow;
		my $lx   = $padL + $colp * $slotW;
		my $ly   = $legendTop + $row * 16;
		my $lab =
		  ( $vallabel && defined $vallabel->[$sx] )
		  ? $vallabel->[$sx]
		  : "Series " . ( $sx + 1 );
		my $isbytes = ( $sx == $nseries - 1 ) ? 1 : 0;
		my $tot = '';
		if ( $valtotal && defined $valtotal->[$sx] ) {
			$tot = _fmtval( _num( $valtotal->[$sx] ), $isbytes );
		}
		push @s,
		  sprintf( '<rect x="%d" y="%d" width="10" height="10" fill="%s"/>',
			$lx, $ly, _col( $valcolor->[$sx] ) );
		my $txt = _esc($lab) . ( $tot ne '' ? ' (' . _esc($tot) . ')' : '' );
		push @s,
		  sprintf( '<text x="%d" y="%d" fill="#3c4043">%s</text>',
			$lx + 14, $ly + 9, $txt );
	}

	push @s, '</svg>';
	return join( "\n", @s ) . "\n";
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Graph_Pie
# Pie chart with a legend. Segments use shades of the section colour (the same
# single colour the old Google plugin received), separated by thin white gaps.
#-------------------------------------------------------
sub Graph_Pie {
	my $nseg = scalar @$blocklabel;
	return '' if ( $nseg < 1 );

	my @vals;
	my $sum = 0;
	foreach my $i ( 0 .. $nseg - 1 ) {
		my $v = _num( $valdata->[$i] );
		$v = 0 if $v < 0;
		$vals[$i] = $v;
		$sum += $v;
	}
	return '' if ( $sum <= 0 );

	my $base = ( $valcolor && defined $valcolor->[0] ) ? $valcolor->[0] : '4477DD';

	# Geometry: pie on the left, legend on the right.
	my $r      = $pieradius;
	my $pad    = 12;
	my $cx     = $pad + $r;
	my $cy     = $pad + $r;
	my $legendX = $cx + $r + 22;
	my $rowH    = 16;
	my $legendH = $nseg * $rowH;
	my $H       = ( $legendH + 2 * $pad > 2 * $r + 2 * $pad )
	  ? $legendH + 2 * $pad
	  : 2 * $r + 2 * $pad;
	my $W = 640;

	my @s;
	push @s,
	  sprintf(
'<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" font-family="Helvetica,Arial,sans-serif" font-size="11">',
		$W, $H, $W, $H );
	push @s,
	  sprintf( '<rect x="0" y="0" width="%d" height="%d" fill="#ffffff"/>',
		$W, $H );

	# Per-segment colours: evenly spread shades of the base colour.
	my @segcol;
	foreach my $i ( 0 .. $nseg - 1 ) {
		my $f = ( $nseg > 1 ) ? ( 0.45 - 0.85 * ( $i / ( $nseg - 1 ) ) ) : 0;
		$segcol[$i] = _shade( $base, $f );
	}

	if ( $nseg == 1 ) {
		# A single 100% slice: a full circle (arc paths can't draw 360 deg).
		push @s,
		  sprintf(
'<circle cx="%.1f" cy="%.1f" r="%d" fill="%s" stroke="#ffffff" stroke-width="1"/>',
			$cx, $cy, $r, $segcol[0] );
	}
	else {
		my $angle = 0;    # radians, 0 = top, clockwise
		foreach my $i ( 0 .. $nseg - 1 ) {
			my $frac = $vals[$i] / $sum;
			my $a0   = $angle;
			my $a1   = $angle + $frac * 2 * $PI;
			$angle = $a1;
			next if $frac <= 0;
			my $x0    = $cx + $r * sin($a0);
			my $y0    = $cy - $r * cos($a0);
			my $x1    = $cx + $r * sin($a1);
			my $y1    = $cy - $r * cos($a1);
			my $large = ( ( $a1 - $a0 ) > $PI ) ? 1 : 0;
			my $pct   = sprintf( "%.1f", $frac * 100 );
			push @s,
			  sprintf(
'<path d="M%.1f,%.1f L%.1f,%.1f A%d,%d 0 %d,1 %.1f,%.1f Z" fill="%s" stroke="#ffffff" stroke-width="1"><title>%s: %s%%</title></path>',
				$cx, $cy, $x0, $y0, $r, $r, $large, $x1, $y1, $segcol[$i],
				_esc( $blocklabel->[$i] ), $pct );
		}
	}

	# Legend.
	foreach my $i ( 0 .. $nseg - 1 ) {
		my $ly  = $pad + $i * $rowH;
		my $pct = sprintf( "%.1f", $vals[$i] / $sum * 100 );
		push @s,
		  sprintf( '<rect x="%d" y="%d" width="11" height="11" fill="%s"/>',
			$legendX, $ly, $segcol[$i] );
		push @s,
		  sprintf(
'<text x="%d" y="%d" fill="#3c4043">%s &#8212; %s%%</text>',
			$legendX + 16, $ly + 10, _esc( $blocklabel->[$i] ), $pct );
	}

	push @s, '</svg>';
	return join( "\n", @s ) . "\n";
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Graph_Rank
# Horizontal ranking bar chart, used in place of the (dead) Google GeoMap for
# the countries section. Shows the top entries by value.
#-------------------------------------------------------
sub Graph_Rank {
	my $n = scalar @$blocklabel;
	return '' if ( $n < 1 );

	# Pair labels with values, sort by value desc, keep the top ones.
	my @rows;
	foreach my $i ( 0 .. $n - 1 ) {
		push @rows,
		  [ defined $blocklabel->[$i] ? $blocklabel->[$i] : '',
			_num( $valdata->[$i] ) ];
	}
	@rows = sort { $b->[1] <=> $a->[1] } @rows;
	my $topn = 15;
	@rows = @rows[ 0 .. $topn - 1 ] if scalar @rows > $topn;

	my $max = 0;
	foreach my $rrow (@rows) { $max = $rrow->[1] if $rrow->[1] > $max; }
	$max = 1 if $max <= 0;

	my $W      = 640;
	my $pad    = 10;
	my $labelW = 150;    # left column for the country name
	my $valW   = 90;     # right column for the value
	my $rowH   = 20;
	my $barH   = 12;
	my $barX   = $pad + $labelW;
	my $barMax = $W - $barX - $valW - $pad;
	my $H      = $pad * 2 + scalar(@rows) * $rowH;
	my $fill   = _col( $color_h, '4477DD' );

	my @s;
	push @s,
	  sprintf(
'<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" font-family="Helvetica,Arial,sans-serif" font-size="11">',
		$W, $H, $W, $H );
	push @s,
	  sprintf( '<rect x="0" y="0" width="%d" height="%d" fill="#ffffff"/>',
		$W, $H );

	foreach my $i ( 0 .. scalar(@rows) - 1 ) {
		my $row = $rows[$i];
		my $ry  = $pad + $i * $rowH;
		my $by  = $ry + ( $rowH - $barH ) / 2;
		my $w   = ( $row->[1] / $max ) * $barMax;
		$w = 0.5 if ( $w < 0.5 && $row->[1] > 0 );

		# Country name (right-aligned against the bars).
		push @s,
		  sprintf(
'<text x="%d" y="%.1f" text-anchor="end" fill="#3c4043">%s</text>',
			$barX - 6, $by + $barH - 2, _esc( $row->[0] ) );

		# Bar.
		push @s,
		  sprintf(
'<rect x="%d" y="%.1f" width="%.1f" height="%d" fill="%s"><title>%s: %s</title></rect>',
			$barX, $by, $w, $barH, $fill,
			_esc( $row->[0] ), _esc( Format_Number( int( $row->[1] ) ) ) );

		# Value.
		push @s,
		  sprintf( '<text x="%.1f" y="%.1f" fill="#70757a">%s</text>',
			$barX + $w + 5, $by + $barH - 2,
			_esc( Format_Number( int( $row->[1] ) ) ) );
	}

	push @s, '</svg>';
	return join( "\n", @s ) . "\n";
}

1;    # Do not remove this line
