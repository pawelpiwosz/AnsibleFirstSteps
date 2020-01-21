## Chapter 14
### Useful commands

#### Tips for ansible-playbook run

One of the useful command to check the status of the playbook was provided
before, when you checked what instances are available for the playbook to
execute changes.

```
(ansible)$ ansible-playbook -i environment/testing/ provision.yml --list-hosts
```

Another useful command is `--list-tags`. Sometimes there is a need to check
what tags are used in playbooks:

```
(ansible)$ ansible-playbook -i environment/localenv/ provision.yml --list-tags

playbook: provision.yml

  play #1 (tag_Purpose_nginx): tag_Purpose_nginx	TAGS: []
      TASK TAGS: []

  play #2 (tag_Purpose_nginx): tag_Purpose_nginx	TAGS: []
      TASK TAGS: [nginx]
```

So, there are two plays, first without any tag inside, and second play contains
only one tag - nginx.  
You should be aware, that this check is going not only through the file
specified in command line, but all related files to that one. So, in this case,
you see task from provision.yml and included role nginx.

What about checking list of tasks in playbook?

```
(ansible)$ ansible-playbook -i environment/localenv/ provision.yml --list-tasks

playbook: provision.yml

  play #1 (tag_Purpose_nginx): tag_Purpose_nginx	TAGS: []
    tasks:
      install python	TAGS: []

  play #2 (tag_Purpose_nginx): tag_Purpose_nginx	TAGS: []
    tasks:
      nginx : Add Nginx repository	TAGS: [nginx]
      nginx : Install packages	TAGS: [nginx]
      nginx : Upload default config file	TAGS: [nginx]
      nginx : Remove default config	TAGS: [nginx]
      nginx : Install pip package	TAGS: [nginx]
      nginx : Install passlib Python package	TAGS: [nginx]
      nginx : Install vserver config	TAGS: [nginx]
      nginx : Install htpasswd	TAGS: [nginx]
```

```
(ansible)$ ansible-playbook -i environment/localenv/ provision.yml --check
```

will check you run, without any changes. It is a dry run.

Very useful is a possibility to check the syntax of your code.

```
(ansible)$ ansible-playbook -i environment/localenv/ provision.yml --syntax-check
```

You can wish, that Ansible will ask if should be executed for each task. Use
`--step`.

Also, you can start from any task in playbook: `--start-at-task="Install pip package"`.

The last useful parameter I'd like to show is `--force-handlers`. This
parameter will force the ansible to run handlers, no matter what status of the
task is (so, if something was changed, or not, even if task fails).

#### Useful setting for user who is running the playbook.

You noticed before, that ansible uses user `vagrant` for localenv and `ubuntu`
for testing (or AWS related environments). It is not convenient way to
remember all the time to add `--user=ubuntu` to the run.  
Of course, I strongly discourage to use Ansible (and not only Ansible) with
ubuntu user (or ec2-user, or root), but sometimes... Tests, home use cases,
that can be acceptable (with a lot of pain ;) ). Well, better to be prepared.

In section `-hosts` in your playbook you can have:

```
user: "{{ 'vagrant' if environment=='localenv' else 'ubuntu' }}"
```

But as I said. I strongly recommend to use recognizable and auditable usernames.

## [Next Chapter](../Chapter-15/README.md)
