## Chapter 7
### Ansible-vault

#### Preparations

Ok, you already learned a lot about Ansible. I'm sure, you know also, that
IaaS (Infrastructure as a Code) should be kept in Version Control system, like
GitHub. And know you started to see some problem. Important problem. How to
store sensitive data in the repository?

Ansible gives us some possibility to do that, but first, let's prepare the
Nginx virtual server config and htpasswd file.

In `tasks` directory create file nginx-config.yml, and put there two files

```
---
- name: Install vserver config
  template: src=vserver.conf
            dest=/etc/nginx/sites-enabled/vserver.conf
  notify: restart nginx
  when: ansible_facts['os_family'] == "Debian"
  tags:
    - nginx

- name: Install htpasswd
  htpasswd: path="/opt/htpasswd"
            name={{htpasswd_user}}
            password={{htpasswd_password}}
            owner=root
            group=www-data
            mode=0640
  notify: restart nginx
  tags:
    - nginx
```

(nginx-config-1.yml)

First task will copy vserv.conf file to its location, second will prepare
htpasswd file with user and password. Notice the `htpasswd` module, and
conditional for vserver config file.

Logic dictate though, you should remove the default file.
Let's add this task at the beginning of nginx-config.yml

```
- name: Remove default config
  file:
    path: "{{item}}"
    state: absent
  become: true
  loop:
    - /etc/nginx/sites-available/default
    - /etc/nginx/sites-enabled/default
  tags:
    - nginx
```

(nginx-config-2.yml)

Now it is time to add our template.  
Create file `vserver-template.conf` in `templates` directory.

```
server {
  listen 80 backlog={{backlog_value}};
  server_name {{server_name_value}};
  root /var/www/html;
  location / {
    try_files $uri $uri/ =404;
  }
}
```

(vserver-template.conf)

Simple. As you can see, we need new variables: `{{backlog_value}}`,
`{{server_name_value}}`, `{{htpasswd_user}}` and `{{htpasswd_password}}`

So, update the `environment/localenv/group_vars/tag_Purpose_nginx/vars.yml`
file.

```
backlog_value: 1024
server_name_value: "newserver.com"
htpasswd_user: "myuser"
htpasswd_password: "secretpassword"
```

(vars-1.yml)

Last thing. Add to virtualenv `passlib` library on target machine. Well, this
job need two new tasks in `nginx-config.yml` file. First install pip (just in
case if remote machine doesn't have one), and then passlib library to be
able to use htpasswd module and encrypt the password in htpasswd file.

```
- name: Install pip package
  apt:
    pkg: ['python-pip', 'apache2-utils']
    state: present
    update_cache: yes
  become: true
  when: ansible_facts['os_family'] == "Debian"
  tags:
    - nginx

- name: Install passlib Python package
  pip:
    name: passlib
    become: true
  tags:
    - nginx
```

(nginx-config-3.yml)

Those tasks install pip and apache2-utils, and then Python passlib library.

So, it was a lot of udates and changes.  
Let's run `vagrant up --provision`.

And?

Nothing!

Tasks from new file weren't executed, of course.

__Only the `main.yml` is executed automatically__. Other files have to be
included.  
Open tasks/main.yml and add on the end line:

```
include: nginx-config.yml`
```

(task-main.yml)

#### Encrypt source.

But, hey, `vars.yml` contains _unencrypted_ password! This cannot be sent to
the repository! `ansible-vault` is our tool here.

As the first thing, we need to have a password for vault.

Create file `.vault_password` with the content `pass2Vault` in root directory
of the project. Now, this is not a best place to keep this file. Although we
will leave it as is, and add `.vault_password` to `.gitignore`. This is
obvious, I hope.

Now, update the ansible.cfg file and add line in `[defaults]` section:

```
vault_password_file = ./.vault_password
```

(.vault_password)

Here is time to create encrypted file.

```
ansible-vault create environment/localenv/group_vars/tag_Purpose_nginx/vault.yml
```

with content:

```
vault_htpasswd_password: "secretpassword"
```

Saved file should be similar to:

```
$ANSIBLE_VAULT;1.1;AES256
62396237366566633039653339666131353163666535353936663430303462393565306330363362
3337623437356430343338373634643964616233353633660a393364366165313066366339636637
376262313434326132666233623838396663626134
```

As you see, Ansible didn't ask for password. It is configured and stored in
file, ready to use.

Useful commands for working with ansible-vault:
* `ansible-vault edit` - in order to edit encrypted file
* `ansible-vault create` - in order to create encrypted file
* `ansible-vault rekey` - in order to change encryption key
* `ansible-vault encrypt` - in order to encrypt the file
* `ansible-vault decrypt` - reverse to previous one

Last thing here, what you need to do, is to point the variable in vars.yml to
encrypted one.

Change from:

```
htpasswd_password: "secretpassword"
```

to:

```
htpasswd_password: "{{vault_htpasswd_password}}"
```

(vars-2.yml)
