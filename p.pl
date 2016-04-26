#!/usr/bin/perl
use strict;
use warnings;
use POSIX q/strftime/;
use feature "say";

my $dia = 60*60*24;
my $t_banana = strftime ("%d_%B_%Y_%H_%M_%S",localtime(time()-$dia));
say $t_banana;
