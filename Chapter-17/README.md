## Chapter 17
### Deeper look into the playbooks

In previous Chapters you learn the essentials of playbooks. So let's look
on playbook structure again, this time with some explanations.

#### hosts

You can think about `hosts:` as a global configuration of playbook run. You
specify there host(s) or groups of hosts, where playbook has to be executed.

You can specify here a lot of settings, like connection (for example, we used
`local` for creating ec2), the escalate of privileges pattern, serialization,
if facts should be gathered or not, and which user should be used (this can
be overrided in single task).

Gathering facts is very important part. At first, it needs some resources to
run. What is more interesting, you can cache facts in Redis.  
When you are working with different types of operating systems, services, etc,
I can assure you, you need to understand how, what and when is gathered as
facts.

#### vars

In `vars:` section you can specify variables. In my opinion this approach is
inefficient, but sometimes can be useful. I prefer to use:

#### vars_files

Section `vars_files:` contains paths to the variable files. You used it during
the work with this tutorial. And you know already, that you can differentiate
the file based on variables.

There is another method to load variable files, though. You can do it in the
tasks, by using `include_vars` module. It is up to you what you will use, I
personally prefer the `vars_files`, as it is more clear for me.

#### vars_prompt

We parametrized our playbooks using variables from files, or passed from
command line. But Ansible can ask the user for variable's value.
This ha to be done in `vars_prompt:` section. The syntax is simple:

```
vars_prompt:
  - name: nginx_version
    prompt: "Which version of Nginx should be installed?"
```

This code allows you to promt user about prefered Nginx version, and user's
answer will be available as a value of `nginx_version` variable.  
prompt can have a few more parameters, like `private: yes|no`, which will
hide on the console the answer given by user, or `encrypt` for encrypting the
value of the variable (passlib library has to be installed),

#### pre_tasks

The `pre_tasks:` section is run _before_ all tasks and roles. Let's suppose,
you need to prepare some files, like decrypt some external file, or remove
instance from loadbalancer, or send notification to email, Slack, whatever.

So, why to use tasks in different section than tasks: (as pre_task in fact is
a different section)? For me, the biggest benefit of it is to create the
logical separation between preparation and core part of the playbook.

#### post_tasks

The `post_tasks:` section has exactly the same meaning and purpose, like
`pre_tasks:`, only difference is, that this part is run after roles.

#### tasks

In `tasks:` section you are defining the tasks for execution. You can
combine it with

#### roles

`roles:`. The purpose for `tasks:` and `roles:` is to "do" something on remote
hosts.
