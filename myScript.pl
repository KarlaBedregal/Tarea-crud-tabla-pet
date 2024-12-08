#!/usr/bin/perl

use strict; 
use warnings;

use CGI::Carp; # send errors to the browser, not to the logfile
use CGI;

my $cgi = CGI->new(); # create new CGI object

my $email = $cgi->param('email');
my $pwd = $cgi->param('pwd');

print $cgi->header('text/html');

print "Hello, $email, your password is $pwd";