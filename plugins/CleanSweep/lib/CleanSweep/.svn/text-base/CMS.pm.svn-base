#!/usr/bin/perl -w
#
# This software is licensed under the Gnu Public License, or GPL v2.
# 
# Copyright 2007, Six Apart, Ltd.

package CleanSweep::CMS;

use strict;
use base qw( MT::App );
use CleanSweep::Plugin;

use MT::Util qw( encode_html format_ts offset_time_list offset_time epoch2ts
		 relative_date is_valid_date );

sub instance {
    return MT->component('CleanSweep');
}

sub id { 'cleansweep_cms' }

sub report {
    my $app = shift;
    my $q = $app->{query};
    my $blog = $app->blog;

    my $host = 'http://' . $ENV{'HTTP_HOST'} . $ENV{'REQUEST_URI'};
    my $base = $blog->site_url;

    my ($target) = ($host =~ /$base(.*)/);

    require CleanSweep::Log;

    my $log = CleanSweep::Log->load({ 
	uri     => $target, 
	blog_id => $blog->id,
    });
    unless ($log) {
	$log = CleanSweep::Log->new;
	$log->uri($target);
	$log->full_uri($ENV{'REQUEST_URI'});
	$log->blog_id($blog->id);
	$log->all_time_occur(0);
	$log->occur(0);
    }

    my $config = CleanSweep::Plugin::_read_config($blog->id); 
    my $redirect;

    # 301 - Moved permanently
    # 302 - Found, but redirect may change
    if ($log->mapping) { 
	$redirect = $log->mapping;
	$app->response_code("301");
    } elsif ($log->return_code) {
	$app->response_code($log->return_code);
	$redirect = $config->{'404url'};
#	$redirect = '';

    } elsif ($redirect = _guess_intended($app,$target)) {
	# do nothing? maybe try to fix permanently?
	# stream the found file to the browser?
	$app->response_code("302");

    } elsif ($config->{'404url'}) {
	$log->increment();
	$redirect = $config->{'404url'};
	my $path = _guess_file_path($app,$target);
	if ($path) {
            open NOTFOUND, $path;
            undef $/;
            my $contents = <NOTFOUND>;
            close NOTFOUND;
            $app->response_code("404");
            $log->save or return $app->error( $log->errstr );
            return $contents;
	}
	$app->response_code("404");

    } else {
	$redirect = $app->{cfg}->CGIPath . $app->{cfg}->SearchScript .'?IncludeBlogs='.$blog->id.'&keyword='.$target;
    }
    $log->save or return $app->error( $log->errstr );
    $app->redirect($redirect);

}

sub _guess_file_path {
    my $app = shift;
    my ($uri) = @_;
    my $blog = $app->blog;
    require MT::FileInfo;
    $uri =~ s!^http://[^/]*/!!;
    if (my $fi = MT::FileInfo->load({ url => "/$uri" })) {
	return $fi->file_path;
    }
}

sub _guess_intended {
    my $app = shift;
    my ($uri) = @_;
    my $blog = $app->blog;
    require MT::FileInfo;

    # Test 1: is the target a possible entry ID?
    if (my ($id) = ($uri =~ /\/(\d+)\.(php|html)$/)) {
	$id =~ s/^0+//; 
	my $fi = MT::FileInfo->load({ entry_id => $id });
	return $fi->url;
    }

    # Test 2: is the target using underscore when it should be using hyphens?
    my $uri_tmp = $uri;
    $uri_tmp =~ s/_/-/g;
    if (my $fi = MT::FileInfo->load({ url => "/$uri_tmp" })) {
	return $fi->url;
    }

    require MT::Entry;
    # Test 3: look for entry with same basename
    my ($basename,$ext) = ($uri =~ /\/([^\.]*)\.(\w+)$/i);
    $basename =~ s/-/_/g;
    if (my $e = MT::Entry->load({ basename => $basename, blog_id => $blog->id })) {
	my $fi = MT::FileInfo->load({ entry_id => $e->id });
	return $fi->url;
    }
    return undef;
}

sub _finder {
    # $_ is the file
    my $dir = $File::Find::dir;
    my $name = $File::Find::name;
    if ( -f $name ) {
#	print STDERR 'file: ' . $name . "\n";
    }
}

