#!/usr/bin/perl
######################################################################
# Radar agregator.
######################################################################

use autodie;
use feature "say";
use strict;
use XML::FeedPP;
use File::Slurp; 
use Data::Dumper;
use Getopt::Std;
use Pod::Usage;

=pod

=head1 SYNOPSIS

Este programa ekekea los rss del lifo.

=cut

# Opciones
my %opts = ();
getopts('dh',\%opts);

my @feed_lines = read_file('feeds.csv');
#my %FEEDS = ();
my %ENTRIES = ();

my $debug = $opts{d} || 0;


######################################################################
# Cod Ppal.
######################################################################


foreach my $line(@feed_lines){
  my @array_linea = split(/,/,$line);
  my ($url_feed,@categorias) = @array_linea;
  get_feed($url_feed);
}

print Dumper(\%ENTRIES);











######################################################################
# Subs
######################################################################

sub get_feed {

    # acceder a cada feed.
    my $source = shift;
    my $feed   = XML::FeedPP->new($source);

    # print "Title: ", $feed->title(),   "\n";
    # print "Date: ",  $feed->pubDate(), "\n";

    foreach my $item ( $feed->get_item() ) {

        #  print "URL: ",   $item->link(),  "\n";
        #  print "Title: ", $item->title(), "\n";
        #  print "Description: ", $item->description(), "\n\n";
        my $titulo_item = $item->title();

        #Esto tendria que estar afuera primero.
        my $item_feed        = $feed->title();
        my $item_date        = $item->pubDate();
        my $item_url         = $item->link();
        my $item_description = $item->description();
        my $item_content     = '-';
        my $item_tags        = $item->category();
        my $item_author      = $item->author();

        #Guardar en el hash main.
        $ENTRIES{$titulo_item} = {
            feed        => "$item_feed",
            date        => "$item_date",
            url         => "$item_url",
            description => "$item_description",
            content     => "$item_content",
            tags        => "$item_tags",
            author      => "$item_author"
        };

    }
    return "### fetched: ", $feed->title() if $debug;
}


sub ayudas {
    pod2usage(-verbose=>3);
}











######################################################################
__DATA__

FEED
  url
  categorias
  descripcion
  title
  source

  ENTRIEs
    date
    url(original)
    description
    contenido
    tags
    author
