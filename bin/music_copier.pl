#!/usr/bin/perl

use warnings;
use strict;
use Cwd;
use File::Copy::Recursive qw (dircopy);

$| = 1; # Flush print buffer immediately


# Get the name of the directory to search from the command line
my $top_dir = getcwd;
print ("Starting in $top_dir\n");

my $source_dir;# = $top_dir.'/';
my $destination_dir;# = $top_dir.'/';
if($ARGV[0] && $ARGV[1]){
	# Check whether or not we have an absolute path
	if($ARGV[0]=~m/^\//){
		print "Source path is absolute.\n";
	} else {
		print "Source path is relative.\n";
		$source_dir = $top_dir.'/';
	}
	if($ARGV[1]=~m/^\//){
		print "Destination path is absolute.\n";
	} else {
		print "Destination path is relative.\n";
		$destination_dir = $top_dir.'/';
	}


	$source_dir .= $ARGV[0];
	$destination_dir .= $ARGV[1];
} else {
	die "Source and destination directories must be provided.\n";
}

print STDOUT "\nChecking contents of $source_dir\n";

opendir(my $SOURCE_HANDLE, $source_dir) or die "Failed to open source directory $source_dir: $!";
opendir(my $DEST_HANDLE, $destination_dir) or die "Failed to open destination directory $destination_dir: $!";

# Store the names of created directories here so that we don't have to keep checking file system
my %created;


# Prepare to read any directories not beginning with dots
my @contents = grep(!/^\./,  readdir($SOURCE_HANDLE));

# Sort the list of files alphabetically
my @sorted_contents = sort {uc($a) cmp uc($b)} @contents;

chdir $source_dir or die "Failed to change to $source_dir: $!\n";

foreach my $entry (@contents){

	# If it is a directory, get the first letter.
	if (-d $entry){
		my $first_letter = substr($entry,0,1);
		$first_letter = uc($first_letter);
		if ($first_letter=~m/[\d]/){
			$first_letter = '0';
		} elsif ($first_letter=~m/\W|_/) {
			$first_letter = '_';
		}

		# Check if the entry has already been copied across.
		my $copied = &checkCopied($entry, $first_letter);

		# If it has not been, copy it.
		unless($copied){
			&copyEntry($entry, $first_letter);
		}
	}
}


# Close the directory handle
closedir($SOURCE_HANDLE);
closedir($DEST_HANDLE);


########################

########################

sub checkCopied{
	my $entry = $_[0];
	my $first_letter = $_[1];

	print "Performing checkCopied on $entry.\n";

	my $copied = 0;

	chdir($destination_dir) or die "A. Failed to change to $destination_dir: $!\n";
	if (-e $first_letter){
		$created{$first_letter} = 1;
		chdir($first_letter) or die "B. Failed to change to letter_path $first_letter: $!\n";
		if (-e $entry){
			$copied = 1;
		}
	}
	chdir($source_dir) or die "C. Failed to change back to $source_dir: $!\n";

	return $copied;
}

sub copyEntry{
	my $entry = $_[0];
	my $first_letter = $_[1];

	print "Performing copyEntry on $entry.\n";

	# If there isn't a directory with that (uppercased) letter in the destination, make it.
	unless ($created{$first_letter}){
		$created{$first_letter} = 1;
		print("Creating directory $first_letter because of $entry\n");
		chdir($destination_dir) or die "D. Failed to change to $destination_dir: $!\n";
		# Double check the existance
		unless(-e $first_letter){
			mkdir($first_letter) or die "E. Failed to create $first_letter: $!\n";
		} else {
			print ("$first_letter already exists\n");
		}
		chdir($source_dir) or die "F. Failed to change back to $source_dir: $!\n";
		print ("\n");
	}
	# Copy the folder to the letter directory
	print ("Copying $entry to $first_letter\n");
	dircopy($entry, $destination_dir.'/'.$first_letter.'/'.$entry);

}
