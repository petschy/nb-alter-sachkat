#!/usr/local/bin/perl -w

use Modern::Perl '2017';
use utf8::all;
use autodie;
use MARC::File::USMARC;
use MARC::Record;
use MARC::Field;
use String::Util qw(trim);
use Data::Dumper;

# Filenames
my $marcfile = shift;
my $file_960 = "960.txt";
my $file_961 = "961.txt";
my $file_968 = "968.txt";

# Filehandles
my $fh_marc = IO::File->new( $marcfile, '<:utf8' );
my $fh_960  = IO::File->new( $file_960, '>:utf8' );
my $fh_961  = IO::File->new( $file_961, '>:utf8' );
my $fh_968  = IO::File->new( $file_968, '>:utf8' );

##########################
# header of output files #
##########################

my $bib_id         = "BIB_ID";
my $i1             = "I1";
my $i2             = "I2";
my $heading        = "Heading";
my $field_content  = "Feldinhalt mit UF-Codierung";
my $sf_a           = "UF a";
my $sf_b           = "UF b";
my $sf_c           = "UF c";
my $sf_d           = "UF d";
my $sf_x           = "UF x";
my $sf_y           = "UF y";
my $sf_z           = "UF z";
my $sf_9           = "UF 9";
my $sf_other       = "andere UF";
my @output_columns = ();
my $output         = "";

# Field 960
@output_columns = (
	$bib_id, $i1,   $i2,   $heading, $field_content,
	$sf_a,   $sf_b, $sf_c, $sf_d,    $sf_other
);
$output = join( "\t", @output_columns );
say $fh_960 $output;

# Field 961
@output_columns = (
	$bib_id, $i1,   $i2,   $heading, $field_content,
	$sf_a,   $sf_x, $sf_y, $sf_other
);
$output = join( "\t", @output_columns );
say $fh_961 $output;

# Field 968
@output_columns = (
	$bib_id, $i1,   $i2,   "DK",  $field_content, $sf_a,
	$sf_x,   $sf_y, $sf_z, $sf_9, $sf_other
);
$output = join( "\t", @output_columns );
say $fh_968 $output;

################
# MARC records #
################

my $record_counter = 1;
my $records        = MARC::File::USMARC->in($fh_marc);
while ( my $record = $records->next() ) {

	my $bib_id = $record->field('001')->as_string();
	$bib_id =~ s/^vtls//g;
	$bib_id = $bib_id;

	# Console output
	say "Record no. $record_counter:\t$bib_id";

	# Lists of 96x fields
	my @fields_960 = $record->field('960');
	my @fields_961 = $record->field('961');
	my @fields_968 = $record->field('968');

	# Field 960
	# ---------
	# Reset subfield data
	$i1            = "";
	$i2            = "";
	$heading       = "";
	$field_content = "";
	$sf_a          = "";
	$sf_b          = "";
	$sf_c          = "";
	$sf_d          = "";
	$sf_x          = "";
	$sf_y          = "";
	$sf_z          = "";
	$sf_9          = "";
	$sf_other      = "";
	foreach my $field (@fields_960) {

		$i1      = $field->indicator(1);
		$i2      = $field->indicator(2);
		$heading = lc $field->as_string();
		$heading =~ s/(\(|\))//g;
		$heading =~ s/ ; |, / /g;
		my @subfields = $field->subfields();
		( $sf_a, $sf_b, $sf_c, $sf_d, $sf_other ) = _subfields_960(@subfields);
		$field_content = _field_content(@subfields);

		# File output
		@output_columns = (
			$bib_id,        $i1,   $i2,   $heading,
			$field_content, $sf_a, $sf_b, $sf_c,
			$sf_d,          $sf_other
		);
		$output = join( "\t", @output_columns );
		say $fh_960 $output;
	}

	# Field 961
	# ---------
	# Reset subfield data
	$i1            = "";
	$i2            = "";
	$heading       = "";
	$field_content = "";
	$sf_a          = "";
	$sf_b          = "";
	$sf_c          = "";
	$sf_d          = "";
	$sf_x          = "";
	$sf_y          = "";
	$sf_z          = "";
	$sf_9          = "";
	$sf_other      = "";
	foreach my $field (@fields_961) {

		my $str = "";
		$i1      = $field->indicator(1);
		$i2      = $field->indicator(2);
		$heading = $field->subfield('a');
		$heading =~ s/(\(|\))//g;
		my @subfields = $field->subfields();
		( $sf_a, $sf_x, $sf_y, $sf_other ) = _subfields_961(@subfields);
		$field_content = _field_content(@subfields);

		# File output
		@output_columns = (
			$bib_id,  $i1,            $i2,
			$heading, $field_content, $sf_a,
			$sf_x,    $sf_y,          $sf_other
		);
		$output = join( "\t", @output_columns );
		say $fh_961 $output;
	}

	# Field 968
	# ---------
	# Reset subfield data
	$i1            = "";
	$i2            = "";
	$heading       = "";
	$field_content = "";
	$sf_a          = "";
	$sf_b          = "";
	$sf_c          = "";
	$sf_d          = "";
	$sf_x          = "";
	$sf_y          = "";
	$sf_z          = "";
	$sf_9          = "";
	$sf_other      = "";
	foreach my $field (@fields_968) {

		$i1 = $field->indicator(1);
		$i2 = $field->indicator(2);
		if ( $field->subfield('9') ) {
			$heading = $field->subfield('9');
			$heading =~ s/^ \| //;
			$heading =~ s/<-> //g;
		}
		else {
			$heading = 'KEINE DK';
		}
		my @subfields = $field->subfields();
		( $sf_a, $sf_x, $sf_y, $sf_z, $sf_9, $sf_other ) =
		  _subfields_968(@subfields);
		$field_content = _field_content(@subfields);

		# File output
		@output_columns = (
			$bib_id,        $i1,   $i2,   $heading,
			$field_content, $sf_a, $sf_x, $sf_y,
			$sf_z,          $sf_9, $sf_other
		);
		$output = join( "\t", @output_columns );
		say $fh_968 $output;
	}
	$record_counter++;
}

