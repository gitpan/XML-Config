#(c)2000 XML Global Technologies, Inc. 
# $Id: Config.pm,v 1.1 2000/05/01 21:53:40 matt Exp $

package XML::Config;
use XML::Parser;
use vars qw($VERSION);

my $err_str = undef;
$VERSION = 0.1;


sub new {
	my $class = shift;
	my $self = {};
	bless($self,$class);
	return($self);
}



sub load_conf {
	my $self = shift;
	
	foreach my $file (@_) {
		eval {
			my $xp = new XML::Parser(parent => $self, Handlers => {Char => \&GoXML::Config::__charparse});
			$xp->parsefile($file);
			undef($xp);
		};
		
		if ($@) {
			
			if ($@ !~ m!file.*found!i) {
				my $fbak = $file . '.bak';
				undef($@);
				
				eval {
					my $xp = new XML::Parser(parent => $self, Handlers => {Char => \&GoXML::Config::__charparse});
					$xp->parsefile($file);
					$err_str = "WARN: Loaded backup configuration\n";
					undef($xp);
				};
				
				if ($@) {		
					$err_str = "PARSE ERROR, BACKUP READ ATTEMPTED: $@\n";
					return(undef);
				}
			}
			
			else {
				$err_str = "PARSE ERROR: $@\n";
				return(undef);
			}
			
		}	
		
	}
	
	my $conf = $self->{conf};
	
	return %{$conf};
}


sub err_str { return $err_str }

sub __charparse {
	my ($xp,$str) = @_;
	my $self = $xp->{parent};
	return if $str =~ /^\s*$/m;
	$self->{conf}{$xp->current_element} = $str;
}

__END__

=pod
=head1 NAME
XML::Config
=head1 VERSION INFORMATION

Version: 0.1

$Id: Config.pm,v 1.1 2000/05/01 21:53:40 matt Exp $

=head1 SYNOPSIS

use XML::Config;

my $cfg = new XML::Config;
my %CONF = $cfg->load_conf("path/to/file.xml");

=head1 DESCRIPTION

XML::Config is a simple shallow XML to hash converter.  Given a configuration file in the form:

<xml_config>
	<foo>Bar</foo>
	<bar>Foo</bar>
</xml_config>

... XML::Config->load_conf returns:

{
	foo => 'bar',
	bar => 'foo'
}


XML::Config will also try to load "path/to/file.xml.bak" in the case of a non-file not found parse error.
if it does this, it will set the err_str to "WARN: Loaded backup configuration\n";

XML::Config doesn't care about your root tag, or any naming of tags.

=head1 METHODS

load_conf($conf_file_path)
err_str()

=head1 AUTHOR

XML Global Technologies, Inc (Matthew MacKenzie)

=head1 COPYRIGHT

(c)2000 XML Global Technologies, Inc.



				
