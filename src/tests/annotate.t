#! /usr/bin/perl
################################################################################
## task - a command line task list manager.
##
## Copyright 2006 - 2009, Paul Beckingham.
## All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, write to the
##
##     Free Software Foundation, Inc.,
##     51 Franklin Street, Fifth Floor,
##     Boston, MA
##     02110-1301
##     USA
##
################################################################################

use strict;
use warnings;
use Test::More tests => 8;

# Create the rc file.
if (open my $fh, '>', 'annotate.rc')
{
  print $fh "data.location=.\n",
            "report.r.description=r\n",
            "report.r.columns=id,description\n",
            "report.r.sort=id+\n";
  close $fh;
  ok (-r 'annotate.rc', 'Created annotate.rc');
}

# Add two tasks, annotate one twice.
qx{../task rc:annotate.rc add one};
qx{../task rc:annotate.rc add two};
qx{../task rc:annotate.rc annotate 1 foo};
sleep 2;
qx{../task rc:annotate.rc annotate 1 bar};
my $output = qx{../task rc:annotate.rc r};

# ID Description                    
# -- -------------------------------
#  1 one
#    3/24/2009 foo
#    3/24/2009 bar
#  2 two
# 
# 2 tasks
like ($output, qr/1 one/,   'task 1');
like ($output, qr/2 two/,   'task 2');
like ($output, qr/one.+\d{1,2}\/\d{1,2}\/\d{4} foo/ms, 'first annotation');
like ($output, qr/foo.+\d{1,2}\/\d{1,2}\/\d{4} bar/ms, 'second annotation');
like ($output, qr/2 tasks/, 'count');

# Cleanup.
unlink 'pending.data';
ok (!-r 'pending.data', 'Removed pending.data');

unlink 'annotate.rc';
ok (!-r 'annotate.rc', 'Removed annotate.rc');

exit 0;

