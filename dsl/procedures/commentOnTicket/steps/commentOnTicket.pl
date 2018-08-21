#############################################################################
#
# Copyright Electric-Cloud 2015
#
#############################################################################
$[/plugins[EC-Admin]project/scripts/perlHeaderJSON]

use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;
use MIME::Base64;

#############################################################################
#
# Parameters
#
#############################################################################
my $creds = "$[credential]";
my $comment = "$[comment]";
my $URL   = "$[/myProject/zendeskURL]/tickets/$[ticketNumber].json";

#############################################################################
#
# Global Variables
#
#############################################################################
my $DEBUG=0;

# Retrieve login and password from the credential
my $username= $ec->getFullCredential($creds, {value => "password"})->{responses}->[0]->{credential}->{userName}; 
my $password= $ec->getFullCredential($creds, {value => "userName"})->{responses}->[0]->{credential}->{password};

# Package the data in a data structure matching the expected JSON
my %data =(
	ticket => {
        comment => {
			public => "true",
        	body => "$comment"
        },
    },
);

# Encode the data structure to JSON
my $data = encode_json(\%data);

#
# Create request
#
# Note: the current version of the LWP::UserAGent package does not support the put method
#       therefore we have to use the POST metod from the HTTP::Request::Common package
#       However this package seems to have issue with put request containing data so the trick
#       is to create a POST request with the data and then change it to PUT

#my $req = PUT $URL, Content => $data; #;
my $req = POST($URL, 'Content-Type' => 'application/json', 'Content' => $data);
printf("Req: %s\n", $req->as_string);

$req->authorization_basic($username, $password);
$req->method('PUT');

# Create a user agent and make the request
my $ua = LWP::UserAgent->new(ssl_opts =>{ verify_hostname => 0 });

my $response = $ua->request($req);

# Check for HTTP error codes
die 'http status: ' . $response->code . '  ' . $response->message
    unless ($response->is_success);

# Decode the JSON into a Perl data structure
my $response = decode_json($response->content);
print Dumper($response);


