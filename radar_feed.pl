#!/usr/bin/perl
######################################################################
# ...
######################################################################
use strict;
#use warnings;
use autodie;
use feature         "say";
use POSIX           "strftime";
#use Getopt::Std;
use Pod::Usage;
use Data::Dumper;
use File::Slurp     qw(read_file write_file);

#pal rss
#use LWP::Simple "get";
#use XML::RAI;

my %opts = ();
getopts('dhf:',\%opts);

=pod

=head1 SYNOPSIS

Radar... sip.

=cut

######################################################################
# VARIABLES GLOBALES
######################################################################
my $debug = 1;
my $t_banana = strftime ("%d_%B_%Y_%H_%M_%S",localtime(time()));
my $archivo_urls_categorias_csv = 'feeds.csv';
my @uri_rss_all = ();
my %RSS = ();
my %Noticias = ();



######################################################################
# M A I N
######################################################################
if ($opts{h}){
    ayudas();
    exit 0;
if ($opts{d}){
    $debug = 1;
}
if ($opts{f}){
    die unless -e $opts{f};
    $archivo_urls_categorias_csv = $opts{f};
}
   
feeds_list($archivo_urls_categorias_csv);
print Dumper(%RSS) if $debug;

######################################################################
# S U B S
######################################################################
sub ayudas {
    pod2usage(-verbose=>3);
}
sub feeds_list {
    my $file_name = shift;
    my $n = 0;
    my @datas = read_file($file_name);
    foreach my $ln (@datas){
        chomp($ln);
        my @r = split(/,/,$ln);
        print Dumper(@r) if $debug;
        $RSS{$n} = \@r;
        push (@uris_rss_all,$r[0]);
        $n++;
    }
}
sub url_getter {
    #foreach my $uri_rss (@uris_rss_all){
        #my $rss_obj = XML::RAI->parse(get($uri_rss));
        #foreach my $item(@{$rss_obj->items}){
            #$title = $item->title;
            #$link = $item->link;
        #}
    #}
}