sub widget_links {
    my $app = shift;
    my ( $tmpl, $param ) = @_;
    require CleanSweep::Log;

    my $args   = { offset => 0, 
		   sort => 'occur', 
		   direction => 'descend', 
		   limit => 10,
	       };
    my $terms = {};
    $terms->{blog_id} => $app->blog->id if $app->blog;
    my @links = CleanSweep::Log->load( $terms, $args );
    my @link_loop;
    my $count = 0;
    foreach my $l (@links) {
	my $row = {
	    uri => $l->uri,
	    id  => $l->id,
	    occur => $l->occur,
	    count => $count,
	    '__odd__' => ($count++ % 2 == 0),
	};
	my $uri_short = $l->uri;
	if (length($uri_short) > 30) {
	    $uri_short =~ s/.*(.{30})$/\1/;
	    $row->{uri_short} = $uri_short;
	}
	push @link_loop, $row;
    }

    $param->{html_head} .= '<link rel="stylesheet" href="'.$app->static_path.'plugins/CleanSweep/styles/app.css" type="text/css" />';
    $param->{object_loop} = \@link_loop;
}

sub list_404 {
    my $app = shift;
    my %param = @_;

    my $author    = $app->user;
    my $list_pref = $app->list_pref('404');

    my $base = $app->blog->site_url;
    my $date_format          = "%Y.%m.%d";
    my $datetime_format      = "%Y-%m-%d %H:%M:%S";

    my $code = sub {
        my ($obj, $row) = @_;

#        $row->{'column1'} = $obj->id;
#        $row->{'column2'} = $obj->title;
#        my $ts = $row->{created_on};
#        $row->{date} = relative_date($ts, time);

	my $map;
	if ($obj->mapping) {
	    ($map) = ($obj->mapping =~ /$base(.*)/);
	}
	$row->{uri_long} = encode_html($obj->uri);
	$row->{id} = $obj->id;
	$row->{return_code} = $obj->return_code;
	$row->{map_full} = $obj->mapping;
	$row->{map} = $map || "<em>" . $app->translate("None") . "</em>";
	$row->{is_mapped} = ($obj->return_code ne "");
	$row->{all_time} = $obj->all_time_occur;
	$row->{count} = $obj->occur;

	if ($obj->mapping) { $row->{return_code} = "301"; }
	my $uri_short = $obj->uri;
	if (length($uri_short) > 50) {
	    $uri_short =~ s/.*(.{50})$/\1/;
	    $row->{uri_short} = $uri_short;
	}
        if ( my $ts = $obj->last_requested ) {
	    $row->{created_on_formatted} =
		format_ts( $date_format, $ts, $app->blog, $app->user ? $app->user->preferred_language : undef );
	    $row->{created_on_time_formatted} =
              format_ts( $datetime_format, $ts, $app->blog, $app->user ? $app->user->preferred_language : undef );
            $row->{created_on_relative} =
              relative_date( $ts, time, $app->blog );
        }
    };

    my %terms = (
		 blog_id => $app->blog->id,
    );

    my %args = (
		limit => $list_pref->{rows},
		offset => $app->param('offset') || 0,
		sort => 'occur',
		direction => 'descend',
    );

    my %params = (
                  'map_saved' => $app->{query}->param('map_saved') == 1,
                  'uri_reset' => $app->{query}->param('uri_reset') == 1,
                  'nav_404' => 1,
                  'list_noncron' => 1,
    );
    my $plugin = instance();
    $app->listing({
        type     => 'cleansweep.log',
        terms    => \%terms,
        args     => \%args,
        listing_screen => 1,
        code     => $code,
        template => $plugin->load_tmpl('list.tmpl'),
        params   => \%params,
    });
}

sub reset {
    my $app = shift;
    my $param;
    my $q = $app->{query};
    require CleanSweep::Log;
    my $link = CleanSweep::Log->load($q->param('id'));
    if ($link) { $link->reset(); }
    my $cgi = $app->{cfg}->CGIPath . $app->{cfg}->AdminScript;
    $app->redirect("$cgi?__mode=list_404s&blog_id=".$app->blog->id."&uri_reset=1");
}