# Feldinhalt mit Unterfeldcodierungen
sub _field_content {
	my @subfields = @_;
	my $str       = "";
	while ( my $subfield = shift(@subfields) ) {
		my ( $code, $data ) = @$subfield;
		$str = "$str \$$code $data";
	}
	return trim($str);
}

sub _subfields_960 {
	my @subfields = @_;
	my $sf_a      = "";
	my $sf_b      = "";
	my $sf_c      = "";
	my $sf_d      = "";
	my $sf_other  = "";
	while ( my $subfield = shift(@subfields) ) {
		my ( $code, $data ) = @$subfield;
		if ( $code eq 'a' ) {
			$sf_a = "$sf_a | $data";
		}
		elsif ( $code eq 'b' ) {
			$sf_b = "$sf_b | $data";
		}
		elsif ( $code eq 'c' ) {
			$sf_c = "$sf_c | $data";
		}
		elsif ( $code eq 'd' ) {
			$sf_d = "$sf_d | $data";
		}
		else {
			$sf_other = "$sf_other | $data";
		}
	}
	$sf_a =~ s/^ \| //;
	$sf_b =~ s/^ \| //;
	$sf_c =~ s/^ \| //;
	$sf_d =~ s/^ \| //;
	$sf_other =~ s/^ \| //;
	my @arr = ( $sf_a, $sf_b, $sf_c, $sf_d, $sf_other );
	return @arr;
}

sub _subfields_961 {
	my @subfields = @_;
	my $sf_a      = "";
	my $sf_x      = "";
	my $sf_y      = "";
	my $sf_other  = "";
	while ( my $subfield = shift(@subfields) ) {
		my ( $code, $data ) = @$subfield;
		if ( $code eq 'a' ) {
			$sf_a = "$sf_a | $data";
		}
		elsif ( $code eq 'x' ) {
			$sf_x = "$sf_x | $data";
		}
		elsif ( $code eq 'y' ) {
			$sf_y = "$sf_y | $data";
		}
		else {
			$sf_other = "$sf_other | $data";
		}
	}
	$sf_a =~ s/^ \| //;
	$sf_x =~ s/^ \| //;
	$sf_y =~ s/^ \| //;
	$sf_other =~ s/^ \| //;
	my @arr = ( $sf_a, $sf_x, $sf_y, $sf_other );
	return @arr;
}

sub _subfields_968 {
	my @subfields = @_;
	my $sf_a      = "";
	my $sf_x      = "";
	my $sf_y      = "";
	my $sf_z      = "";
	my $sf_9      = "";
	my $sf_other  = "";
	while ( my $subfield = shift(@subfields) ) {
		my ( $code, $data ) = @$subfield;
		if ( $code eq 'a' ) {
			$sf_a = "$sf_a | $data";
		}
		elsif ( $code eq 'x' ) {
			$sf_x = "$sf_x | $data";
		}
		elsif ( $code eq 'y' ) {
			$sf_y = "$sf_y | $data";
		}
		elsif ( $code eq 'z' ) {
			$sf_z = "$sf_z | $data";
		}
		elsif ( $code eq '9' ) {
			$sf_9 = "$sf_9 | $data";
		}
		else {
			$sf_other = "$sf_other | $data";
		}
	}
	$sf_a =~ s/^ \| //;
	$sf_x =~ s/^ \| //;
	$sf_y =~ s/^ \| //;
	$sf_z =~ s/^ \| //;
	$sf_9 =~ s/^ \| //;
	$sf_other =~ s/^ \| //;
	my @arr = ( $sf_a, $sf_x, $sf_y, $sf_z, $sf_9, $sf_other );
	return @arr;
}

