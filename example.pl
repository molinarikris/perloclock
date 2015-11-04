#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use Cache::Memcached;
use DateTime;

my $cache = new Cache::Memcached {
  'servers' => ['localhost:11211']
};
my $dt = DateTime->now();
$dt = $dt->set_time_zone('America/Chicago');
my $dbh = DBI->connect("DBI:mysql:perlmysql", "root", "");


die "Failed to connect to MySQL.\n DBI->errstr()" if (!$dbh) ;

if ($ARGV[0] eq "start") {
  unless ($cache->get('clocked-in')) {
    my $sql = "INSERT INTO punchIn(time)
      VALUES( NOW() )";
    $dbh->do($sql);
    $cache->set('clocked-in', $dt);
    print("You successfully clocked-in.\n")
  } else {
    print("You're already punched in!\n");
  }
} elsif ($ARGV[0] eq "stop") {
  if ($cache->get('clocked-in')) {
    my $sql = "INSERT INTO punchOut(time)
      VALUES( NOW() )";
    $dbh->do($sql);
    $cache->delete('clocked-in');
    print("You successfully clocked-out.\n")
  }
} elsif ($ARGV[0] eq "status") {
  print("Status: \n");
  if ($cache->get('clocked-in')) {
    print("Clocked in at \033[32m", $cache->get('clocked-in'), "\033[0m.\n");
  } else {
    print("Not clocked in.\n");
  }
} else {
  print("Timeclock: Usage\n \033[32mtimeclock start\033[0m\n\tRegister a clock-in.\n")
}

$dbh->disconnect();

# Subroutines/functions
