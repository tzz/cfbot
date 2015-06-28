#!/usr/bin/perl

use strict;
use warnings;
use Proc::Daemon;
use Cwd;
use Pod::Usage;
# libproc-daemon-perl 

=pod

=head1 SYNOPSIS

C<< daemon [-d|--dir <working directory> [-stat|-stop|-restart] >>

This script starts cfbot.pl as a daemon for normal use.

=head1 AUTHOR

Neil H. Watson, http://watson-wilson.ca, C<< <neil@watson-wilson.ca> >>

=head1 COPYRIGHT

Copyright (C) 2015 Neil H. Watson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

sub _get_cli_args
{
   use Getopt::Long qw/GetOptionsFromArray/;
   use Cwd;

   my $args->{dir} = getcwd();
   # Set default CLI args here. Getopts will override.
   my %arg = (
      dir => '/home/cfbot/cfbot'
   );

   my @args = @_;

   GetOptionsFromArray
   (
      \@args,
      \%arg,
      'help|?',
      'version',
      'start',
      'stop',
      'restart',
      'dir:s',
   )
   or eval
   {
      usage( 'USAGE' );
      exit 1;
   };
   return \%arg;
}

sub usage
{
   my $msg = shift;
   my $section;
   if ( $msg =~ m/\AEXAMPLES\Z/ )
   {
      $section = $msg;
   }
   else
   {
      $section = "SYNOPSIS";
   }
   pod2usage(
      -verbose  => 99,
      -sections => "$section",
      -msg      => $msg
   );
}

my $args = _get_cli_args( @ARGV );

if ( $args->{help} )
{
   usage( 'HELP' );
   exit;
}
=pod
elsif ( $args->{version} )
{
   say $VERSION;
   exit;
}
=cut

#my $args->{dir} = getcwd();
my $pid_file = $args->{dir}."/cfbot.pid";
my $d = Proc::Daemon->new(
   work_dir     => $args->{dir},
   pid_file     => $pid_file,
   exec_command => $args->{dir}."/cfbot.pl",
   setuid       => 'cfbot',
   setgid       => 'cfbot',
);

my %subs = ( 
   start   => \&start,
   stop    => \&stop,
   restart => \&restart
);

if ( $args->{start} )
{
   start();
}
elsif ( $args->{stop} )
{
   stop();
}
elsif ( $args->{restart} )
{
   stop();
   start();
}
else
{
   usage( 'USAGE' );
   exit 1;
}

sub start
{
   my $pid = $d->Init()
}

sub stop
{
   my $pid;
   open my $fh, '<', $pid_file
      or die "Cannot open pid file [$pid_file]";
   $pid .= $_ while (<$fh>);
   close $fh;
   kill 'TERM', $pid;
} 

sub restart
{
   stop();
   start();
}
