
gitlabHost='gitlab.org.com'
gitlabUrl="https://${gitlabHost}"
gitlabUrlApi="${gitlabUrl}/api/v4"
gitlab_curl () {
  local requestType=$1
  shift
  data="$*"
  #if [ ${requestType} != 'GET' ]; then
    headerRequest="--request ${requestType}"
  #fi
  curl -k --header "PRIVATE-TOKEN: ${gitlab_token}" ${headerRequest} ${data}
}
gitlab_group_id_get () {
  local groupName=$1
  gitlab_groups_search ${groupName}
}
gitlab_group_list () {
  # List projects in a group
  local groupId=$1
  gitlab_curl GET ${gitlabUrlApi}/groups/:${groupId}/projects
}
gitlab_groups_list () {
  # List groups
  gitlab_curl GET ${gitlabUrlApi}/groups
  #/namespaces
}
gitlab_groups_search () {
  local groupName=$1
  gitlab_curl GET ${gitlabUrlApi}/groups?search=${groupName}
  #/namespaces?search=foobar
}
gitlab_project_create () {
  # Params: urlApi, name, namespace, description
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
  if [ "${verbose}" == 'True' ]; then
    echo "${json}" | jq .
  fi
  projectId=$(echo "${json}" | jq .id)
}
gitlab_projects_list () {
  gitlab_curl GET ${gitlabUrlApi}/projects
}
#gitlab_header () {}
gitlab_notification_ () {
  # new_merge_request, reopen_merge_request, merge_merge_request, failed_pipeline, success_pipeline
  # https://docs.gitlab.com/ce/api/notification_settings.html
  local projectId=$1
  gitlab_curl PUT ${gitlabUrlApi}/projects/:${projectId}/notification_settings
  #?failed_pipeline=true&success_pipeline=true& ...
}
gitlab_runner_enable () {
  # https://docs.gitlab.com/ce/api/runners.html#enable-a-runner-in-project
  local projectId=$1
  local runnerId=$2
  gitlab_curl POST ${gitlabUrlApi}/projects/:${projectId}/runners --form "runner_id=${runnerId}"
}
#gitlab_runner_id_get () {}
gitlab_runners_list () {
  gitlab_curl GET ${gitlabUrlApi}/runners/all
}
#gitlab_service_email_jobs () {}
gitlab_service_email_pipeline () {
  # https://docs.gitlab.com/ce/api/services.html#pipeline-emails
  local projectId=$1
  gitlab_curl PUT ${gitlabUrlApi}/projects/:${projectId}/services/pipelines-email
  # recipients, add_pusher, notify_only_broken_pipelines
}
gitlab_service_jira () {
  # https://docs.gitlab.com/ce/api/services.html#jira
  local projectId=$1
  local jiraProject=$2
  jiraURL='https://jira.org.com/api/v2/jira'
  jiraUser='gitlab'
  jiraPaswd='git2jiaSOMEpassword'
  jiraTrans='51'
  gitlab_curl PUT ${gitlabUrlApi}/projects/:${projectId}/services/jira?url=${jiraURL}&project_key=${jiraProject}&username=${jiraUser}&password=${jiraPaswd}&jira_issue_transition_id=${jiraTrans}
}
gitlab_service_slack () {
  # https://docs.gitlab.com/ce/api/services.html#slack-notifications
  local projectId=$1
  local slackChannel=$2 #'#csb-deploy-nonprod' # Which channel??
  slackURL='https://hooks.slack.com/services/' # has 2 more parts. get from slack
  slackUser=
  gitlab_curl PUT ${gitlabUrlApi}/projects/:${projectId}/services/slack?webhook=${slackURL}&username=${slackUser}&channel=${slackChannel}
}
gitlab_service_wiki () {
  # Link to external wiki
  # https://docs.gitlab.com/ce/api/services.html#external-wiki
  local projectId=$1
  wikiURL=
  gitlab_curl PUT ${gitlabUrlApi}/projects/:${projectId}/services/external-wiki?external_wiki_url=${wikiURL}
}
gitlab_service_delete () {
  local projectId=$1
  local service=$2
  gitlab_curl DELETE ${gitlabUrlApi}/projects/:${projectId}/services/${service}
}
gitLab_variable_set () {
  # Params: key, value
  # https://docs.gitlab.com/ce/api/build_variables.html
  local projectId=$1
  local key=$2
  local value=$3
  gitlab_curl POST ${gitlabUrlApi}/projects/:${projectId}/variables --form "key=${key}" --form "value=${value}"
}
