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

# headers
my $bib_id         = "BIB_ID";
my $i1             = "I1";
my $i2             = "I2";
my $heading        = "Feldinhalt";
my $field_content  = "Feldinhalt mit UF-Codierung";
my $sf_a           = "UF a";
my $sf_b           = "UF b";
my $sf_c           = "UF c";
my $sf_d           = "UF d";
my $sf_x           = "UF x";
my $sf_y           = "UF y";
my $sf_z           = "UF z";
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
	$bib_id, $i1,   $i2,   "DK",  $field_content,
	$sf_a,   $sf_x, $sf_y, $sf_z, $sf_other
);
$output = join( "\t", @output_columns );
say $fh_968 $output;

# MARC records
my $record_counter = 1;
my $records        = MARC::File::USMARC->in($fh_marc);
while ( my $record = $records->next() ) {

	my $bib_id = $record->field('001')->as_string();
	$bib_id =~ s/^vtls//g;
	$bib_id = $bib_id;

	# Reset values for output
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
	$sf_other      = "";

	# Console output
	say "Record no. $record_counter:\t$bib_id";

	# Lists of 96x fields
	my @fields_960 = $record->field('960');
	my @fields_961 = $record->field('961');
	my @fields_968 = $record->field('968');

	foreach my $field (@fields_960) {

		$i1 = $field->indicator(1);
		$i2 = $field->indicator(2);
		my $field_content = $field->as_string();

		# File output
		@output_columns = (
			$bib_id,        $i1,   $i2,   $heading,
			$field_content, $sf_a, $sf_b, $sf_c,
			$sf_d,          $sf_other
		);
		$output = join( "\t", @output_columns );
		say $fh_960 $output;
	}

	foreach my $field (@fields_961) {

		my $str = "";
		$i1 = $field->indicator(1);
		$i2 = $field->indicator(2);
		$heading = $field->as_string();
		$sf_a = $field->subfield('a');
		my @subfields     = $field->subfields();
		$field_content = _field_content( @subfields );

		# File output
		@output_columns = (
			$bib_id,        $i1,   $i2,   $heading,
			$field_content, $sf_a, $sf_b, $sf_c,
			$sf_d,          $sf_other
		);
		$output = join( "\t", @output_columns );
		say $fh_961 $output;
	}
	
	foreach my $field (@fields_968) {

		$i1 = $field->indicator(1);
		$i2 = $field->indicator(2);
		my $field_content = $field->as_string();

		#				_subfields( $field->subfields() );

		# File output
		@output_columns = (
			$bib_id,        $i1,   $i2,   $heading,
			$field_content, $sf_a, $sf_b, $sf_c,
			$sf_d,          $sf_other
		);
		$output = join( "\t", @output_columns );
		say $fh_968 $output;
	}
	$record_counter++;
}

sub _field_content {
	my @subfields = @_;
	my $str       = "";
	while ( my $subfield = shift(@subfields) ) {
			my ( $code, $data ) = @$subfield;
			say "Code: $code; Data: $data";
			$str = "$str \$$code $data";
	}
	return trim($str);
}

sub _subfields {
	my @subfields = @_;
	my $str       = "";

	#	say Dumper @subfields;
	while ( my $subfield = shift(@subfields) ) {
			my ( $code, $data ) = @$subfield;
			say "Code: $code; Data: $data";
			$str = "$str \$$code $data";

		#		say Dumper @$subfield;

	}
	return trim($str);
}

