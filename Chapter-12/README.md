## Chapter 12
### Provision ec2 instance

In order to provision Vagrant box the executed command was `vagrant up` or
`vagrant up --provisioning`. Provisioning tool and playbook was described
in Vagrantfile. But this provisioning can be run using `ansible-playbook`.

```
(ansible)$ ansible-playbook -i environment/localenv/ provision.yml
```

The result, regarding Ansible related run, will be the same.
Let's check then, how to provision ec2 instance. But first, add missing
variables (simply copy them from `localenv` vars file to `testing`). Also,
copy `vault.yml` file (vars.yml).

As you probably noticed, the executed playbook `createec2.yml` built base
machine only. And this ec2 instance need to be provisioned.

```
(ansible)$ ansible-playbook -i environment/testing/ provision.yml --list-hosts
```

As a first command, check available hosts. The result should be:

```
playbook: provision.yml

  play #1 (tag_Purpose_nginx): tag_Purpose_nginx	TAGS: []
    pattern: ['tag_Purpose_nginx']
    hosts (1):
      54.123.456.78

  play #2 (tag_Purpose_nginx): tag_Purpose_nginx	TAGS: []
    pattern: ['tag_Purpose_nginx']
    hosts (1):
      54.123.456.78
```

If this list will be empty, create a box, using examples from last Chapter.  
Why we have two plays, with the same IP? Well, the playbook contains two `hosts`
sections.  
Ok, all is set and ready to run provisioning.

```
(ansible)$ ansible-playbook -i environment/testing/ provision.yml
```

And... it failed. Why? Guess, what user you are using?

```
$ whoami
```

How do you think, is this user created on your instance? Of course not.

Although I do not recommend this, but in case of this tutorial I will use the
"power" user - `ubuntu`.

Let's run:

```
(ansible)$ ansible-playbook --user=ubuntu -i environment/testing/ provision.yml
```

`--user=<username>` is used for declaration which user should be used on remote
machine.

I'm sure, this time the provision was successful.

The command above will run provisioning on all machines with tag
`Purpose: nginx`. So, how to execute this playbook on one box only? Ansible
provided another parameter, called `--limit`. Let's see:

```
(ansible)$ ansible-playbook --user=ubuntu -i environment/testing/ \
provision.yml --limit=54.123.456.78
```

You can specify more hosts, using coma for multiple IP adresses.

Try to put IP address of your ec2 instance into the browser. Assuming, that
your security group is properly configured (port 80 should be open), you
should see the authorization prompt (as htpasswd was established before).

Now, remove... Yes, you know that :)
