package radar;

use Dancer2;
use utf8;
use File::Slurp;
use POSIX q/strftime/;
use Data::Dumper;

use XML::FeedPP;
use HTML::Entities;
use HTML::Parse;
use HTML::FormatText;
use Date::Manip;
use Digest::MD5 qw(md5_hex);
use JSON;

our $VERSION = '0.1';

my %FEEDS         = ();
my %ENTRIES       = ();
my @ids_items_db  = ();
my $hoy           = time();
my $dia           = 60 * 60 * 24;
my $ayer          = $hoy - $dia;

get '/' => sub {
    my $data_file           = read_file config->{radar}{entries_json_file};
    my $desc                = config->{radar}{descripcion};
    my $data                = from_json $data_file;
    @ids_items_db           = keys(%$data); #setear este array.
    #pa debuggear...
    #my $arrocero = join " ", @ids_items_db;
    #print Dumper($data);
    #template 'index',       { data => $data , descripcion => $desc, extras => $arrocero};
    my $h                   = config->{radar}{pie_de_pag};
    template 'index',       { data => $data , descripcion => $desc, extras => $h};
};

get '/update/*' => sub {
    my ( $pass )    = splat;
    my $pass_conf   = config->{radar}{admin_p};
    #print $f1, $f2, $f3;
    if ($pass eq $pass_conf){
        get_feed_stuff();
        template 'sip';
    } else {
        redirect '/';
    }
};


######################################################################
# Funciones
######################################################################

# llamar esta funcion con tres argumentos:
# 1- archivo con las urls de los feeds.
# 2- archivo json con los feeds (feeds.json)
# 3- archivo_json con las entradas (entries.json).
sub get_feed_stuff {
    my $f1          = config->{radar}{feed_file};
    my $f2          = config->{radar}{feeds_json_file};
    my $f3          = config->{radar}{entries_json_file};
    my $feed_file_urls = $f1;
    my @feed_lines     = read_file($feed_file_urls);
    foreach my $line(@feed_lines){  
      chomp($line);
      next unless $line;
      my @array_linea = split(/,/,$line);
      my ($url_feed,@categorias) = @array_linea;
      get_feed($url_feed,@categorias);
    }

    my $FEEDSjson   = encode_json \%FEEDS;
    my $ENTRIESjson = encode_json \%ENTRIES;
    write_file ($f2, { append => 1 }, $FEEDSjson    );
    write_file ($f3, { append => 1 }, $ENTRIESjson  );
}

sub get_feed {
    # acceder a cada feed.
    my $feed_source = shift;
    my $feed   = XML::FeedPP->new($feed_source);

    my @feed_categories  = @_;
    my $feed_title       = decode_entities( $feed->title() );
    my $feed_url         = $feed->link();
    my $feed_url_digest  = md5_hex($feed_url);
    my $feed_description = decode_entities( $feed->description() );
    my $feed_language    = $feed->language();

    # entries
    my $feeds_counter = 0;
    my @items_de_hoy = $feed->match_item( pubDate => q/$rgx_fecha/); 


    foreach my $item ( $feed->get_item() ) {
        my $item_title = decode_entities($item->title());

        #Esto tendria que estar afuera primero.
        my $item_date        = $item->pubDate();
        my $item_url         = $item->link();
        my $item_url_digest  = md5_hex($item_url);
        my $item_description = $item->description();
        my $item_descriptionClean = HTML::FormatText->new->format( parse_html($item_description) );
        $item_descriptionClean = decode_entities($item_descriptionClean);
        $item_descriptionClean =~ s/Read\s*More$//gi;

        #¿es de las ultimas 24hrs?
        my @item_tags        = $item->category();
        my $item_author      = $item->author();

        my $x = UnixDate($item_date, "%s"); # cualquier fecha, en timestamp format.
        if($x >= $ayer && $x <= $hoy){
            unless(item_repetido($item_url_digest)){
                $ENTRIES{ $item_url_digest } = {
                    title       => "$item_title",
                    feed        => "$feed_title",
                    feed_url    => "$feed_url",
                    feed_id     => "$feed_url_digest",
                    feed_categories => [@feed_categories],
                    date        => "$item_date",
                    url         => "$item_url",
                    id          => "$item_url_digest",
                    description => "$item_description",
                    descriptionClean => "$item_descriptionClean",
                    tags        => @item_tags,
                    author      => "$item_author"
                };
            }
        }
    	$feeds_counter++;
    }

    # feeds
    $FEEDS{$feed_url_digest} = {
        title       => "$feed_title",
        url         => "$feed_url",
        id          => "$feed_url_digest",
        description => "$feed_description",
        lang        => "$feed_language",
        categories  => [@feed_categories],
        n_entries   => "$feeds_counter",
    };
}

sub item_repetido {
    my $itemi_id = $_[0];
    if ($itemi_id ~~ @ids_items_db){
        return true;
    } else {
        return false;
    }
}




#-----------------------------------------------------------------
true;
