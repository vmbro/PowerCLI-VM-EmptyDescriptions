from jira import JIRA
import sys

location = sys.argv[1]
vmNames = sys.argv[2]
jiraProjectKey = sys.argv[3]
jiraUsername = sys.argv[4]
jiraToken = sys.argv[5]
jiraURL = sys.argv[6]

issueTitle = location + " | Virtual Machines with empty notes"
issueDescription = "*Virtual machines does not have any note/description.*\n"
issueAction = "Please fill the VM Notes section."
description = issueDescription + "\n{code:java}" + vmNames + "{code}\n"

jira_connection = JIRA(basic_auth=(jiraUsername, jiraToken), options={'server': jiraURL})

issue_dict = {
    'project': {'key': jiraProjectKey},
    'summary': issueTitle,
    'description': description,
    'priority':{'name': 'Lowest'},
    'issuetype': {'name': 'Task'},
}

jira_connection.create_issue(fields=issue_dict)
