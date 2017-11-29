#!/bin/bash
#
# Create a customized repository stub for a project and upload it
#
# TODO: Add error checking for all external calls: git

gitlabHost='gitlab.org.com'
gitlabURL="https://${gitlabHost}"
jenkinsURL='https://jenkins.org.com'
templateConfigPrefix='template_'
templateDescriptionFile="${templateConfigPrefix}description.txt"
# Rest of these will move into template scripts
dirInfrastructure='infrastructure'
dirEcs="${dirInfrastructure}/ecs"
dirTerraform="${dirInfrastructure}/terraform"
ecsJSONScript="${dirEcs}/task_definition_template.json.sh"
readme='README.md'
readmeECS="${dirEcs}/README.md"
readmeTerraform="${dirTerraform}/README.md"

projectType=$1

###
### Create stub repository
###
# Currently 3 layer template: Global, Project, zip archive
# TODO: make 4 layer: Global, Group, Project, zip archive
# How to figure out which Group template?
#   naming: global, group, group+project, [group+[group+...]+]project
# ADD: process custom script from each template
#     Run all after or as each template is copied?
#     All customization stuff move into template scripts
mkdir -p repo
###
### Copy Templates
###
cd templates
# Copy global template
cp -ap global/. ../repo
# Copy group and project templates
for template in ${projectType//+/ }; do
  cp -ap ${template}/. ../repo
done
cd ..

###
### Add contents of uploaded file
###
if [ -f uploadedZipFile ]; then
  unzip -q uploadedZipFile
  cp -ap $(basename -s .zip "${uploadedZipFile}")/. repo
elif [ -f springZip ]; then
  unzip -q springZip
  cp -ap $(basename -s .zip "${springZip}")/. repo
else
  echo "WARNING: No uploaded zip stub file found"
fi

###
### Customize files
###
cd repo
# Cleanup
rm -f ${templateConfigPrefix}*
##
## README Files
##
# TODO: Add build badge and any other badges that exist
#   Add links to interesting parts of workflow
# GitLab CI Badges:
#   [![build status](https://gitlab.org.com/infrastructure/csb-qa-secrets/badges/master/build.svg)](https://gitlab.org.com/infrastructure/csb-qa-secrets/commits/master)
#   [![coverage report](https://gitlab.org.com/infrastructure/csb-qa-secrets/badges/master/coverage.svg)](https://gitlab.org.com/infrastructure/csb-qa-secrets/commits/master)
# gitlabURL='https://gitlab.eng.org.com'
# gitlabRepoURI="${group}/${gitProject}"
# gitlabBadgeURI="${gitlabRepoURI}/badges/master"
# gitlabBranchURI="${gitlabRepoURI}/commits/master"
#   [![GitLab build status](${gitlabURL}/${gitlabBadgeURI}/build.svg)](${gitlabURL}/${gitlabBranchURI})
#   [![GitLab coverage report](${gitlabURL}/${gitlabBadgeURI}/coverage.svg)](${gitlabURL}/${gitlabBranchURI})
# Jenkins Badges:
#   https://wiki.jenkins-ci.org/display/JENKINS/Embeddable+Build+Status+Plugin
#   https://github.com/yannickcr/jenkins-status-badges-plugin
#   https://shields.io/
# Need to use protected links. Use short w/o view link for image with view url for link
#   Markdown (without view)
#   protected
#   [![Build Status](https://jenkins2.eng.cs.org.com/job/EVENT+active-content-service+QA+Deploy+ECS+Deployment/6//badge/icon)](https://jenkins2.eng.cs.org.com/job/EVENT+active-content-service+QA+Deploy+ECS+Deployment/6/)
#   unprotected
#   [![Build Status](https://jenkins2.eng.cs.org.com/buildStatus/icon?job=EVENT+active-content-service+QA+Deploy+ECS+Deployment&build=6)](https://jenkins2.eng.cs.org.com/job/EVENT+active-content-service+QA+Deploy+ECS+Deployment/6/)
# Direct URL:
#   ${jenkinsURL}/job/${group^^}+${gitProject}+QA+Deploy+ECS+Deployment/badge/icon
#   ${jenkinsURL}/job/${group^^}+${gitProject}+QA+Deploy+Terraform+Plan/badge/icon?style=plastic
#
# Do not overwrite any README.md provided by zip file
if [ ! -s "${readme}" ]; then
  cat <<README >${readme}
# ${group}/${gitProject}

${description}

[![Gitlab Build Status](${gitlabURL}/${group}/${gitProject}/badges/master/build.svg)](${gitlabURL}/${group}/${gitProject}/commits/master)

[Jenkins Project View](${jenkinsURL}/view/Projects/view/${group^^}/${gitProject})

[Jenkins Project Environments View](${jenkinsURL}/view/Projects/view/${group^^}/${gitProject}/view/By%20Environment/)

[Jenkins Project Workflow Views](${jenkinsURL}/view/Projects/view/${group^^}/${gitProject}/view/Workflows/)

[AWS ECS Deployment README](${dirEcs}/README.md)

[Terraform Deployment README](${dirTerraform}/README.md)

README
fi
if [ ! -s "${readmeECS}" ]; then
  cat <<README >${readmeECS}
# AWS ECS container deployment jobs

[![ECS QA Deploy Status](${jenkinsURL}/job/${group^^}+${gitProject}+QA+Deploy+ECS+Deployment/badge/icon)](${jenkinsURL}/view/Projects/view/${group^^}/view/${gitProject}/view/By%20Environment/job/${group^^}+${gitProject}+QA+Deploy+ECS+Deployment/)

[![ECS Staging Deploy Status](${jenkinsURL}/job/${group^^}+${gitProject}+Staging+Deploy+ECS+Deployment/badge/icon)](${jenkinsURL}/view/Projects/view/${group^^}/view/${gitProject}/view/By%20Environment/job/${group^^}+${gitProject}+Staging+Deploy+ECS+Deployment/)

[![ECS Prod Deploy Status](${jenkinsURL}/job/${group^^}+${gitProject}+Prod+Deploy+ECS+Deployment/badge/icon)](${jenkinsURL}/view/Projects/view/${group^^}/view/${gitProject}/view/By%20Environment/job/${group^^}+${gitProject}+Prod+Deploy+ECS+Deployment/)

README
fi
if [ ! -s "${readmeTerraform}" ]; then
  cat <<README >${readmeTerraform}
# Terraform environment build/maintenance jobs

[![Terraform QA Plan](${jenkinsURL}/job/${group^^}+${gitProject}+QA+Deploy+Terraform+Plan/badge/icon)](${jenkinsURL}/view/Projects/view/${group^^}/view/${gitProject}/view/By%20Environment/job/${group^^}+${gitProject}+QA+Deploy+Terraform+Apply/)
[![Terraform QA Apply](${jenkinsURL}/job/${group^^}+${gitProject}+QA+Deploy+Terraform+Apply/badge/icon)](${jenkinsURL}/view/Projects/view/${group^^}/view/${gitProject}/view/By%20Environment/job/${group^^}+${gitProject}+QA+Deploy+Terraform+Plan/)

[![Terraform Staging Plan](${jenkinsURL}/job/${group^^}+${gitProject}+Staging+Deploy+Terraform+Plan/badge/icon)](${jenkinsURL}/view/Projects/view/${group^^}/view/${gitProject}/view/By%20Environment/job/${group^^}+${gitProject}+Staging+Deploy+Terraform+Apply/)
[![Terraform Staging Apply](${jenkinsURL}/job/${group^^}+${gitProject}+Staging+Deploy+Terraform+Apply/badge/icon)](${jenkinsURL}/view/Projects/view/${group^^}/view/${gitProject}/view/By%20Environment/job/${group^^}+${gitProject}+Staging+Deploy+Terraform+Plan/)

[![Terraform Prod Plan](${jenkinsURL}/job/${group^^}+${gitProject}+Prod+Deploy+Terraform+Plan/badge/icon)](${jenkinsURL}/view/Projects/view/${group^^}/view/${gitProject}/view/By%20Environment/job/${group^^}+${gitProject}+Prod+Deploy+Terraform+Apply/)
[![Terraform Prod Apply](${jenkinsURL}/job/${group^^}+${gitProject}+Prod+Deploy+Terraform+Apply/badge/icon)](${jenkinsURL}/view/Projects/view/${group^^}/view/${gitProject}/view/By%20Environment/job/${group^^}+${gitProject}+Prod+Deploy+Terraform+Plan/)

README
fi

# README.md
#   Add links in main README.md to rest of README files
#     infrastructure/ecs/README.md
#     infrastructure/terraform/README.md
#     docker/README.md
#   Setup a standard README format - Needs to be defined
# docker/README.md
#   Files to be copied into image. Config, entrypoint script
#   Link to docker image build?
#   Link to image in register
##
## .gitlab-ci.yml
##
#if [ -f '.gitlab-ci.yml' ]; then
# Update jenkins trigger url
#   curl -ik "https://jenkins2.eng.cs.org.com/job/CSB+accountsvc+QA+Terraform_Plan/buildWithParameters?token=${JENKINS_TOKEN}&cause=GitLab_CI&GIT_TAG=${CI_BUILD_TAG}"
# jenkinsJobURI="job/${group^^}+${gitProject}+QA+Terraform+Plan/buildWithParameters"
# jenkinsParams='token=\${JENKINS_TOKEN}&cause=GitLab_CI&GIT_TAG=\${CI_BUILD_TAG}'
# jenkinsBuildURL="${jenkinsURL}/${jenkinsJobURI}?${jenkinsParams}"
#sed "/curl/ s/\".*/\"${jenkinsBuildURL}\""


# TODO: Customize ecs & terraform with service name ${gitProject}
# terraform:  ecs-service.tf sed s/BaaS//i
#       aws/*.json: image:
# Update ECS with project name
if [ -f "${ecsJSONScript}" ]; then
  sed -i "/PROJECT_NAME/ s/PROJECT_NAME/${gitProject}/g" ${ecsJSONScript}
fi
# Update Terraform with project name

##
## Template specific changes
##
if [ "${projectType}" = "microservice_spring" ]; then
  # For gradle projects
  if [ ! -f settings.gradle ]; then
    echo "rootProject.name = '${gitProject}'" > settings.gradle
  fi
fi
# TODO: Option to tar repo. So user could download if gitlab create fails ??
###
### Create Git repository and upload it
###
git init
git add -A
git commit -m "Initial stub for ${group}/${gitProject} by ${BUILD_USER}"
git remote add origin git@${gitlabHost}:${group}/${gitProject}.git
GIT_SSH_COMMAND="ssh -A -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git push -u origin master

echo "INFO: Clone your prepared repository with: git clone git@${gitlabHost}:${group}/${gitProject}.git ."
echo "INFO: See your new project at: ${gitlabURL}/${group}/${gitProject}"
