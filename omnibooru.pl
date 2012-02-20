#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

require "common/common.pm";

&main;


sub main {
	my ($filter, $software, $tags, $verbose);
	
	Omnibooru::Common->printHeader();

	GetOptions('e' => sub { $filter = 'e'},
		's' => sub { $filter = 's'},
		'v' => sub { $verbose = 1});
	
	if($#ARGV != 1) { Omnibooru::Common->printHelp; die("\n"); }
	($software, $tags) = @ARGV;
	my $booru;

	if($software eq "gelbooru" || $software eq "1") { require "gelbooru/gelbooru.pm"; $software = 'Gelbooru' }
	#if($software eq "danbooru" || $software eq "2") { require "danbooru/danbooru.pm"; }

	my $omnibooru = $software->new('tags' => $tags, 'filter' => $filter, 'verbose' => $verbose);
	$omnibooru->process();
}
