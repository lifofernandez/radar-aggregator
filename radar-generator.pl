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

use Date::Manip;

use HTML::Entities;
use HTML::Parse;
use HTML::FormatText;
use HTML::Template;

=pod

=head1 SYNOPSIS

Este programa ekekea los rss del lifo.

=cut

# Opciones

my %opts = ();
getopts('dh',\%opts);

my @feed_lines = read_file('feeds.csv');
my $feed_ejemplo = read_file('ejemplo_feed_file.xml');

# my %FEEDS = ();
# my %ENTRIES = ();

my @entradas = ();
my @feeds = ();


# open the html template
my $template = HTML::Template->new(filename => 'index.tmpl');

my $debug = $opts{d} || 0;


######################################################################
# Cod Ppal.
######################################################################

# DEVELEPMENT content

get_feed("ejemplo_feed_file.xml",["prueba", "pepe"]);

# REAL content

foreach my $line(@feed_lines){  
	chomp($line);
	next unless $line;
	
	my @array_linea = split(/,/,$line);
	my ($url_feed,@categorias) = @array_linea;

	get_feed($url_feed,@categorias);
}



######################################################################
# HTMLing.
######################################################################


$template->param(ENTRADA => \@entradas);
$template->param(FEED => \@feeds);

my $output = $template->output;

# print $output;
write_file( 'output/index.html', {binmode => ':utf8'}, $output );

# write_file('output/index.html',$output);


# foreach my $entry ( keys %ENTRIES ) {
#     #print "$entry:\n";
#     
#     # foreach my $item ( keys %{ $ENTRIES{$entry} } ) {
#     #       print "$item: $ENTRIES{$entry}{$item}\n";
#     # }
#     # print "\n";
# }


# for my $feed ( keys %FEEDS ) {
#     print "$feed:\n";
#     for my $item ( keys %{ $FEEDS{$feed} } ) {
#          print "$item: $FEEDS{$feed}{$item}\n";
#     }
#     print "\n";
# }






# print Dumper(\%ENTRIES);






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
		print ($feed_url."\n");
		my $feed_description = decode_entities($feed->description());

		my $feed_language	 = $feed->language();


		# entries

		my $feeds_counter = 0;

		foreach my $item ( $feed->get_item() ) {

				my $item_title = decode_entities($item->title());

				# Esto tendria que estar afuera primero.
				my $item_date        			= $item->pubDate();

				my $item_url         			= $item->link();
				my $item_description 			= $item->description();
				my $item_descriptionClean = HTML::FormatText->new->format(parse_html($item_description));
				
				$item_descriptionClean 		= decode_entities($item_descriptionClean);
				$item_descriptionClean 		=~ s/\R//g;
				$item_descriptionClean    =~ s/ +/ /g;

				# item_descriptionClean    =~ s/(\.{3})?\s*Read\s*More$//gi;
				$item_descriptionClean 		=~ s/Read\s*More$//gi;



				my @item_tags        			= $item->category();
				my @tags       			 			= ();
						
				# my @item_tags = ('carro','perro','forro');
				# my @item_tags = 'carro';

				# print (ref(\@item_tags));
				# print Dumper(@item_tags);

				if(@item_tags[0] ne undef){

					foreach (@item_tags){
						if(ref(\$_) eq 'SCALAR'){
							my $slug = lc $_;
							$slug =~ s/[^[:ascii:]]//g;
							$slug=~s/ /-/g;
						
							push @tags, {tagname => $_,tagslug=>$slug};
						}
						if(ref(\$_) eq 'REF'){
							foreach (@$_){
								my $slug = lc $_;
								$slug =~ s/[^[:ascii:]]//g;
								$slug=~s/ /-/g;

								push @tags, {tagname => $_,tagslug=>$slug};
							}
						}
					}
				}

				

				
				




				
				##   reserva   #####################
				# foreach my $tag (@item_tags) {
				    
				#     # if (ref($tag) eq 'ARRAY') {
				#     # 	#next;
				    	
				#     # }		
				#     my %a = {tagname => $tag};
				#     $tags[$index] = \%a ;
				#     # push @tags, %a;
				#     $index++;
				# }

				# foreach my $p (@item_tags){
				# 	next unless ($p =~ /\w+/);
				#      print $p;
				#      my %prueba = { tagname => $p }; 
				#      push @tags, \%prueba ;
				# }
				####################################
				


				my $item_author      			= $item->author();

				# Guardar en el hash main.
	
				# hash ariginal	 
				# $ENTRIES{"$item_title"} = {
				# 	title     => "$item_title",
				# 	date        => "$item_date",
				# 	url         => "$item_url",
				# 	description_raw => "$item_description",
				# 	description => "$item_descriptionClean",
				# 	tags        => @item_tags,
				# 	author      => "$item_author",
				# 	feed        => "$feed_title",
				# 	feed_url    => "$feed_url",
				# 	feed_categories => [@feed_categories]
				# };  

				my $date1 = ParseDate($item_date);
				my $date2 = ParseDate("yesterday");

				my $rango ='0:0:0:0:-24:0:0';
			 	my $delta = DateCalc($date1,$date2);

   			my $esdehoy = Date_Cmp($rango,$delta);

				# imprimir($date1);
				# imprimir($date2);
				# imprimir($esdehoy);
				
				# print ("\n");
				if($esdehoy > -1){
					push @entradas, {
						title       => "$item_title",
						date        => "$item_date",
						url         => "$item_url",
						# description_raw => "$item_description",
						description => "$item_descriptionClean",
						tags        => [@tags],
						# tags        => @item_tags,

						# author      => "$item_author",
						feed        => "$feed_title",
						feed_url    => "$feed_url"
							# feed_categories => [@feed_categories],     
					};
				}


			
			$feeds_counter++;

		}



		# feeds

		# $FEEDS{"$feed_title"} = {
		# 	# title       => "$feed_title",
		# 	url         => "$feed_url",
		# 	description => "$feed_description",
		# 	lang        => "$feed_language",
		# 	categories  => [@feed_categories],
		# 	n_items     => "$feeds_counter",
		# };

		push @feeds, {
			title       => "$feed_title",
			url         => "$feed_url",
			description => "$feed_description",
			lang        => "$feed_language",
			# categories  => [@feed_categories],
			n_items     => "$feeds_counter",    
		};  


		return "### fetched: ", $feed->title() if $debug;
}






sub ayudas {
		pod2usage(-verbose=>3);
}

sub imprimir {
	my $input = shift;
	unless (ref $input) {
		print "$input\n";
		} elsif (ref $input eq 'ARRAY') {
			imprimir($_) for @$input;
		} elsif (ref $input eq 'HASH') {
			for (keys %$input) {
				print "$_\n";
				imprimir($input->{$_});
			}
		} else {
			print ref $input,"\n";
		}
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
