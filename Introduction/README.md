## Introduction
### Say hello to Ansible.

What is Ansible? Some say, it is configuration manager. Others - it is an
orchestrator. Also, some say it is ssh on steroids.

For me, all of those definitions fits. Partially :)

Ansible is easy to use, as it use ssh protocol to communicate with nodes. It
is very convenient, as nothing special is needed to run playbooks. From other
hand, not always people who has access to remote node should run playbooks
there (ok, we have different tools to prevent that :) ).

In this terms, Ansible can automate everything what you did manually or by
scripts on hosts, or remotely. In this meaning it is ssh on steroid.

Ansible is a configuration manager. As it can automatically run provisioning
of your nodes, or even create those nodes. Also, it can manage some other
resources, like ELB. But...

For me it is not fully configuration manager. It is configuration tool. As I
need to run Ansible to do things on nodes. Ok, I can automate it and run
Ansible playbooks in scheduled way, but it is not straight way to do it.  
In this case, Puppet, Saltstack - those are configuration managers, as those
tools not only do changes, but also check them in some intervals and fix all
changes done in other way. So, the remote configuration is like it should be -
as is defined and stored in version control (at least - should be).

Ansible is an orchestrator. It can run new entities, or remove them. And again,
yes, but from my experience, we have better tools for it. CloudFormation.
Terraform. Those are a few examples. It is not that convenient and easy going
process to use Ansible as a orchestrator.

So... It is a bad tool, right?

No.

Ansible is easy to learn, easy to use, easy to improve. It has a lot of
possibilities, and the biggest power of ansible is ability to fast run of
single commands on selected hosts.

By running `ansible -i hosts -m "service nginx reload"` I can easily and very
fast reload Nginx on all (maybe even 1000) servers defined in hosts.

This is the real power of Ansible.
