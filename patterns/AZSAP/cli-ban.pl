#!/usr/bin/perl

# Title:       Totem Configuration
# Description: Checks totem configuration in corosync.conf
# Modified:    2013 Jun 21

##############################################################################
#  Copyright (C) 2013 SUSE LLC
##############################################################################
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, see <http://www.gnu.org/licenses/>.

#  Authors/Contributors:
#   Jason Record (jrecord@suse.com)

##############################################################################

##############################################################################
# Module Definition
##############################################################################

use strict;
use warnings;
use SDP::Core;
use SDP::SUSE;

##############################################################################
# Overriden (eventually or in part) from SDP::Core Module
##############################################################################

@PATTERN_RESULTS = (
	PROPERTY_NAME_CLASS."=AZSAP",
	PROPERTY_NAME_CATEGORY."=Database",
	PROPERTY_NAME_COMPONENT."=Resource",
	PROPERTY_NAME_PATTERN_ID."=$PATTERN_ID",
	PROPERTY_NAME_PRIMARY_LINK."=META_LINK_TID",
	PROPERTY_NAME_OVERALL."=$GSTATUS",
	PROPERTY_NAME_OVERALL_INFO."=None",
	"META_LINK_TID=https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-pacemaker#cluster-installation"
);




##############################################################################
# Local Function Definitions
##############################################################################

sub checkCliBanConfiguration {
	SDP::Core::printDebug('> checkTotemConfiguration', 'BEGIN');
	my $RCODE = 0;
	my $FILE_OPEN = 'ha.txt';
	my $SECTION = 'crm configure show';
	my @CONTENT = ();
	my $CONSTRAINT_COUNT = 0;

	if ( SDP::Core::getSection($FILE_OPEN, $SECTION, \@CONTENT) ) {
		foreach $_ (@CONTENT) {
			next if ( m/^\s*$/ ); # Skip blank lines
			if ( /cli-ban/i ) {
			    SDP::Core::printDebug('cli-ban location constraint', "Found");
			    $CONSTRAINT_COUNT++;
			} elsif  ( /cli-prefer/i ) {
			    SDP::Core::printDebug('cli-prefer location constraint', "Found");
			    $CONSTRAINT_COUNT++;
			} 
		}
		if ( $CONSTRAINT_COUNT > 0 ) {
		    SDP::Core::updateStatus(STATUS_WARNING, "Found: cli-ban or cli-prefer location constraints");
		} else {
		    SDP::Core::updateStatus(STATUS_SUCCESS, "No cli-ban or cli-prefer location constraints found ")
		}
		
	} else {
		SDP::Core::updateStatus(STATUS_ERROR, "ERROR: checkTotemConfiguration(): Cannot find \"$SECTION\" section in $FILE_OPEN");
	}
	SDP::Core::printDebug("< checkCliBanConfiguration", "Returns: $RCODE");
	return $RCODE;
}

##############################################################################
# Main Program Execution
##############################################################################

SDP::Core::processOptions();
	checkCliBanConfiguration();
SDP::Core::printPatternResults();

exit;
