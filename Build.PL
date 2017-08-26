#!/usr/bin/perl -w
use strict;
use warnings;

use File::Basename 'dirname';
use Module::Build 0.30;

my $VERSION_BASE = '1.0';
my ($VERSION, %P);

for (my $i = 0; $i <= $#ARGV; $i++) {
	if ($ARGV[$i] =~ /^--build(?:=(\d+))?$/) {
		splice @ARGV, $i, 1;
		$P{build} = $1 // splice @ARGV, $i, 1;
		next unless @ARGV;
	}
}

if (exists $ENV{VERSION}) {
	$VERSION = $ENV{VERSION};
} elsif (-d 'debian/' && -f 'debian/changelog') {
	$VERSION = `dpkg-parsechangelog -ldebian/changelog --show-field Version`;
	$VERSION =~ s/\s//g;
	$VERSION =~ s/-\d+$//;
} else {
	unless (defined $P{build}) {
		$P{build} = $ENV{BUILD_ID}
			if exists $ENV{BUILD_ID};
	}

	unless (defined $P{build}) {
		print STDERR "Cannot determine module build version.\n";
		exit 1;
	}

	$VERSION = "$VERSION_BASE.$P{build}";
}

my $pm_file = dirname __FILE__;
$pm_file .= '/lib/Getopt/Complete.pm';

open my $fp, '<', $pm_file or die "'$pm_file' not found?";
my $content = do {local $/; <$fp>};
close $fp;

$content =~ s/^.*##VERSION-TAG/\$VERSION = '$VERSION'; ##VERSION-TAG/m;

chmod 0644, $pm_file or die "'$pm_file' could not be chmodded: $!";
open $fp, '>', $pm_file or die "'$pm_file' cannot be written to: $!";
print $fp $content;
close $fp;

my %module_build_args = (
	dist_abstract => 'Command line processing with extensive usage generation',
	dist_author => [q(Oliver Schieche <schiecheo@cpan.org>)],
	dist_name => 'libgetopt-complete',
	release_status => 'stable',

	build_requires => {
		'Module::Build' => '0.30',
	},
	configure_requires => {
		'ExtUtils::MakeMaker' => 0,
		'Module::Build' => '0.30'
	},
	license => 'restrictive',
	module_name => 'Getopt::Complete',
	requires => {
		'Readonly' => 0
	},
	test_requires => {
		'Capture::Tiny' => 0,
		'Test::More' => 0,
		'Test::MockObject::Extends' => 0
	}
);


my %fallback_build_requires = (
	'Module::Build' => '0.30',
	'Test::More' => 0
);

unless (eval {Module::Build->VERSION(0.4004)}) {
	delete $module_build_args{test_requires};
	$module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
