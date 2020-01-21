## Chapter 18
### The good of Ansible is the bad

Yeah... What is the best thing about Ansible? It doesn't need any additional
configuration to run. Ansible works using SSH, so wherever you have access
through ssh, you can use Ansible.

And that is the best thing...

And the worst.

Ansible is slow. Not fully reliable, I experienced many problems with mine and
my colleagues runs.

Anyway, on the beginning of this tutorial (when I expected it will be
definitely shorter ;) ) I provided an upgraded configuration for Ansible.

Now it is time to explain this config, as it contains some added parameters.

Some time ago in one of my previous company I wrote the article about
accelerate Ansible, and the provided differences between original and tweaked
config were huge. Although, in some cases those changes generated problems,
which I mentioned earlier. One of the best example is `pipelining`. In the
core, it should speed up the execution, but sometimes it breaks it... Also,
some of the tweaks I made are not related to speed up execution, but for
adding more usability.

So, let's take a closer look to the current config file

```
[defaults]
vault_password_file = ./.vault_password
host_key_checking = False
transport = ssh
become_flags=-H -S -n
command_warnings = False
inventory_ignore_extensions = ~, .orig, .bak, .ini, .cfg, .retry, .pyc, .pyo, .yml, .md, files, templates, wiki
timeout = 60
roles_path = ./.galaxy

[ssh_connection]
ssh_args=-o ForwardAgent=yes -o StrictHostKeyChecking=no -o ControlMaster=auto -o ControlPersist=60s
pipelining=True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
```

The important part is `[ssh_connection]`. As I said before, Ansible is using
ssh as a transport layer. That is why I'm passing some ssh parameters in the
config file as `ssh_args`.

`ForwardAgent=yes` - the same use case like in ssh config file. It isn't
related to speed up Ansible, but it is needed in case of jumping through
the bastion host server.

`StrictHostKeyChecking=no` - consider dynamic environment. There is a huge
possibility that sooner or later one of the ip adresses or hostnames will not
match the one you have in knownhosts file. And Ansible will fail (as ssh will
fail). So, avoiding this problem, this part of the config make us sure,
that knownhosts issue will not be a problem anymore.

`ControlMaster=auto` - this setting activates multiplexing. Auto is the best
option here, and it means, that if master connection doesn't exist - create it
and use. Important is to be sure, that the ssh config has proper `MaxSession`
limit set.

`ControlPersist=60s` - in this case, the default value is enough, but you can
tweak it and check what happened. This setting is saying how long to keep the
open connection as a socket.

Now the most important setting - `pipelining=True`. By default (without
pipelining), each task opens and closes ssh connection. Very ineffective.
Pipelining changes this behaviour and it make Ansible much faster.  
But (there is always some __but__) you have to be aware to remove `requiretty`
from sudoers file.

`control_path = /tmp/ansible-ssh-%%h-%%p-%%r` - session control file name
pattern. It is commonly known, that the name of this file cannot be too long.
That is why the best place to keep it is `tmp` (as in fact it is a temporary
file), and build the name in recognizable, but short way. This parameter is
related to `ControlPersist` one.

## [Next Chapter](../Chapter-19/README.md)

