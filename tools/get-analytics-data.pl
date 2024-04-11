#!/usr/bin/perl

use strict;

use Data::Dump;
use JSON;
use LWP::UserAgent;
use YAML;

use constant STATS_SUMMARY => 'https://stats.lms-community.org/api/stats';
use constant STATS_YAML => 'docs/analytics/stats.yaml';

my $stats;
eval {
    my $ua = LWP::UserAgent->new();
    $ua->ssl_opts(verify_hostname => 0);
    my $resp = $ua->get(STATS_SUMMARY);
	$stats = from_json($resp->content);
} || die "$@";

my %stats;
$stats{countries} = join("\n", map { my ($k, $v) = each %$_; qq("$k": $v) } @{$stats->{countries} || []});
$stats{os} = join("\n", map { my ($k, $v) = each %$_; qq("$k": $v) } @{$stats->{os} || []});
$stats{pluginLabels} = $stats->{plugins}->{names};
$stats{pluginCounts} = $stats->{plugins}->{counts};

YAML::DumpFile(STATS_YAML, \%stats);
