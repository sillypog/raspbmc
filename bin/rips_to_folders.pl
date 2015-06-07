#!/usr/bin/perl

use warnings;
use strict;

use Carp;
use Cwd;
use File::Spec;
use File::Copy;

#############################
# Script to be run as a cron job.
#
# Copy all the ripped files to 2 new locations:
# 1) unchanged flac files.
# 2) 192mbs MP3 files.
#
# Original folder structures are 'Artist Name/Album/Track Number - Track Name'
# Output will be 'Artist Name First Letter/Artist Name/Album/Track Number - Track Name'
#############################

my $source_dir = '/home/pi/cd_rips';
my $outputHi_dir = '/media/data/Music_flac';
my $outputLo_dir = '/media/data/Music_mp3';

# Go into each directory under source
# Run the flac_to_mp3 script
# Create all relevant directories in outputHi
# Create all relevant directories in outputLo
# Move all flac files to outputHi
# Move all mp3 files to outputLo

processDirectory($source_dir);

sub processDirectory{
	my $directory = $_[0];

	print STDOUT "\n\nChecking contents of $directory\n";

	chdir($directory) or die "Failed to change to $directory: $!\n";

	# Open directory so we can read the contents
	opendir(my $DIRECTORY, $directory) or die "Failed to open $directory: $!\n";

	# Prepare to read any directories not beginning with dots
	my @contents = File::Spec->no_upwards(readdir($DIRECTORY));

	# Sort the list of files alphabetically
	my @sorted_contents = sort {uc($a) cmp uc($b)} @contents;

	print STDOUT join("\n", @sorted_contents);

	# If this directory contains flac files, process them
	if (<*.flac>){
		print STDOUT "\nProcessing flac files in $directory\n";
		`flac_to_mp3.sh`;

		moveContents();	# Move the 2 different file types to the appropriate locations
	}

	# If the directory contains directories, descend into it and run again
	foreach my $entry (@sorted_contents){
		if (-d $entry){
			processDirectory(File::Spec->catdir($directory, $entry));
		}
	}

	# Reset for the next recursion
	chdir('..');
	closedir($DIRECTORY);
}

sub moveContents{
	my $cwd = getcwd;
	my @path_parts = File::Spec->splitdir( $cwd );
	my $album = pop(@path_parts);
	my $artist = pop(@path_parts);
	my $artistInitial = substr($artist,0,1);

	# Transform artistInitial to be in the A-Z_0 range.
	$artistInitial = uc($artistInitial);
	if ($artistInitial=~m/[\d]/){
		$artistInitial = '0';
	} elsif ($artistInitial=~m/\W|_/) {
		$artistInitial = '_';
	}

	print STDOUT "Moving contents from $album by $artist to $artistInitial\n";

	# Create the directories in the copy folders if they don't exist
	moveContentType('flac', $outputHi_dir, $artistInitial, $artist, $album);
	moveContentType('mp3', $outputLo_dir, $artistInitial, $artist, $album);

	# Ensure we're still where we should be
	chdir($cwd);
}

sub moveContentType{
	my $fileType = $_[0];
	my $outputDir = $_[1];
	my $artistInitial = $_[2];
	my $artist = $_[3];
	my $album = $_[4];

	my $cwd = getcwd;

	# Check if the artistInitial folder exists
	chdir($outputDir);
	unless(-e $artistInitial){
		mkdir($artistInitial) or die "Failed to create $artistInitial: $!\n";
	}

	chdir(File::Spec->catdir($outputDir, $artistInitial));

	# Check if this artist exists
	unless(-e $artist){
		mkdir($artist) or die "Failed to create $artist: $!\n";
	}

	chdir(File::Spec->catdir($outputDir, $artistInitial, $artist));
	if (-e $album){
		# Throw an error here - don't want to overwrite existing album
		carp "$album already exists in " . cwd . "\n";
	} else {
		mkdir($album) or die "Failed to create album: $!\n";
	}

	chdir ($cwd);

	# Copy the file type to the destination
	my $destination = File::Spec->catdir($outputDir, $artistInitial, $artist, $album);
	for my $file(<*.$fileType>){
		chomp($file);
		if (-e $file) {
			my $destinationFile = $destination . '/' . $file;
			print STDOUT "Moving $file to $destinationFile\n";
			move($file, $destinationFile) or die "Failure moving $file to $destinationFile: $!\n";
		} else {
			print STDOUT "$file does not exist\n";
		}
	}
}
