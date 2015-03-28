#############################################################################
#
# Copyright Electric-Cloud 2015
#
#############################################################################
$[/plugins[EC-Admin]project/scripts/perlHeaderJSON]

use LWP::UserAgent;
use JSON;
use MIME::Base64;

#############################################################################
#
# Parameters
#
#############################################################################
my $creds = "zendesk";
my $title = "$[ticketSubject]";
my $body  = "$[ticketDescription]";
my $URL   = "$[zendeskURL]/tickets.json";
my $product="$[product]";

#############################################################################
#
# Global Variables
#
#############################################################################
# my $DEBUG=1;


# Retrieve login and password from the credential
my $username= $ec->getFullCredential($creds, {value => "password"})->{responses}->[0]->{credential}->{userName}; 
my $password= $ec->getFullCredential($creds, {value => "userName"})->{responses}->[0]->{credential}->{password};

# Package the data in a data structure matching the expected JSON
my %data =(
	ticket => {
		subject => $title,
        comment => {
        	body => $body
        },
        custom_fields => [
                    {'id' => 108886, 'value' => $product},		# Product custome field
                    {"id" => 112789, 'value' => "email"}		# Issue initiation
                  ],
    },
);

# Encode the data structure to JSON
my $data = encode_json(\%data);

#
# Create request
#
my $credentials = encode_base64("$username:$password");

# Create a user agent and make the request
my $ua = LWP::UserAgent->new(ssl_opts =>{ verify_hostname => 0 });
my $response = $ua->post($URL, 
						 'Content' => $data,
                         'Content-Type' => 'application/json',
                         'Authorization' => "Basic $credentials");

# Check for HTTP error codes
die 'http status: ' . $response->code . '  ' . $response->message
    unless ($response->is_success);

# Decode the JSON into a Perl data structure
my $response = decode_json($response->content);
print Dumper($response);
my $ticketId=$response->{audit}->{ticket_id};
$ec->setProperty("/myJob/zendesk/ticketId", $ticketId);
$ec->setProperty("summary", "Zendesk ticket created: $ticketId");


