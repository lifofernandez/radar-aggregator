package radar;
use Dancer2;
use utf8;
use File::Slurp;
use POSIX q/strftime/;
use Data::Dumper;

#my $t_banana = strftime ("%d_%B_%Y_%H_%M_%S",localtime(time()));

our $VERSION = '0.1';

get '/' => sub {
    my $data_file           = read_file config->{radar}{entries};
    my $desc                = config->{radar}{descripcion};
    my $data                = from_json $data_file;
    #print Dumper($data);
    #my $data_sin_array      = @$data;
    template 'index',       { data => $data , descripcion => $desc};
};





true;
