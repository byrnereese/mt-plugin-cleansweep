# Good for Nothing Plugin for Movable Type
# Author: Byrne Reese
# Copyright (C) 2008 Six Apart, Ltd.
# This file is licensed under the GPL.

package CleanSweep::Plugin;
use strict;

sub instance {
    MT->component('CleanSweep');
}

sub _read_config {
    my ($blog_id,$options) = @_;
    $options = {} if !defined($options);
    require MT::Request;
    my $config = MT::Request->instance->stash('CleanSweepConfig');
    return $config if (defined($config));
    my $plugin = instance();
    $config = $plugin->get_config_hash('blog:'.$blog_id);
    MT::Request->instance->stash('CleanSweepConfig',$config);
    return $config;
}

sub blogconf_template {
    my ($plugin,$param,$scope) = @_;
    my $app = MT::App->instance;
    my $cfg = _read_config($app->blog->id, { ignore_errors => 1} );
    my $script = $app->{cfg}->CGIPath . $app->{cfg}->AdminScript;
    my $bid = $app->blog->id;
    my $url = $app->blog->site_url;
    $url =~ s!https?://[^/]*!!i;
    $script =~ s!https?://[^/]*!!i;
    my $tmpl = "";
    $tmpl .= <<EOT;
    <fieldset>
    <div id="404-url" class="field field-left-label pkg ">
      <div class="field-header">
        <label for="accesskey">404 URL:</label>
      </div>
      <div class="field-content">
        <p><input type="text" size="50" name="404url" value="<TMPL_VAR NAME=404URL>" /><br />
        Enter the URL to redirect the user to when a resource cannot be found.</p>
      </div>
    </div>
    <div id="webserver" class="field field-left-label pkg ">
      <div class="field-header">
        <label for="accesskey">Web Server:</label>
      </div>
      <div class="field-content">
        <input type="radio" name="webserver" value="apache" onclick="show('apache-config'); hide('lighttpd-config');" <mt:if name="webserver" eq="apache">checked</mt:if> /> Apache
        <input type="radio" name="webserver" value="lighttpd" onclick="show('lighttpd-config'); hide('apache-config');" <mt:if name="webserver" eq="lighttpd">checked</mt:if> /> Lighttpd
      </div>
    </div>
    </fieldset>
    <fieldset>
    <div id="apache-config" class="field field-left-label pkg " style="<mt:if name="webserver" ne="apache">display:none;</mt:if>">
      <div class="field-header">
        <label for="accesskey">Apache Config:</label>
      </div>
      <div class="field-content">
        <p>Add this to your Apache configuration file:</p>
        <pre><code>
&lt;Location $url&gt;
  ErrorDocument 404 $script?__mode=404&blog_id=$bid
&lt;/Location&gt;
        </code></pre>
      </div>
    </div>
    <div id="lighttpd-config" class="field field-left-label pkg " style="<mt:if name="webserver" ne="lighttpd">display:none;</mt:if>">
      <div class="field-header">
        <label for="accesskey">LigHTTPD Config:</label>
      </div>
      <div class="field-content">
        <p>Add this to your Lighttpd configuration file:</p>
        <pre><code>
server.error-handler-404 = "$script?__mode=404&blog_id=$bid"
        </code></pre>
      </div>
    </div>
    </fieldset>
EOT
    $tmpl;
}

1;
