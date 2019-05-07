## Chapter 4
### Loops

Loops in Ansible are very useful. The most simple, and most common use is
iterate through list of arguments and install, create, remove of directories,
packages, users, and so on.

#### The apt case

Let's assume, you want to install some packages. You already know, how to do it:

```
- name: Install nginx
  apt: pkg=nginx state=present update_cache=yes
  become: true
```

But how to install more than one package? Use tasks for each package? Yes, it
is possible, but not optimal.  
The solution is to iterate through items:  

```
- name: Install packages
  apt: pkg={{ item }} state=present update_cache=yes
  with_items:
    - nginx
    - htop
    - curl
    - wget
  become: true
```

(file tasks-main-apt.yml)

In this example I created a list inside `with_items`, with packages to install.
statement `{{ item }}` tells Ansible, that this task has to iterate through
`with_items`. Let's put this code into `roles/nginx/tasks/main.yml` file and
execute.

(Yes, I know, it looks stupid now, to use tag nginx with this task, but, hey,
  this is only the tutorial! :) )

After the execution, you should see something like:

```
ok: [mybox] => (item=['nginx', 'htop', 'curl', 'wget'])
```

__But...__  

You probably also saw the deprecation warning... This is something sad for me,
how often Ansible provides breaking changes. This is why I'm showing it here.
Anyway, let's do the changes according the warning, even if changes will be
completely implemented in version 2.11.

```
- name: Install packages
  apt:
    pkg: ['nginx', 'htop', 'curl', 'wget']
    state: present
    update_cache: yes
  become: true
```

(file tasks-main-apt-new.yml)

And, well, from my perspective, this is less clear, and output is not that
informative, like before:

```
TASK [nginx : Install packages] ************************************************
changed: [mybox]
```

#### Loop through items with other modules

To create directory structure, ansible uses `file` module, and this task can
go through items, and this time the loop is using `with_list`:

```
- name: Create directories structure
  file: path=/tmp/{{item}} state=directory owner="root" group="root"
  with_list:
    - "application"
    - "application/bin"
    - "application/bin/usr"
    - "application/logs"
    - "application/config"
```

From Ansible 2.5 it is recommended to use `loop` not `with_*` statements.
The documentation of it is here:
https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html#migrating-from-with-x-to-loop  

In this example the change is the simplest possible. Just switch `with_list`
with `loop`. Other `with-*` are more complicated.

```
- name: Create directories structure
  file: path=/tmp/{{item}} state=directory owner="root" group="root"
  loop:
    - "application"
    - "application/bin"
    - "application/bin/usr"
    - "application/logs"
    - "application/config"
```

In this example the directory `application` will be created under /tmp, and
subdirectories will be created as well. Notice the `state=directory`
statement. This means for Ansible, to create a directory, not a file.  
Another possible option is `state=touch` for create an empty file.


#### Do - Until loops

Ansible offers another type of loops - do - until. But honestly speaking,
after couple of years of work with Ansible, I didn't use it, even once.  
The only use case I see, is waiting for application start in background, or so.

#### wait_for

Not true loop, but on the top its function is similar to use case described
earlier. `wait_for` will be used later, when the AWS EC2 instance will be build.
