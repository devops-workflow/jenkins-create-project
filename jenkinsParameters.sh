#!/bin/bash
#
# Create parameter properties file for Jenkins Create Project job
#

envName=Dev
tmpFile="${PWD}/tmp.properties"
propertiesDir="etc/jenkins/${envName}"
# File for Jenkins parameters
propertiesFile="${propertiesDir}/project_templates.properties"
dirTemplates=templates
# One line description of the template
templateDescriptionFile='template_description.txt'
# List of multi-layered templates and descriptions
#   Format: name=description
#     name: [template+[template+...]]template
layeredTemplatesFile="${dirTemplates}/templates_layered.properties"

echo "INFO: Building Jenkins parameters properties file..."
pushd ${dirTemplates} 2>&1 >/dev/null
# TODO: If want all templates * multi-layered sorted, sort everything in hash.
#       Then build property file lines at end
### Get all templates
templates=$(ls -1F | grep / | cut -d/ -f1 | LC_COLLATE=C sort)
### Get template descriptions
listDescriptions=''
listTemplates=''
for template in ${templates}; do
  listTemplates="${listTemplates},${template}"
  if [ -f "${template}/${templateDescriptionFile}" ]; then
    # read template description from file
    desc=" - $(head -n1 ${template}/${templateDescriptionFile} | sed 's/,/;/g')"
  else
    desc=''
  fi
  listDescriptions="${listDescriptions},${template}${desc}"
done
popd 2>&1 >/dev/null
listTemplates=$(echo ${listTemplates} | cut -c2-)
listDescriptions=$(echo ${listDescriptions} | cut -c2-)
# Add multi layered templates from properties file
if [ -f ${layeredTemplatesFile} ]; then
  echo "INFO: Reading Layered Templates file..."
  templates=$(sort ${layeredTemplatesFile} | while read line || [[ -n "$line" ]]; do
    echo ${line}
  done)
  IFS_OLD=$IFS
  IFS=$'\n'
  for line in ${templates}; do
    template=$(echo "$line" | cut -d= -f1)
    desc=$(echo "$line" | cut -d= -f2)
    # TODO: rip apart and verify each template exists
    #for t in ${template//+/ }; do
    #  if [ ! -d "${dirTemplates}/${t}" ]; then
    #    echo "ERROR: Template does not exist: ${dirTemplates}/${t}"
    #    exit 1
    #  fi
    #done
    listTemplates="${listTemplates},${template}"
    listDescriptions="${listDescriptions},${template} - ${desc}"
  done
  IFS=$IFS_OLD
fi

cp /dev/null ${tmpFile}
echo "templates=${listTemplates}" >> $tmpFile
echo "templateDescriptions=${listDescriptions}" >> $tmpFile
# Add default selection
#echo "templateDefault=global" >> $tmpFile
echo "templateDefault=microservice_spring" >> $tmpFile

### Check if there are any changes
echo "INFO: Checking if changes were made to Jenkins parameters properties file..."
if [ -f "${propertiesFile}" ]; then
  diff -q ${tmpFile} ${propertiesFile} > /dev/null 2>&1
  if [ $? -gt 0 ]; then
    commit="true"
  fi
else
  # Create & commit
  mkdir -p ${propertiesDir}
  commit="true"
fi
if [ "${commit}" == "true" ]; then
  mv ${tmpFile} ${propertiesFile}
  git add etc/*
  git commit -m "Update Jenkins parameters for new template by ${BUILD_USER}"
fi
