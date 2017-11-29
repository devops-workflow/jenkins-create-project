#!/bin/bash
#
# Create a GitLab project
#
# TODO:
#   Add error checking on all gitlab commands
#   Create random Jenkins build token -> JJB job definition & GitLab project variable
#
set +x
gitlabConfig='gitlab.ini'
gitlabHost='gitlab.org.com'
exit

###
### Create gitlab config file
###
cat <<CONFIG >${gitlabConfig}
[global]
default = org
ssl_verify = false
timeout = 5
[org]
url = https://${gitlabHost}/
private_token = ${gitlab_token}
CONFIG
### Info
#if [ ${projectOwner} = "UseBuildUser" ]; then
#  projectOwner=${BUILD_USER_ID}
#fi
#echo "INFO: Git project owner (NOT USED): ${projectOwner}"
###
### Check if project already exists
###
echo "INFO: Checking if project exists: ${group}/${gitProject} ..."
#gitlab -c gitlab.ini -v project list --all | grep ^path-with-namespace: | sort
if [ $(gitlab -c ${gitlabConfig} -v project list --all | grep ^path-with-namespace: | grep "${group}/${gitProject}$" | wc -l) -gt 0 ]; then
  # Look into - Maybe request info on repo and check if success/fail instead
  echo "ERROR: Project exists: ${group}/${gitProject}"
  exit 1
fi
###
### Create GitLab Project
###
### Get Group ID
groupId=$(gitlab -c ${gitlabConfig} group get --id ${group} 2>/dev/null | grep ^id: | cut -d\  -f2)
### Create GitLab project
echo "INFO: Creating GitLab project '${gitProject}' in group '${group} (${groupId})' ..."
cmd="gitlab -c ${gitlabConfig} project create \
  --namespace-id ${groupId} \
  --name ${gitProject} \
  --visibility-level 10 \
  --description \"${description}\" \
  --builds-enabled true"
echo "DEBUG: cmd: ${cmd}"
# Quoting issue
#projectId=$(${cmd})
projectId=$(gitlab -c ${gitlabConfig} project create \
  --namespace-id ${groupId} \
  --name ${gitProject} \
  --visibility-level 10 \
  --description "${description}" \
  --builds-enabled true )
#  --sudo ${{projectOwner}} # not tested yet. Requires Admin)
# Add error handling if NO project ID
echo "New project's ID: ${projectId}"
# Returns: id: <id>\npath: <path>
#   maybe parse and disply nicely. None fr both if failed
# Need at least Master permission in namespace
# Returns: id & path
# Setup owner & user access. Needed or inherited is good enough
# Need at least owner
# If going with GitLab CI
# TODO: Check old projects and get all settings
#   Setup runners or make sure there are shared ones with matching tags
#   Enable/disable service integrations. Disable all not on desired list
#   Set all Slack settings (DO SOON)
#   Create required env variables: Quay, Jenkins Token,
#   Consider rewrite with v4 API and curl
#     Routine handle auth header, url, data
#   https://docs.gitlab.com/ce/api/
#   https://gitlab.com/gitlab-org/gitlab-ce/tree/master/lib/api
#   https://gitlab.com/gitlab-org/gitlab-ce/blob/master/lib/api/api.rb
#   https://gitlab.com/gitlab-org/gitlab-ce/issues/20070
#
curl -k --header "PRIVATE-TOKEN: ${gitlab_token}" --request POST \
     --data "name=${gitProject}" \
     --data "description=${description}" \
     --data "namespace_id=${groupId}" \
     --data 'builds_enabled=true' \
     --data 'issues_enabled=false' \
     --data 'jobs_enabled=true' \
     --data 'lfs_enabled=false' \
     --data 'merge_requests_enabled=true' \
     --data 'public_jobs=false' \
     --data 'request_access_enabled=true' \
     --data 'snippets_enabled=true' \
     --data 'shared_runners_enabled=true' \
     --data 'visibility=internal' \
     --data 'wiki_enabled=true' \
     --data 'only_allow_merge_if_pipeline_succeeds=true' \
     --data 'only_allow_merge_if_all_discussions_are_resolved=true' \
     "https://${gitlabHost}/api/v4/projects"
# | jq
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
# Variables - JENKINS_TOKEN, QUAY_TOKEN, QUAY_USER
#   project-variable list, get, create, update, delete --project-id <ID>
#   project-variable create --project-id <ID> --key <key> --value <value>
#   https://docs.gitlab.com/ce/api/build_variables.html
#   v3
#  list   GET /projects/:id/variables
#     curl --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/variables"
#  get   GET /projects/:id/variables/:key
#  create   POST /projects/:id/variables
#     curl --request POST --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/variables" --form "key=NEW_VARIABLE" --form "value=new value"
#  update   PUT /projects/:id/variables/:key
#     curl --request PUT --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" "https://gitlab.example.com/api/v3/projects/1/variables/NEW_VARIABLE" --form "value=updated value"
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
rm -f ${gitlabConfig}

