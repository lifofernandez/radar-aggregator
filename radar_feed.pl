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
getopts('dhkf:',\%opts);

=pod

=head1 SYNOPSIS

Radar: Bajador de feeds rss y atom..

=head2 Forma de uso:

=over

=item -d debug 

=item -k Guardar todos los feeds que encuentre en "ALL.json".

=item -f [Archivo csv con feeds a parsear/bajar]

=back

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

if ($opts{k}){
	my $BIG = \%Results;
	my $BIGBIG = to_json $BIG;
	write_file("ALL.json", {binmode=>':utf8'}, $BIGBIG);
}

my $A = \%HOY;
my $AA = to_json $A;
my $archivo_salida_hoy = $t_banana . '.json';
write_file($archivo_salida_hoy, {binmode => ':utf8'}, $AA);

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
			my $tt_entry = DateTime->from_object( object => $tiempo_desde_creacion_del_entry_pre);
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

# Para mejorar/revisar

* No se que onda con los encodings. 
	# los reviso y te digo
* hay html embebido.... ¿Qué hacer con eso? __LIFO__
	# esta bien guardar descripcion y descripcionLimpia ¿o es mejor que lo haga des?
* El formato del JSON es arbitrario. 
	# en /public/hoy.json esta la estrcuctura que facilita todo desp
	# es un array de hashes creo, 
	

{
	"feeds": [
		{
		   "name"   : "TedCrhuch" 
		   "url"    : "httt:wpewepfmfm"  
		   "entries": [
				{
					"tags": null,
					"feed_url": "http://www.dataisnature.com",
					"description": "Illustration from The Design of Diagrams for Engineering Formulas and the Theory of Nomography &#8211; Laurence Hewes and Herbert Seward [1923] Laurence Hewes&#8217;s and Herbert Seward&#8217;s manual on the design of nomographs, published in 1923, is an unintentional masterpiece of analogue calculation aesthetics. The topologies and contours of these charts echo the systems they encapsulate. [&#8230;]",
					"author": "paul",
					"url": "http://www.dataisnature.com/?p=2222",
					"title": "The Music of Nomography –  Laurence Hewes’s & Herbert Seward’s ‘Design of Diagrams for Engineering Formulas’ and John Cage’s scores",
					"date": "2015-09-13T19:29:35+00:00",
					"descriptionClean": "Illustration from The Design of Diagrams for Engineering Formulas and the\n   Theory of Nomography – Laurence Hewes and Herbert Seward [1923]\n   Laurence Hewes’s and Herbert Seward’s manual on the design of\n   nomographs, published in 1923, is an unintentional masterpiece of\n   analogue calculation aesthetics. The topologies and contours of these\n   charts echo the systems they encapsulate.\n",
					"feed_categories": [
						"Arte"
					],
				},
				{
					"description": "Cyprea (Cowry) Shells from Thesaurus Conchyliorum &#8211; G.B Sowerby (Cyprea mappa shown in center) Remi Rorschach, one of a few dozen or so characters in George Perec&#8217;s immensely complex and ingeniously constrained masterpiece &#8216;Life a Users Manual&#8217;, has a series of seemingly incongruous occupations &#8211; Â first a clown and circus manager, then an international shell [&#8230;]",
					"tags": null,
					"url": "http://www.dataisnature.com/?p=2212",
					"title": "Cypraea mappa – The Mollusc Cartographer",
					"author": "paul",
					"feed": "Dataisnature",
					"feed_categories": [
						"Arte"
					],
					"date": "2015-08-20T19:40:28+00:00",
					"descriptionClean": "Cyprea (Cowry) Shells from Thesaurus Conchyliorum – G.B Sowerby (Cyprea\n   mappa shown in center) Remi Rorschach, one of a few dozen or so\n   characters in George Perec’s immensely complex and ingeniously\n   constrained masterpiece ‘Life a Users Manual’, has a series of\n   seemingly incongruous occupations – Â first a clown and circus\n   manager, then an international shell\n"
				}
			]
		},
		{
		   "name"   : "dataisnature" 
		   "url"    : "httt:dataisnature.orggga"  
		   "entries": [
				{
					"tags": null,
					"feed_url": "http://www.dataisnature.com",
					"description": "Illustration from The Design of Diagrams for Engineering Formulas and the Theory of Nomography &#8211; Laurence Hewes and Herbert Seward [1923] Laurence Hewes&#8217;s and Herbert Seward&#8217;s manual on the design of nomographs, published in 1923, is an unintentional masterpiece of analogue calculation aesthetics. The topologies and contours of these charts echo the systems they encapsulate. [&#8230;]",
					"author": "paul",
					"url": "http://www.dataisnature.com/?p=2222",
					"title": "The Music of Nomography –  Laurence Hewes’s & Herbert Seward’s ‘Design of Diagrams for Engineering Formulas’ and John Cage’s scores",
					"date": "2015-09-13T19:29:35+00:00",
					"descriptionClean": "Illustration from The Design of Diagrams for Engineering Formulas and the\n   Theory of Nomography – Laurence Hewes and Herbert Seward [1923]\n   Laurence Hewes’s and Herbert Seward’s manual on the design of\n   nomographs, published in 1923, is an unintentional masterpiece of\n   analogue calculation aesthetics. The topologies and contours of these\n   charts echo the systems they encapsulate.\n",
					"feed_categories": [
						"Arte"
					],
				},
				{
					"description": "Cyprea (Cowry) Shells from Thesaurus Conchyliorum &#8211; G.B Sowerby (Cyprea mappa shown in center) Remi Rorschach, one of a few dozen or so characters in George Perec&#8217;s immensely complex and ingeniously constrained masterpiece &#8216;Life a Users Manual&#8217;, has a series of seemingly incongruous occupations &#8211; Â first a clown and circus manager, then an international shell [&#8230;]",
					"tags": null,
					"url": "http://www.dataisnature.com/?p=2212",
					"title": "Cypraea mappa – The Mollusc Cartographer",
					"author": "paul",
					"feed": "Dataisnature",
					"feed_categories": [
						"Arte"
					],
					"date": "2015-08-20T19:40:28+00:00",
					"descriptionClean": "Cyprea (Cowry) Shells from Thesaurus Conchyliorum – G.B Sowerby (Cyprea\n   mappa shown in center) Remi Rorschach, one of a few dozen or so\n   characters in George Perec’s immensely complex and ingeniously\n   constrained masterpiece ‘Life a Users Manual’, has a series of\n   seemingly incongruous occupations – Â first a clown and circus\n   manager, then an international shell\n"
				}
			]
		}
	]
}