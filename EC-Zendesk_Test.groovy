
project 'EC-Zendesk_Test', {
  description = 'Easier testing of plugin'
  resourceName = null
  workspaceName = null

  procedure 'createTicket', {
    description = ''
    jobNameTemplate = ''
    resourceName = ''
    timeLimit = ''
    timeLimitUnits = 'minutes'
    workspaceName = ''

    step 'createTicket', {
      description = ''
      alwaysRun = '0'
      broadcast = '0'
      command = null
      condition = ''
      errorHandling = 'failProcedure'
      exclusiveMode = 'none'
      logFileName = null
      parallel = '0'
      postProcessor = null
      precondition = ''
      releaseMode = 'none'
      resourceName = ''
      shell = null
      subprocedure = 'createTicket'
      subproject = '/plugins/EC-Zendesk/project'
      timeLimit = ''
      timeLimitUnits = 'minutes'
      workingDirectory = null
      workspaceName = ''
      actualParameter '''configuration''', '''zendesk'''
      actualParameter '''problemScope''', '''7_some_sites'''
      actualParameter '''problemType''', '''4_tool_limiting'''
      actualParameter '''product''', '''electricflow'''
      actualParameter '''ticketDescription''', '''this is a test - Ignore'''
      actualParameter '''ticketSubject''', '''Test'''
      actualParameter '''version''', '''8.5'''
    }
  }
}
