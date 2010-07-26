#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

require "common/common.pm";

&main;


sub main {
	my ($filter, $software, $tags, $verbose);
	
	&printHeader();

	GetOptions	('e' => sub { $filter = 'e'},
				 's' => sub { $filter = 's'},
				 'v' => sub { $verbose = 1});
	
	if($#ARGV != 1) { &printHelp; die("\n"); }
	$software = shift(@ARGV);
	$tags = shift(@ARGV);

	if($software eq "gelbooru" || $software eq "1") { require "gelbooru/gelbooru.pm"; }
	#if($software eq "danbooru" || $software eq "2") { require "danbooru/danbooru.pm"; }

	&initOmnibooru($tags, $filter, $verbose);
	
}