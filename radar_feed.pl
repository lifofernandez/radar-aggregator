#!/usr/bin/perl
######################################################################
# Radar coso 
######################################################################
use strict;
#use warnings;
use autodie;
use feature         "say";
use POSIX           "strftime";
use Getopt::Std;
use Pod::Usage;
use Data::Dumper;
use File::Slurp     qw(read_file write_file);

#pal rss
use XML::FeedPP;
use DateTime;
use DateTime::Format::W3CDTF; 
use XML::Entities;
use JSON            "to_json";

# O P T s
my %opts = ();
getopts('dhf:',\%opts);

=pod

=head1 SYNOPSIS

Radar: Bajador de feeds rss y atom..

=cut

######################################################################
# VARIABLES GLOBALES
######################################################################
my $debug = $opts{d};
my $t_banana = strftime ("%d_%B_%Y",localtime(time()));
my $archivo_urls_categorias_csv = 'feeds.csv';
my @uri_rss_all     = ();
my %RSS             = ();
my %Noticias        = ();
my %Results         = ();
my %HOY             = ();
my $hoy = DateTime->now(@_)->truncate( to => 'minute' );
my $un_dia = 60 * 60 * 24 + 10;


######################################################################
# M A I N
######################################################################
if ($opts{h}){
    ayudas();
    exit 0;
}

if ($opts{f}){
    die unless -e $opts{f};
    $archivo_urls_categorias_csv = $opts{f};
}

# Recontra-Main   
feeds_list($archivo_urls_categorias_csv);
print Dumper(%RSS) if $debug;
url_getter();

=pod

=head2

Al final se pasa el hasref a un json!

=cut
my $BIG = \%Results;
my $BIGBIG = to_json $BIG;
write_file("todas_las_entradas.json", {binmode=>':utf8'}, $BIGBIG);

my $A = \%HOY;
my $AA = to_json $A;
write_file("HOY.json", {binmode => ':utf8'}, $AA);

#fin
exit 0;

######################################################################
# S U B S
######################################################################
sub feeds_list {
    my $file_name = shift;
    my $n = 0;
    my @datas = read_file($file_name);
    foreach my $ln (@datas){
        chomp($ln);
        my @r = split(/,/,$ln);
        print Dumper(@r) if $debug;
        $RSS{$n} = \@r;
        push (@uri_rss_all,$r[0]);
        $n++;
    }
}

=pod

=head2 FeedPP

La funcion url_getter hace todo el trabajo con los Rss.

Utiliza XML::FeedPP.

=cut

sub url_getter {
    foreach my $uri_rss (@uri_rss_all){
        my $feed = XML::FeedPP->new($uri_rss);
        my %entries_stuffs = ();
        my %entries_hoy = ();
        my $nro = 0;
        for my $entry ($feed->get_item()){
            print Dumper($entry) if $debug;

            $entries_stuffs{$nro}{'title'}   = decode_shits($entry->title);
            $entries_stuffs{$nro}{'author'}  = decode_shits($entry->author);
            $entries_stuffs{$nro}{'link'}    = decode_shits($entry->link);
            $entries_stuffs{$nro}{'content'} = decode_shits($entry->description);
            $entries_stuffs{$nro}{'time'}    = tiempo_lindo($entry->pubDate);
            
            # FIJARSE SI ES NUEVO (HASTA HACE UN DIA ATRAS)
            my $chiotto = DateTime::Format::W3CDTF->new;
            my $tiempo_desde_creacion_del_entry_pre = $chiotto->parse_datetime($entry->pubDate);
            print Dumper($tiempo_desde_creacion_del_entry)if $debug; ############ DEBUUGUGUGUGUGUGUGUEARRRR ACA!!!!
            my $tiempo_desde_creacion_del_entry = $hoy->epoch() - $tiempo_desde_creacion_del_entry_pre->epoch();
            say $tiempo_desde_creacion_del_entry if $debug;
            
            if ($tiempo_desde_creacion_del_entry <= $un_dia + 20){
                say "es de hoy" if $debug;
                $entries_hoy{$nro}{'title'}   = decode_shits($entry->title);
                $entries_hoy{$nro}{'author'}  = decode_shits($entry->author);
                $entries_hoy{$nro}{'link'}    = decode_shits($entry->link);
                $entries_hoy{$nro}{'content'} = decode_shits($entry->description);
                $entries_hoy{$nro}{'time'}    = tiempo_lindo($entry->pubDate);
            }
            $nro++;
        }
        $Results{$feed->title}  = \%entries_stuffs;
        $HOY{$feed->title}      = \%entries_hoy;
    }
}

sub decode_shits {
    my $shit = shift;
    my $coso_sin_codificar = XML::Entities::decode('all',$shit);
    return $coso_sin_codificar;
}

sub tiempo_lindo {
    my $st = shift;
    my $fecha_bien_laputaquetepario = $st;
    $fecha_bien_laputaquetepario    =~ s/([^T]+)T([^T]+)/\2 \1/g;
    return $fecha_bien_laputaquetepario;    
}

sub ayudas {
    pod2usage(-verbose=>3);
}
__DATA__

# Para mejorar

* No se que onda con los encodings.
* No me gusta el metodo para ver si la fecha del articulo es de hoy
* hay html embebido.... ¿Qué hacer con eso?
* El formato del JSON es arbitrario.

~~ Pasar a FeedPP que es mejor!~~

~~W3CDTF:: Es el nombre ISO del formato en el que (deberían) está el tiempo en rss/atom.~~


Hay una cagada con el tiempo y el objeto que parsea la gilada: no hace la cuenta!



