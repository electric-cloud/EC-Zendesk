# Data that drives the create step picker registration for this plugin.
my %commentOnTicket = ( 
  label       => "EC-Zendesk - commentOnTicket", 
  procedure   => "commentOnTicket", 
  description => "Comment on an existing  Zendesk Ticket", 
  category    => "Administration" 
);

my %createTicket = ( 
  label       => "EC-Zendesk - createTicket", 
  procedure   => "createTicket", 
  description => "Create a Zendesk Ticket", 
  category    => "Administration" 
);

@::createStepPickerSteps = (\%commentOnTicket, \%createTicket);
