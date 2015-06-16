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
my %FEEDS = ();
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

print Dumper(\%FEEDS);











######################################################################
# Subs
######################################################################

sub get_feed {

    # acceder a cada feed.
    my $feed_source = shift;
    my $feed   = XML::FeedPP->new($feed_source);

  
    my $feed_title       = $feed->title();
   
    my $feed_url         = $feed->link();
   	#my $feed_date        = $feed->pubDate();
    my $feed_description = $feed->description();
    #my $feed_copyright	 = $feed->copyright();
    my $feed_language	 = $feed->language();
    #my $feed_image       = $feed->image();
    #$feed->image( $url, $title, $link, $description, $width, $height )


    $FEEDS{$feed_title} = {
    	url 		=> "$feed_url",
        description => "$feed_description",
        lang        => "$feed_language",
    };



    foreach my $item ( $feed->get_item() ) {

        my $item_title = $item->title();

        #Esto tendria que estar afuera primero.
        my $item_date        = $item->pubDate();
        my $item_url         = $item->link();
        my $item_description = $item->description();
        my $item_tags        = $item->category();
        my $item_author      = $item->author();

        #Guardar en el hash main.
        $ENTRIES{$item_title} = {
            feed        => "$feed_title",
            date        => "$item_date",
            url         => "$item_url",
            description => "$item_description",
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
