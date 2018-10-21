#############################################################################
#
# Copyright Electric-Cloud 2015-2018
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Changelog:
#----------------------------------------------------------------------------
# 2018-09-27  lrochette   change initiation of the ticket to "scripted"
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
my $creds   = "$[configuration]";
my $title   = "$[ticketSubject]";
my $body    = getP("ticketDescription");
my $URL     = getP("/myProject/zendeskURL");
my $product = "$[product]";
my $version = "$[version]";
my $pbScope = "$[problemScope]";
my $pbType  = "$[problemType]";

#############################################################################
#
# Global Variables
#
#############################################################################
my $DEBUG=1;

# Retrieve login and password from the credential
my $username= $ec->getFullCredential($creds, {value => "password"})->{responses}->[0]->{credential}->{userName};
my $password= $ec->getFullCredential($creds, {value => "userName"})->{responses}->[0]->{credential}->{password};

chomp($URL);

# Package the data in a data structure matching the expected JSON
my %data =(
	request => {
		subject => $title,
        comment => {
        	body => "Ticket created by $[/myParent/projectName]\n\n$body"
        },
        custom_fields => [
          {'id' => 108886,   'value' => $product},		# Product custome field
          {"id" => 112789,   'value' => "scripted"},	# Issue initiation
          {"id" => 109953,   'value' => $version},		# product version
          {"id" => 24209853, 'value' => $pbType},		  # problem type
          {"id" => 24250276, 'value' => $pbScope},	  # problem scope
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
my $response = $ua->post("$URL/requests.json",
						 'Content' => $data,
                         'Content-Type' => 'application/json',
                         'Authorization' => "Basic $credentials");
#printf("Request: %s\n", "$URL/tickets.json");
#printf("Data: %s\n", $data);
#print Dumper($ua);

#printf("\nResponse:");
#print Dumper($response);

# Check for HTTP error codes
die 'http status: ' . $response->code . '  ' . $response->message
    unless ($response->is_success);


# Decode the JSON into a Perl data structure
my $response = decode_json($response->content);
print Dumper($response);
#my $ticketId=$response->{audit}->{ticket_id};
my $ticketId=$response->{request}->{id};
$ec->setProperty("/myJob/zendesk/ticketId", $ticketId);
$ec->setProperty("summary", "Zendesk ticket created: $ticketId");

$[/plugins[EC-Admin]project/scripts/perlLibJSON]
