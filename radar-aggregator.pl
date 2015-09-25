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
use HTML::Entities;
use HTML::Parse;
use HTML::FormatText;
use JSON;

=pod

=head1 SYNOPSIS

Este programa ekekea los rss del lifo.

=cut

# Opciones
my %opts = ();
getopts('dh',\%opts);

my @feed_lines = read_file('feeds.csv');
my @FEEDS = ();
my @ENTRIES = ();


my $debug = $opts{d} || 0;


######################################################################
# Cod Ppal.
######################################################################


foreach my $line(@feed_lines){  
  chomp($line);
  next unless $line;
  
  my @array_linea = split(/,/,$line);
  my ($url_feed,@categorias) = @array_linea;

  get_feed($url_feed,@categorias);
}

#print Dumper(\%FEEDS);

my $FEEDSjson = encode_json \@FEEDS;
my $ENTRIESjson = encode_json \@ENTRIES;

write_file('data/feeds.json', $FEEDSjson);
write_file('data/entries.json', $ENTRIESjson);

print Dumper($FEEDSjson);








######################################################################
# Subs
######################################################################

sub get_feed {

    # acceder a cada feed.

    my $feed_source = shift;
    my $feed   = XML::FeedPP->new($feed_source);

    my @feed_categories = @_;


    my $feed_title       = decode_entities($feed->title());
   
    my $feed_url         = $feed->link();
    my $feed_description = decode_entities($feed->description());

    my $feed_language	 = $feed->language();


    # entries

    my $feeds_counter = 0;

    foreach my $item ( $feed->get_item() ) {

        my $item_title = decode_entities($item->title());

        #Esto tendria que estar afuera primero.
        my $item_date        = $item->pubDate();
        my $item_url         = $item->link();
        my $item_description = $item->description();
        my $item_descriptionClean = HTML::FormatText->new->format(parse_html($item_description));
        $item_descriptionClean = decode_entities($item_descriptionClean);
        #item_descriptionClean =~ s/(\.{3})?\s*Read\s*More$//gi;
        $item_descriptionClean =~ s/Read\s*More$//gi;



        my @item_tags        = $item->category();
        my $item_author      = $item->author();

        #Guardar en el hash main.
       
        push @ENTRIES, {
            title       => "$item_title",
            feed        => "$feed_title",
            feed_url    => "$feed_url",
            feed_categories => [@feed_categories],
            date        => "$item_date",
            url         => "$item_url",
            description => "$item_description",
            descriptionClean => "$item_descriptionClean",
            tags        => @item_tags,
            author      => "$item_author"
        };  

    	
    	$feeds_counter++;

    }



    # feeds

    push @FEEDS, {
        title       => "$feed_title",
        url         => "$feed_url",
        description => "$feed_description",
        lang        => "$feed_language",
        categories  => [@feed_categories],
        n_items     => "$feeds_counter",
    };




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
