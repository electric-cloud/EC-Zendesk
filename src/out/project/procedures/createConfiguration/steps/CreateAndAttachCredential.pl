##########################
# createAndAttachCredential.pl
##########################

use ElectricCommander;

use constant {
    SUCCESS => 0,
    ERROR   => 1,
};

my $ec = new ElectricCommander();
$ec->abortOnError(0);

my $credName = getP("/myJob/config");
my $xpath = $ec->getFullCredential("credential");
my $userName = $xpath->findvalue("//userName");
my $password = $xpath->findvalue("//password");

# Create credential
my $projName = "EC-Zendesk-1.0.0.72";

$ec->deleteCredential($projName, $credName);
$xpath = $ec->createCredential($projName, $credName, $userName, $password);
my $errors = $ec->checkAllErrors($xpath);

# Give config the credential's real name
my $configPath = "/projects/$projName/plugins_cfgs/$credName";
$xpath = $ec->setProperty($configPath . "/credential", $credName);
$errors .= $ec->checkAllErrors($xpath);

# Give job launcher full permissions on the credential
my $user = getP("/myJob/launchedByUser");
$xpath = $ec->createAclEntry("user", $user,
    {projectName => $projName,
     credentialName => $credName,
     readPrivilege => allow,
     modifyPrivilege => allow,
     executePrivilege => allow,
     changePermissionsPrivilege => allow});
$errors .= $ec->checkAllErrors($xpath);

## Attach credential to steps that will need it
    $xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'PROC',
     stepName => 'STEP'});
    $errors .= $ec->checkAllErrors($xpath);


#if errors
    if ("$errors" ne "") {
        # Cleanup the partially created configuration we just created
        $ec->deleteProperty($configPath);
        $ec->deleteCredential($projName, $credName);
        my $errMsg = 'Error creating configuration credential: ' . $errors;
        $ec->setProperty("/myJob/configError", $errMsg);
        print $errMsg;
        exit ERROR;
    }

#############################################################################
#
# Compare 2 version number strings like x.y.z... section by section
# return 1 if V1 > v2
# return 0 if v1 == v2
# return -1 if v1 < v2
#
#############################################################################
sub compareVersion {

  my ($v1, $v2)=@_;
  
  my @v1Numbers = split('\.', $v1);
  my @v2Numbers = split('\.', $v2);

  for (my $index = 0; $index < scalar(@v1Numbers); $index++) {
    
    # We ran out of V2 numbers => V1 is a bigger version
    return 1 if (scalar(@v2Numbers) == $index);

    # same value, go to next number
    next if ($v1Numbers[$index] == $v2Numbers[$index]);
        
    # V1 is a bigger version
    return 1 if ($v1Numbers[$index] > $v2Numbers[$index]);
           ;
    # V2 is a bigger version
    return -1;
  }

  # We ran out of V1 numbers
  return -1 if(scalar(@v1Numbers) != scalar(@v2Numbers));

  # Same number
  return 0;
};

#############################################################################
#
# Return property value or undef in case of error (non existing)
#
#############################################################################
sub getP
{
  my $prop=shift;

  my($success, $xPath, $errMsg, $errCode)= InvokeCommander("SuppressLog IgnoreError", "getProperty", $prop);
  return undef if ($success != 1);
  my $val= $xPath->findvalue("//value");
  return($val);
}

;

#############################################################################
#
# Return human readable size
#
#############################################################################
sub humanSize {
  my $size = shift();

  if ($size > 1099511627776) { # TB: 1024 GB
      return sprintf("%.2f TB", $size / 1099511627776);
  }
  if ($size > 1073741824) { # GB: 1024 MB
      return sprintf("%.2f GB", $size / 1073741824);
  }
  if ($size > 1048576) { # MB: 1024 KB
      return sprintf("%.2f MB", $size / 1048576);
  }
  elsif ($size > 1024) { # KiB: 1024 B
      return sprintf("%.2f KB", $size / 1024);
  }
                                  # bytes
  return "$size byte" . ($size <= 1 ? "" : "s");
};
;

#############################################################################
#
# Invoke a API call
#
#############################################################################
sub InvokeCommander {

    my $optionFlags = shift;
    my $commanderFunction = shift;
    my $xPath;
    my $success = 1;

    my $bSuppressLog = $optionFlags =~ /SuppressLog/i;
    my $bSuppressResult = $bSuppressLog || $optionFlags =~ /SuppressResult/i;
    my $bIgnoreError = $optionFlags =~ /IgnoreError/i;

    # Run the command
    # print "Request to Commander: $commanderFunction\n" unless ($bSuppressLog);

    $ec->abortOnError(0) if $bIgnoreError;
    $xPath = $ec->$commanderFunction(@_);
    $ec->abortOnError(1) if $bIgnoreError;

    # Check for error return
    my $errMsg = $ec->checkAllErrors($xPath);
    my $errCode=$xPath->findvalue('//code',)->value();
    if ($errMsg ne "") {
        $success = 0;
    }
    if ($xPath) {
        print "Return data from Commander:\n" .
               $xPath->findnodes_as_string("/") . "\n"
            unless $bSuppressResult;
    }

    # Return the result
    return ($success, $xPath, $errMsg, $errCode);
}


#############################################################################
#
# Return a hash of the properties contained in a Property Sheet.
# Args:
#    1. Property Sheet path
#    2. Recursive boolean
#############################################################################
sub getPS
{
  my $psPath=shift;
  my $recursive=shift;
  
  my $hashRef=undef;
  
  my($success, $result, $errMsg, $errCode)=InvokeCommander("SuppressLog IgnoreError", "getProperties", {'path'=>$psPath});
  return $hashRef if (!$success);
  
 
  foreach my $node ($result->findnodes('//property')) {
    my $propName=$node->findvalue('propertyName');
    my $value   =$node->findvalue('value')->string_value();
    my $psId    =$node->findvalue('propertySheetId');
    
    # this is not a nested PS    
    if ($psId eq '') {
      $hashRef->{$propName}=$value;
      printf("%s: %s\n", $propName, $value);
    } else {
      # nested PropertySheet
      if ($recursive) {
        $hashRef->{$propName}=getPS("$psPath/$propName", $recursive);
      } else {
        $hashRef->{$propName}=undef;
      }  
    }
  }
  return $hashRef;
}

