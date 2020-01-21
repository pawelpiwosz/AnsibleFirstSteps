## Chapter 1
### Environment preparation

Ansible can be installed directly in your system, but I do not recommend it.  
From my perspective, the best idea is to install Ansible in Virtualenv.
This is giving the possibility to use different version of Ansible, what can be
very useful sometimes. Also, this gives a possibility to install all needed
packages in closed environment.

So, let's prepare the Virtualenv.  
First, create the file `requirements.txt` with all needed packages.  
Packages can be just like in our example, and this mean that the newest
version will be installed. Other way is to keep the package version:
`boto==2.49`.  
Put into this file two packages:  

```
ansible
boto
```

`Ansible` is obvious, I hope, `boto` is the Python library for working with
AWS.  
**In case you don't have virtualenv installed you can install it via **```pip install virtualenv```


Now, copy the `setupenv.sh` file to your project directory, and run it.

So, now the environment should be ready, with Ansible and boto installed
(with all needed dependencies).

How to run this environment?  
Simply run `. ansible/bin/activate`. You should see the `(ansible)` before
your prompt.  
In order quit, execute `deactivate`.
You should run all commands related to this tutorial from this virtualenv.

### Ansible config

Ansible can use three locations for config file.  
* /etc/ansible/ansible.cfg
* /home/$USER/ansible.cfg
* /your_project_root_dir/ansible.cfg

So, let's create the config file specific for this the project in the project
root directory.  
Referring to example from this Chapter, there are two sections:  
* defaults
* ssh_connection

`Defaults` section is most common, and in `ssh_connection` is responsible for
making Ansible faster. In theory. I'll back to it later.


(There is known issue with creating a `$HOME` directory by Ansible. You can
  simply delete it.)

## [Next Chapter](../Chapter-02/README.md)
