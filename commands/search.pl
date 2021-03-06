#!/usr/bin/perl -w

## Put extra dependencies here.
use DBI;

## Do not alter after this point until stated ##
use strict;
use warnings;
use Config::IniFiles;


my $ConfigFile = "/home/vps/.opendchub/scripts/chaosbot.conf";
tie my %ini, 'Config::IniFiles', (-file => $ConfigFile);
my %Config = %{$ini{"config"}};

my $x = '';
my @array = ();
my $user = $ARGV[0];
my $user_perm = $ARGV[1];
my $arg_first = $ARGV[2];
my $arg_second = $ARGV[3];
my $userip = $ARGV[4];
my $fire = $Config{fire};
$0 =~ s/^.*?(\w+)[\.\w+]*$/$1/;

if ($fire == 0 && $user_perm < 2) {
die;
}

sub output( @ ) {
  my @array = @_;
  for($x=0;$x<@array;$x++) {
    $array[$x] = $array[$x] . "Þ";
  }

  print @array;
}
## Do not alter before this point ##

## Info Block ##

#1# Command Name: search
#2# Description: This command finds lines that include the specified string
#3# Command used by: Operators
#4# Author: KY
#5# Date Created: 12/11/2011
#6# Date added to Bot: 12/11/2011

## Variables available to the script:

# User initiating the script :: $user
# Permission level of the User :: $user_perm
#	0 = Non registered
#	1 = Registered
#	2 = Op
#	3 = Admin
# args1 (The first word after the command) :: $arg_first
# args2 (The second word after the command) :: $arg_second
# eg -testcommand args1 args2

## Output values

# Fill in the required return values here and leave output(@array); as is.
# @array[0] Is the user initiating the script
# @array[1] Is the user the script acts upon
# @array[2] Is the type of message to be sent using the sendmessage function
# @array[3] Is the message to be sent back
# @array[4] If there is an odch function to be used name it here. If not leave blank or null
# @array[5] $fire determines whether or not the script actually fires.

## Message Types (for @array[2])

# The most oft used 'types' when sending to sendmessage are as follows:
# 2 Displays in main chat ONLY to the user
# 3 Sends a PM to the user
# 4 Sends to main chat for everyone

## End Info Block ##

## Place your module specific code here.
# Perl trim function to remove whitespace from the start and end of the string
sub trim($) {
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

my $string = trim("$arg_first $arg_second");

my $search = "'\%" . $string . "\%'";
my $message = "Showing all instances of $string\n";
#select * from cnlog where chat like '%nigger%';
my $dbh = DBI->connect("dbi:SQLite:" . $Config{dbloc} . $Config{db},"","");
my $query = "SELECT timestamp, nick, chat FROM $Config{log} WHERE chat LIKE $search";
my $handle = $dbh->prepare($query);
$handle->execute();
my ($timestamp, $nick, $chat) = ('', '', '');
$handle->bind_columns(\$timestamp, \$nick, \$chat);
while ($handle->fetch()) {
  $message .= "[" . $timestamp . "] <" . $nick . "> " . $chat . "\n";
}
$dbh->disconnect;

$array[0] = $user;
$array[1] = "";
$array[2] = 2;
$array[3] = $message;
$array[4] = "null";
$array[5] = $fire;

## Do not alter following line
output(@array);
