## Chapter 15
### Roles structure

In previous chapters you created your first role. Let us remind the current
structure in the role you were built.

```
~/ansible/roles/nginx$ ls
handlers  tasks  templates
```

As you can expect, those are not all elements available. Here is the
description of all available parts of the role. All of those directories
should contain `main.yml` file.

`tasks`  
The 'core' of role. Contains playbooks with tasks to run.

`handlers`  
Tasks to run once at the end of execution.

`meta`  
Role metadata and dependencies.

```
---
dependencies: []
```

if your role doesn't contain any dependent role, or:

```
---
dependencies:
  - { role: nginx }
```

Let's suppose, you have role called `WordPress`, and you want to install it on
the server. It will be wise to have some webserver. By adding the dependency
above, nginx wil be executed _before_ current role.

`files`  
Directory to place files for copying to the remote server by `file` module.

`templates`  
More sophisticated way of copying files, with possibility to construct
specific content of the files, depend on needs, variables, settings, etc.

`vars`  
Directory for storing variables. In case described in this tutorial, this
directory was obsolete, as it uses different approach.

`defaults`  
Default values of variables. Very useful for building parametrized Galaxy roles.
