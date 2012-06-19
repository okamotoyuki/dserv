#!/usr/bin/perl

while(my $str = <STDIN>) {
	$str =~ s/"/'/g;
	print $str;
}
