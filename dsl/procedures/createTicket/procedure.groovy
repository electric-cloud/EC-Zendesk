/* ###########################################################################
# Main procedure to run Liquibase commands
#
# Author: L.Rochette
#
# Copyright 2018 Electric Cloud, Inc.
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
# History
# ---------------------------------------------------------------------------
# 2018-Aug-17 lrochette Conversion to PluginWizard
#
############################################################################ */
import java.io.File

def procName = 'createTicket'
procedure procName,
  description: 'Create a Zendesk Ticket',
{
  step 'checkConfiguration',
    description: 'Verify the configuration exists',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/checkConfiguration.pl").text,
    shell: 'ec-perl',
    errorHandling: 'abortJob'

  step 'createTicket',
    command: new File(pluginDir, "dsl/procedures/$procName/steps/createTicket.pl").text,
    shell: 'ec-perl',
    condition: '''$[/javascript (typeof(getProperty("/server/EC-Zendesk/testServer")) == "undefined") || (server['EC-Zendesk'].testServer == "0") ]'''

/*  step 'createTicket-debug',
      command: new File(pluginDir, "dsl/procedures/$procName/steps/createTicket-debug.pl").text,
      shell: 'ec-perl',
      condition: '''$[/javascript (typeof(getProperty("/server/EC-Zendesk/testServer")) != "undefined") && (server['EC-Zendesk'].testServer != "0") ]'''
*/
}
