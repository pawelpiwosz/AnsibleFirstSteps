## Chapter 16
### Ansible Galaxy

Galaxy in short is a library of resources developed by community. You can find
there a lot of roles, which can be installed in your projects.

Go and visit Galaxy page: https://galaxy.ansible.com/

Other possibility of use is to build your own Galaxy roles, put them in
GitHub, and then use Ansible Galaxy to download them to your project.

What are the main advantages of using Galaxy?

* possibility to use the same role multiple times.
* possibility of control the role behavior from one place.
* automate common roles used across projects (for example - common Nginx role)
* easier and faster way to fix issues in role
* cleaner and shorter code in project

I think, those are most important.

#### Configure Ansible to use Galaxy

Basically, you don't need any configuration, except one.

Add to your ansible.cfg this line:

```
roles_path = ./.galaxy
```

in `[defaults]` section.

(ansible.cfg)

This setting means, that all roles downloaded with Galaxy will be stored in
`.galaxy` directory, in root of your project. Also, during the execution
Ansible will know, from where get roles.

#### Download roles through Galaxy

There is a possibility to download roles from command line. But, hey, we do
not work like that any longer. Let's do it 'properly' and download roles
using predefinied file.

Create file `galaxy.yml`.

```
---
- name: my_php
  src: geerlingguy.php
  version: 3.7.0
```

(galaxy.yml)

What is going on in this example:  
First, the name of the task is given. Also, you have to be aware, this is the
name of role in further use. I deliberately use other name than original, to
show you how it works. Then, using `src`, I specified what role should be
downloaded. In this case it is role from Galaxy repository (the  link is on the
beginning of this Chapter). And the end I explicitly define the version of the
role.

So, Let's run Galaxy:

```
(ansible)$ ansible-galaxy install -r galaxy.yml
```

Under the hood, the role is downloaded from GitHub and extracted. You should
see something similar to this:

```
- downloading role 'php', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-php/archive/3.7.0.tar.gz
- extracting my_php to /home/pawel/test/ansible/.galaxy/my_php
- my_php (3.7.0) was installed successfully
```

And check the `.galaxy` directory:

```
$ ls .galaxy
my_php
```

Now, I need to explain one thing. If you download this role in this way:

```
$ ansible-galaxy install geerlingguy.php
```

The role will be installed as geerlingguy.php. Remember about it.

The roles can be downloaded from GitHub directly:

```
src: git+ssh://git@github.com/user/repository
```

#### Use downloaded roles

The syntax is exactly the same, like for roles created in project.

```
  - { role: "my_php" }
```


#### Creating a role

This part will be short, as it isn't a place for details.

In order to create a role, run:

```
$ ansible-galaxy init role_name
```

This command will create whole structure for the role. Remember, in case of
roles, it is very important to provide properly filled `meta/main.yml`.  
At least, you have to have

```
---
dependencies: []
```

in the file. Other information you can find in documentation, or looking to
existing Galaxy roles.

## [Next Chapter](../Chapter-17/README.md)

