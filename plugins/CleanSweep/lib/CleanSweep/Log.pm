#!/usr/bin/perl -w
#
# This software is licensed under the Gnu Public License, or GPL v2.
# 
# Copyright 2007, Six Apart, Ltd.

package CleanSweep::Log;

use strict;
use MT::Object;
use base qw( MT::Object );

__PACKAGE__->install_properties({
    column_defs => {
	'id'             => 'integer not null auto_increment', 
	'blog_id'        => 'integer not null', 
	'uri'            => 'string(255) not null',
	'full_uri'       => 'string(255) not null',
	'occur'          => 'integer not null',
	'all_time_occur' => 'integer not null',
	'return_code'    => 'string(5)',
	'mapping'        => 'string(255)',
	'last_requested' => 'datetime',
    },
    indexes => {
	blog_id => 1,
	created_on => 1,
	uri => 1,
    },
    audit => 1,
    datasource => 'cleansweep_log',
    primary_key => 'id',
});

sub increment {
    my $obj = shift;
    if (!$obj->all_time_occur) {
	$obj->occur(0);
	$obj->all_time_occur(0);
    } 
    $obj->occur( $obj->occur + 1 );
    $obj->all_time_occur( $obj->all_time_occur + 1 );

    my @ts = MT::Util::offset_time_list(time, $obj->blog_id);
    my $ts = sprintf '%04d%02d%02d%02d%02d%02d', $ts[5]+1900, $ts[4]+1, @ts[3,2,1,0];
    $obj->last_requested($ts);
}

sub reset {
    my $obj = shift;
    $obj->occur(0);
    $obj->save;
}

sub map {
    my $obj = shift;
    my ($dest) = @_;
    $obj->mapping($dest);
    $obj->save;
}

1;
