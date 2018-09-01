#############################################################################
#
# Copyright Electric-Cloud 2015-2018
#
#	Reuse existing ticket instead of creating a new one for each call
#############################################################################
$[/plugins[EC-Admin]project/scripts/perlHeaderJSON]

my $ticketId=120851;

$ec->setProperty("/myJob/zendesk/ticketId", $ticketId);
$ec->setProperty("summary", "Zendesk ticket created: $ticketId");
