## Chapter 2
### Prepare Vagrantfile

To begin work with Vagrant, you need to have Vagrant and Virtualbox
installed in your system.  

Let's go through the most important elements of Vagrantfile.  

`config.vm.synced_folder ".", "/vagrant"` newly created box will have the
entire current directory mounted in `/vagrant` path. Why not.

`config.vm.define "mybox" do |mybox|` define name of new box and start to
configure it.

In `mybox.vm.*` section are the configuration parameters like image from
which the box will be created, box name, network config, etc.

Now, by running the command `vagrant up`, the box will be created. In order to
check the status of the instance, run `vagrant status`.

To login to the box, run `vagrant ssh`, or `vagrant ssh mybox`.

In order to remove the instance, run `vagrant destroy`.

### Ansible preparation

So, let's start with Ansible. Ansible need to know where to run playbooks. This
structure should be flexible enough to be ready for different environments -
this is one of the most important purposes of this tutorial.

So, create this directory structure in root of your project:


```
environment
|
|- localenv
```


In this directory create the `inventory` file for vagrant instance. This file
should contain:

* box name
* `ansible_ssh_host` as Vagrant is running on our local machine,
use `127.0.0.1`.
* `ansible_ssh_port` use value defined in Vagrantfile
* `ansible_user` to be sure, that Ansible will use proper user to connect
to the vagrant box
* `ansible_ssh_private_key_file` ssh key location for the user specified before.

Now, let's do something additional at this moment, but this step will be
a preparation for environment located on AWS.

Add to `inventory` file section:  

```
[tag_Purpose_nginx]
mybox
```  

This will create a hostgroup named `tag_Purpose_nginx` with one member.  

In environment/localenv directory create `group_vars/tag_Purpose_nginx`
directories structure. Add `vars.yml`. file there. What is the use of it?
`group_vars` combined with hostgroup allows to run playbooks against the
specified group of hosts without any other parameter. `tag_Purpose_nginx` means,
that on AWS the instance will be created with tag `Purpose` with `nginx` as
a value.

### First Ansible playbook  

First, fill the `vars.yml` file created in last step. Put there the values from
example file. Those values will be used to customize the Nginx config later.


Now it is time to create a playbook to run. Let's make it simple for now.
The filename will be `provision.yml`.  

At the beginning you need to install Python on remote machine. The problem with
Ubuntu 18 is simple - there is no Python preinstalled. You can do it inside
the Vagrantfile, but it will be useless, when you want to run this playbook
on AWS. So, let's do it using Ansible. Add to `provision.yml` those lines:  


```
- hosts: tag_Purpose_nginx
  gather_facts: false
  become: true
  become_method: "sudo"
  serial: 1

  tasks:
    - name: 'install python'
      raw: sudo apt-get -y install python

```

First, gathering facts is disabled. To gather facts from remote machine, you
need... yes, Python. Then using a `raw` module (I explain it a little later),
Python is installed.

Again, define the target and configuration for the run (yes, there will be two
  sections with `hosts`):  

```
- hosts: tag_Purpose_nginx
  gather_facts: true
  become: true
  become_method: "sudo"
  serial: 1
```  

This playbook will be run on specified hostgroup (defined in inventory file),
will gather Ansible facts from remote host, and be run as privileged user.
Also, no matter how many hosts will be in this hostgroup, the run will be
executed on one host at the time. There is no specification for username.
This playbook will be run with your user, except the vagrant box, where user
vagrant was specified before (again, in inventory file).  

Add some tasks to execute. It can be done in (as I call it) "flat" file, but
this approach will be a blocker in the future, for more complex solutions.
So, use `roles`.  

Add to `provision.yml` this part:  

```
  roles:
    - { role: "nginx", tags: ["nginx"] }
```

__Remember, indendation is very important!__

So, `provision.yml` calls for the role named nginx. This is enough for the
config, but there is also `tags: ["nginx"]`part. Having this, you can run this
playbook, and call explicity for execution of this role only.  