exit

gitlabUrl="https://${gitlabHost}"
gitlabUrlApi="${gitlabUrl}/api/v4"
gitlabAuthHeader="--header 'PRIVATE-TOKEN: ${gitlab_token}'"
gitlab_curl () {
  requestType=$1
  shift
  data="$*"
  #if [ ${requestType} != 'GET' ]; then
    headerRequest="--request ${requestType}"
  #fi
  curl -k ${gitlabAuthHeader} ${headerRequest} ${data}
}
gitlab_group_id_get () {
  gitlab_groups_search ${name}
}
gitlab_group_list () {
  # List projects in a group
  groupId=$1
  gitlab_curl GET /groups/:${groupId}/projects
}
gitlab_groups_list () {
  # List groups
  gitlab_curl GET /groups
  #/namespaces
}
gitlab_groups_search () {
  groupName=$1
  gitlab_curl GET /groups?search=${groupName}
  #/namespaces?search=foobar
}
gitlab_project_create () {
  # Params: urlApi, token, name, namespace, description
  json=$(gitlab_curl POST \
    --data "name=${gitProject}" \
    --data "description=${description}" \
    --data "namespace_id=${groupId}" \
    --data 'builds_enabled=true' \
    --data 'issues_enabled=false' \
    --data 'jobs_enabled=true' \
    --data 'lfs_enabled=false' \
    --data 'merge_requests_enabled=true' \
    --data 'public_jobs=false' \
    --data 'request_access_enabled=true' \
    --data 'snippets_enabled=true' \
    --data 'shared_runners_enabled=true' \
    --data 'visibility=internal' \
    --data 'wiki_enabled=true' \
    --data 'only_allow_merge_if_pipeline_succeeds=true' \
    --data 'only_allow_merge_if_all_discussions_are_resolved=true' \
    "${gitlabUrlApi}/projects")
  if [ ${verbose} == 'True' ]; then
    echo "${json}" | jq .
  fi
  projectId=$(echo "${json}" | jq .id)
}
gitlab_projects_list () {
  gitlab_curl GET /projects
}
#gitlab_header () {}
gitlab_notification_ () {
  # new_merge_request, reopen_merge_request, merge_merge_request, failed_pipeline, success_pipeline
  # https://docs.gitlab.com/ce/api/notification_settings.html
  projectId=$1
  gitlab_curl PUT /projects/:${projectId}/notification_settings
  #?failed_pipeline=true&success_pipeline=true& ...
}
gitlab_runner_enable () {
  # https://docs.gitlab.com/ce/api/runners.html#enable-a-runner-in-project
  projectId=$1
  runnerId=$2
  gitlab_curl POST /projects/:${projectId}/runners --form "runner_id=${runnerId}"
}
#gitlab_runner_id_get () {}
gitlab_runners_list () {
  gitlab_curl GET /runners/all
}
#gitlab_service_email_jobs () {}
gitlab_service_email_pipeline () {
  # https://docs.gitlab.com/ce/api/services.html#pipeline-emails
  projectId=$1
  gitlab_curl PUT /projects/:${projectId}/services/pipelines-email
  # recipients, add_pusher, notify_only_broken_pipelines
}
gitlab_service_jira () {
  # https://docs.gitlab.com/ce/api/services.html#jira
  projectId=$1
  jiraProject=$2
  jiraURL='https://jira.org.com/api/v2/jira'
  jiraUser='gitlab'
  jiraPaswd='git2jiaSOMEpassword'
  jiraTrans='51'
  gitlab_curl PUT /projects/:${projectId}/services/jira?url=${jiraURL}&project_key=${jiraProject}&username=${jiraUser}&password=${jiraPaswd}&jira_issue_transition_id=${jiraTrans}
}
gitlab_service_slack () {
  # https://docs.gitlab.com/ce/api/services.html#slack-notifications
  projectId=$1
  slackURL='https://hooks.slack.com/services/' # has 2 more parts. get from slack
  slackUser=
  slackChannel='#ci' # Which channel??
  gitlab_curl PUT /projects/:${projectId}/services/slack?webhook=${slackURL}&username=${slackUser}&channel=${slackChannel}
}
gitlab_service_wiki () {
  # Link to external wiki
  # https://docs.gitlab.com/ce/api/services.html#external-wiki
  projectId=$1
  wikiURL=
  gitlab_curl PUT /projects/:${projectId}/services/external-wiki?external_wiki_url=${wikiURL}
}
gitlab_service_delete () {
  projectId=$1
  service=$2
  gitlab_curl DELETE /projects/:${projectId}/services/${service}
}
gitLab_variable_set () {
  # Params: key, value
  # https://docs.gitlab.com/ce/api/build_variables.html
  projectId=$1
  key=$2
  value=$3
  gitlab_curl POST /projects/:${projectId}/variables --form "key=${key}" --form "value=${value}"
}

# Remove service PivotalTracker
gitlab_service_delete ${projectId} pivotaltracker
