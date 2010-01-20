# Changes between 1.1 and 1.16

* 404 pages now properly return a status code of 404, when MT can
  guess the file path to the 404 page that is.
* fixed bug having to do with being unable to delete or reset broken 
  links in bulk
* fixed error with system dashboard widget
* thanks to michele for his help in fixing issues with ensuring
  apache configs are properly declared and reporting some DBI errors
* fixed bug in which _read_config could not be found
* lots of fixes to table listing

# Changes between 1.02 and 1.1

* fixed map dialog text input size
* added logic to automatically attempt to locate a redirect a user to the resource
  being requested

# Changes between 1.01 to 1.02

* fixed templating error that resulted when a 404 URL contained HTML
* added lighttpd suppport
