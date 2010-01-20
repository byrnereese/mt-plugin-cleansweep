
Clean Sweep Plugin For Movable Type
By: Byrne Reese <byrne at majordojo dot com>

Donated in whole to the Movable Type Open Source Project
Copyright 2007-2008 Six Apart Ltd. 

OVERVIEW

CleanSweep is a plugin that assists administrators in finding and fixing
broken inbound links to their website. It was build to support two use
cases:

* to help users get a clean start with their blog by allowing them to 
  completely restructure their permalink URL structure and have a system
  that can automatically adapt by redirecting stale and inbound links to
  the proper destination

* to help users in the process of migrating to Movable Type who are
  forced to modify their web site's URL and permalink structure

Both of these use cases have to do with preserving a site's page rank 
in light of a major redesign.

HOW IT WORKS

Under the Blog Plugin Settings, select the Clean Sweep and retrieve the
Apache configuration directive that will begin routing all 404s through
the Clean Sweep plugin.

Clean Sweep will then track all inbound links that result in a 404 and
will ultimately deduce the indended file and redirect the client to that
file.

Clean Sweep will also produce a set of Apache mod_rewrite rules to map
inbound links to their destination permanently.

REDIRECTION RULES

Clean Sweep will use the following ruleset in trying to guess the target
URL the client is requesting:

1) Is the target resource using the entry id as a URL
   This is a prevalent URL pattern for older MT installations. This will:

   Map: http://www.majordojo.com/archives/000675.php
   To:  http://www.majordojo.com/205/07/goodbye-bookque.php

2) Is the target resource using underscore when it should be using hyphens?
   Many users have switched to using hyphens for purported SEO benefits.
   This will attempt to look for a file in the system of the same name, but
   using '-' instead of '_'. This will:

   Map: http://www.majordojo.com/2005/07/goodbye_bookque.php
   To:  http://www.majordojo.com/2005/07/goodbye-bookque.php

3) Is their a target resource with the same basename somewhere?
   If a user switches their primary mapping to use a date based URL as 
   opposed to a category based URL, then this rule will apply. This will:

   Map: http://www.majordojo.com/personal-projects/goodbye-bookque.php
   To:  http://www.majordojo.com/2005/07/goodbye-bookque.php

4) Let me know and I will add it!

SUPPORTED WEB SERVERS

Clean Sweep supports both Apache and Lighttpd. For now you elect what web 
server you are using on a blog-by-blog basis. All documentation however, 
refers to Apache, as it is far more common. Lighttpd users should simply
follow the analogous instruction for their web server when appropriate.

INSTALL

1. Unpack the Clean Sweep archive.
2. Copy the contents of CleanSweep-1.x/plugins to:
   /path/to/mt/plugins/
3. Create a page in Movable Type called "URL Not Found". Give it a 
   basename of "404". Place whatever personalized message you want that
   will be displayed to your visitors when Clean Sweep is unsuccessful
   in mapping the request to the correct page or destination.
4. Publish the page and remember the complete URL to this page on your
   published blog.
5. Navigate to the Plugin Settings area for Clean Sweep.
6. Enter in the full URL to your "URL Not Found" page you created in 
   step #3. Copy that URL into the "404 URL" configuration parameter
   for Clean Sweep.
7. In your plugin settings area for Clean Sweep, make note of the 
   Apache configuration directive that Clean Sweep asks that you place
   in your httpd.conf or in an .htaccess file.
8. Add the Apache configuration directive to your web server. This may
   be placed in your httpd.conf file or in an .htaccess file located
   in the DocumentRoot for your blog.
9. Restart Apache

LICENSE

Clean Sweep is licensed under the GPL (v2).