It is time to create a role.

### The Nginx role.

In the root directory of the project, create this structure:  

```
roles
|
|- nginx
..|
..|- tasks
..|- handlers
..|- templates
```

`tasks` is the place for manifests. `handlers` useful 'feature' where handlers
for the restarting, reloading, etc can be defined and executed on the end of
the playbook. Templates with jinja2 are stored in `templates` directory.


So, let's build the tasks file.  
Create `main.yml` file in the tasks directory. The Vagrant box is based on
Ubuntu 18, so the provisioning will be created for Ubuntu.

Add this part to the file:

```
---
- name: Add Nginx repository
  command: add-apt-repository -y ppa:nginx/stable
           creates=/etc/apt/sources.list.d/nginx-stable-saucy.list
  become: true
  tags:
    - nginx

- name: Install nginx
  apt: pkg=nginx state=present update_cache=yes
  become: true
  tags:
    - nginx
```

As you can see, the file is started with `---`. Then each task is starting with
`-`.  
The base structure is simple:
* name of the task (this will be shown during the execution)
* type of module to use (in this case, there are `command` and `apt`)
* despite the fact, that `become` is default value (check ansible.cfg), you can
add it to each task.
* tags. Those tags are used when you run playbook with specified tag(s):  
```
ansible-playbook provision.yml --tags=nginx
```  
When not used, all tasks will be executed.

In this example, `command` module is used. This is how you can execute the
"standard" command from shell.  
`apt`, another module from the example, has some values:
* pkg - which packages should be installed
* state - state of the package. Installed (`present`), or uninstalled
(`absent`)
* update_cache - this is equal to `apt-get update` command - refreshing the
apt cache.  

Now it is time to add execution of this playbook by Vagrant. Again, remember
about indendation.  
Add to the Vagrant file section:  
```
mybox.vm.provision "ansible" do |ansible|
  ansible.limit = "tag_Purpose_nginx"
  ansible.playbook = "provision.yml"
  ansible.inventory_path = "./environment/localenv"
end
```

This part is adding provisioner called 'ansible' to the mybox server. The
execution is limited to hostgroup called 'tag_Purpose_nginx', Ansible should
execute the provision.yml file, and the path to the environment is also
defined.  
(The whole Vagrantfile is in the Vagrantfile-part2 file in this Chapter)


After sucessful run, you should have similar output:

```
==> mybox: Running provisioner: ansible...
    mybox: Running ansible-playbook...

PLAY [tag_Purpose_nginx] *******************************************************

TASK [Gathering Facts] *********************************************************
ok: [mybox]

TASK [nginx : Add Nginx repository] ********************************************
changed: [mybox]

TASK [nginx : Install nginx] ***************************************************
changed: [mybox]

PLAY RECAP *********************************************************************
mybox                      : ok=3    changed=2    unreachable=0    failed=0   

```

### Adding handler

Last thing for this chapter will be defining the handlers. In this example
there will be two handlers, for reloading and restarting nginx.

Create file `main.yml` in roles/nginx/handlers. Add there those definitions:

```
---
- name: restart nginx
  service: name=nginx state=restarted
  become: true
  tags:
    - nginx

- name: reload nginx
  service: name=nginx state=reloaded
  become: true
  tags:
    -nginx
```

The file structure is the same like for tasks.  

For enable execution of any of handlers, `notify` statement has to be used.

Change the nginx installation tasks to:

```
- name: Install nginx
  apt: pkg=nginx state=present update_cache=yes
  become: true
  notify: reload nginx
  tags:
    - nginx
```

When you run this tasks, and Ansible will execute it (what means there were
 changes), you should see something similar to:

```
RUNNING HANDLER [nginx : reload nginx] *****************************************
changed: [mybox]
```

There is no use for the handler in this section, so remove it. It will be used
elsewhere.

Important to know: Handlers will not be executed, if there are no changes done
by the task.
