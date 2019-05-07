## Chapter 3
### Add template

It is time, to make the config of Nginx more flexible. Create `templates`
directory in nginx role.  
Templates are using Jinja2 for managing variables. You have some variables
defined in vars.yml file (previous Chapter), to use them you need to use very
simple notation: `{{ variable }}`.

Let's update the default config, installed by Nginx.

```
events {
  use epoll;
	worker_connections {{worker_connections_value}};
	multi_accept on;
}

worker_rlimit_nofile {{worker_connections_value}};
```

(The full file is in this Chapter's examples.)

Now, this file need to be copied to remote server. To do so, use `template` module.

```
- name: Upload default config file
  template:
    src: nginx.conf
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: 0644
  notify:
    - restart nginx
  tags:
    - nginx
```

(The complete main.yml file is available in examples.)


Now, you can run the provisioning of new machine, or simply run
`vagrant up --provision`.