sub itemset_reset_404s {
    my ($app) = @_;
    $app->validate_magic or return;

    my @links = $app->param('id');

    require CleanSweep::Log;
    LINK: for my $link (@links) {
        my $link = CleanSweep::Log->load($link)
          or next LINK;
        $link->reset();
    }
    my $cgi = $app->{cfg}->CGIPath . $app->{cfg}->AdminScript;
	$app->redirect("$cgi?__mode=list_404s&blog_id=".$app->blog->id."&uri_reset=1");
}

sub delete {
    my $app = shift;
    my $q = $app->{query};
    my $link = CleanSweep::Log->load($q->param('id'));
    if ($link) { $link->remove(); }
    my $cgi = $app->{cfg}->CGIPath . $app->{cfg}->AdminScript;
    $app->redirect("$cgi?__mode=list_404s&blog_id=".$app->blog->id."&uri_delete=1");
}

sub itemset_delete_404s {
    my ($app) = @_;
    $app->validate_magic or return;

    my @links = $app->param('id');

    require CleanSweep::Log;
    LINK: for my $link (@links) {
        my $link = CleanSweep::Log->load($link)
          or next LINK;
        $link->remove();
    }
    my $cgi = $app->{cfg}->CGIPath . $app->{cfg}->AdminScript;
	$app->redirect("$cgi?__mode=list_404s&blog_id=".$app->blog->id."&uri_delete=1");
}

sub save_map {
    my $app = shift;
    my $param;
    my $q = $app->{query};
    require CleanSweep::Log;
    my $link = CleanSweep::Log->load($q->param('id'));
    unless ($link) { 
	$link = CleanSweep::Log->new; # this can never happen
    }
    $link->map('');
    $link->return_code($q->param('return_code')); 
    if ($q->param('return_code') eq "301") {
	$link->map($q->param('destination')); 
    }
    $link->save or return $app->error( $link->errstr );

    my $cgi = $app->{cfg}->CGIPath . $app->{cfg}->AdminScript;
    $app->redirect("$cgi?__mode=list_404s&blog_id=".$app->blog->id."&map_saved=1");
}

sub map {
    my $app = shift;
    my ($param) = @_;
    my $q = $app->{query};

    $param ||= {};

    my $blog = $app->blog;
    my $base = $blog->site_url;
    require CleanSweep::Log;
    my $link = CleanSweep::Log->load($q->param('id'));

    my $config = CleanSweep::Plugin::_read_config($blog->id); 

    $param->{base_url}    = $base;
    $param->{uri}         = $link->uri;
    $param->{id}          = $link->id;
    $param->{blog_id}     = $app->blog->id;
    $param->{map}         = $link->mapping;
    $param->{return_code} = $link->return_code || "301";
    $param->{is_mapped}   = ($link->return_code ne "" || $link->mapping ne ""),
    return $app->load_tmpl( 'dialog/map.tmpl', $param );
}

sub rules {
    my $app = shift;
    my $q = $app->{query};

    my $param ||= {};

    my $blog = $app->blog;
    my $base = $blog->site_url;

    my $args   = { sort => 'uri', direction => 'ascend' };

    require MT::Request;
    my $cfg = plugin()->get_config_hash('blog:'.$blog->id);

    require CleanSweep::Log;
    my @links = CleanSweep::Log->load( { blog_id => $app->blog->id }, $args );
    my @link_loop;
    foreach my $l (@links) {
	my $row = {
	    id   => $l->id,
	    uri  => $l->uri,
	    map  => $l->mapping,
	    code => $l->return_code || "301",
	    has_mapping => $l->return_code ne '' || $l->mapping ne '', 
	};
	if ($l->return_code eq "410") { $row->{redir_code} = "G"; } 
	elsif ($l->return_code eq "403") { $row->{redir_code} = "F"; } 
	elsif ($l->mapping) { $row->{redir_code} = "R=301"; }  
	push @link_loop, $row;
    }
    $param->{object_loop} = \@link_loop;

    my $config = CleanSweep::Plugin::_read_config($app->blog->id); 
    $param->{base_url} = $base;
    $param->{blog_id} = $app->blog->id;
    $param->{webserver} = $cfg->{'webserver'};

    return $app->load_tmpl( 'dialog/rules.tmpl', $param );
}

sub plugin {
    MT->component('CleanSweep');
}

1;
