#!/usr/bin/perl
######################################################################
# ...
######################################################################
use strict;
use warnings;
use POSIX q/strftime/;
#use Getopt::Std;
use Pod::Usage;
use Data::Dumper;
use autodie;
use feature "say";

#my %opts = ();
my $t_banana = strftime ("%d_%B_%Y_%H_%M_%S",localtime(time()));

#getopts('',\%opts);

=pod

=head1 SYNOPSIS

Radar... sip.

=cut
