# Create a GitLab project with stubbed repository

This is a POC.

### Build Process
1. Create GitLab project
 + Handled by: createGitLabProject.sh
+ Create Repository
 + Handled by: createStubRepository.sh
+ Upload repository to GitLab
 + Handled by: createStubRepository.sh
 + Repository is created by copying templates on top of the repository.
   Starting with the the global template. Then if a zip file was upload, it's
   contents will be copied on top. Lastly any modifications the script knows
   about will be applied.
+ Update Jenkins job parameters
 + Handled by backend jobs and jenkinsParameters.sh

### Templates
All templates are located under templates

There are 3 types of templates:
- global
 - This is always the first template applied
 - Directory: templates/global
- normal templates
 - These contain files and directories to be copied
 - Any directory under templates without a + in the name
- multi-layered templates
 - These are a list of normal templates to be copied in order
 - Defined in: templates/templates_layered.properties

 All template directories should contain template_description.txt.
 This is where Jenkins will get the template's description.
 It should be a single line description.
