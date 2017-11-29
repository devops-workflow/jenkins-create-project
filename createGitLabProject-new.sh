#!/bin/bash
#
# Create a GitLab project
#
# TODO:
#   Add error checking on all gitlab commands
#   Create random Jenkins build token -> JJB job definition & GitLab project variable
#
set +x
projectType=$1
templateConfigPrefix='template_'
configGitlab="${templateConfigPrefix}gitlab_config.sh"
buildVariables='JENKINS_TOKEN:aBcDeFgHiJ'
. gitlabAPI.sh
#gitlabHost='gitlab.x.com'

###
### Source config files
###
cd templates
# Source global template config
if [ -f "global/${configGitlab}" ]; then
  source global/${configGitlab}
fi
# Source group and project templates config
for template in ${projectType//+/ }; do
  if [ -f "${template}/${configGitlab}" ]; then
    source ${template}/${configGitlab}
  fi
done
cd ..

###
### Check if project already exists
###
echo "INFO: Checking if project exists: ${group}/${gitProject} ..."
if [ $(gitlab_projects_list | jq -r .[].path_with_namespace | grep "^${group}/${gitProject}$" | wc -l) -gt 0 ]; then
  # Look into - Maybe request info on repo and check if success/fail instead
  echo "ERROR: Project exists: ${group}/${gitProject}"
  exit 1
fi
###
### Create GitLab Project
###
### Get Group ID
groupId=$(gitlab_group_id_get ${group} | jq .[].id)
### Create GitLab project
echo "INFO: Creating GitLab project '${gitProject}' in group '${group} (${groupId})' ..."
gitlab_project_create
# Add error handling if NO project ID
echo "New project's ID: ${projectId}"
# Remove service PivotalTracker
gitlab_service_delete ${projectId} pivotaltracker
# Create Environment/Build variables
if [ -n "${buildVariables}" ]; then
  for V in ${buildVariables}; do
    key=${V%%:*}
    value=${V##*:}
    gitLab_variable_set ${projectId} ${key} ${value}
  done
fi
exit
if [ -n "${jiraProjectId}" ]; then
  gitlab_service_jira ${projectId} ${jiraProjectId}
fi
if [ -n "${slackChannel}" ]; then
  gitlab_service_slack ${projectId} "${slackChannel}"
fi
exit
gitlab_service_wiki ${projectId}
runnerId=$(gitlab_runners_list )
gitlab_runner_enable ${projectId} ${runnerId}
# Need at least Master permission in namespace
# Returns: id & path
# Setup owner & user access. Needed or inherited is good enough
# Need at least owner
# If going with GitLab CI
# TODO: Check old projects and get all settings
#   Setup runners or make sure there are shared ones with matching tags
#   Enable/disable service integrations. Disable all not on desired list
#   Set all Slack settings (DO SOON)
#   Create required env variables: Jenkins Token,
#   Consider rewrite with v4 API and curl
#     Routine handle auth header, url, data
#   https://docs.gitlab.com/ce/api/
#   https://gitlab.com/gitlab-org/gitlab-ce/tree/master/lib/api
#   https://gitlab.com/gitlab-org/gitlab-ce/blob/master/lib/api/api.rb
#   https://gitlab.com/gitlab-org/gitlab-ce/issues/20070
#
# Fix: LFS disable,
# Hooks
#   hook list, get, create, delete
#   project-hook list, get, create, update, delete
# Notification settings
#   project-notification-settings get, update
#   https://docs.gitlab.com/ce/api/notification_settings.html
#   v3
#     GET /groups/:id/notification_settings
#     GET /projects/:id/notification_settings
#     PUT /groups/:id/notification_settings
#     PUT /projects/:id/notification_settings
# Project - Anything here can be done when built
#   project update
#   https://docs.gitlab.com/ce/api/projects.html
#   v3
#     GET /projects
#     GET /projects/all
#     GET /projects/:id
#     POST /projects
#     PUT /projects/:id
#     GET /projects/search/:query
# Runners - set ac87498a cs-java-1
#   runner list, get, update, delete
#  ? project_runners list, create, delete
#   https://docs.gitlab.com/ce/api/runners.html
#   v3
#     GET /runners
#     GET /runners/all
#     GET /runners/:id
#     GET /projects/:id/runners
#     POST /projects/:id/runners
#   v4
#     POST /projects/:id/runners
# Service - set Jira, Slack, Build EMails ?, Pipeline EMails ? - remove PivotalTracker
#   project-service get, update, delete
#   https://docs.gitlab.com/ce/api/services.html
#   v3
#     PUT /projects/:id/services/builds-email
#     PUT /projects/:id/services/jira
#     PUT /projects/:id/services/pipelines-email
#     DELETE /projects/:id/services/pivotaltracker
#     PUT /projects/:id/services/slack
#   v4
#     PUT /projects/:id/services/jobs-email
#     PUT /projects/:id/services/jira
#     PUT /projects/:id/services/pipelines-email
#     DELETE /projects/:id/services/pivotaltracker
#     PUT /projects/:id/services/slack
# Settings
#  ? settings get
# Triggers
#   project-trigger list, get, create, delete
# Variables - JENKINS_TOKEN
#   project-variable list, get, create, update, delete --project-id <ID>
#   project-variable create --project-id <ID> --key <key> --value <value>
#   https://docs.gitlab.com/ce/api/build_variables.html
#   v3
#  list   GET /projects/:id/variables
#     curl --header "PRIVATE-TOKEN: 9koXpgAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/variables"
#  get   GET /projects/:id/variables/:key
#  create   POST /projects/:id/variables
#     curl --request POST --header "PRIVATE-TOKEN: 9koXpgAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/variables" --form "key=NEW_VARIABLE" --form "value=new value"
#  update   PUT /projects/:id/variables/:key
#     curl --request PUT --header "PRIVATE-TOKEN: 9koXpgAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/variables/NEW_VARIABLE" --form "value=updated value"
#  delete   DELETE /projects/:id/variables/:key
# GitLab Version
#   https://docs.gitlab.com/ce/api/version.html
#   v3
#     GET /version
# Lint
#   https://docs.gitlab.com/ce/api/ci/lint.html
#   v3
#     POST ci/lint
# Testing
#   can also use github.com EE Current version
# Cleanup

exit
