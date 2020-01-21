## Chapter 5
### Conditionals

Conditionals can be used in many ways. The simplest use of conditionals is to
decide if the task should be executed, or not.  
There are more sophisticated ways to use conditionals, but this tutorial is
getting started type, so I will focus on `when` only.

But on the first step, let's go back to proper track with Nginx, and remove
unnecessary code (task_main.yml).

#### When

Syntax of `when` conditional is simple. So, we have this task:

```
- name: Install packages
  apt:
    pkg: ['nginx']
    state: present
    update_cache: yes
  become: true
  tags:
    - nginx
```

The assumption on the beginning of this tutorial was, that this playbook will
be used for Ubuntu system. And what if this playbook will be run on other,
like RedHat? It is high probability, I can say - certainty of errors.  
In this case, there is a possibility to limit targets for execution, using
`when`:

```
- name: Install packages
  apt:
    pkg: ['nginx']
    state: present
    update_cache: yes
  become: true
  when: ansible_facts['os_family'] == "Debian"
  tags:
    - nginx
```

So, this task will be executed, when gathered fact `os_family` will be Debian
(this will work for Ubuntu as well). For other OS families, task will be
skipped:

```
TASK [nginx : Install packages] ************************************************
skipping: [mybox]
```

#### multiple when statements

Let's assume, you want to execute task on Debian based servers, but
on Production environment only. It is possible in other ways, but this can
be done in task as well:

```
when: ansible_facts['os_family'] == "Debian" and environment == "Production"
```

(`environment` in this example is a variable passed to playbook, or set in the
  playbook)

You can use `or` for the `when` statement as well.

In case when all conditions has to be true, the code can be written as a list:

```
when:
  - ansible_facts['os_family'] == "Debian"
  - environment == "Production"
```

#### Operators

In the example we were use the `==` operator. You can also negate: `!=`, use
greater/lower or equal: `>=`, `<=`, or greater/lower: `<`, `>`.

## [Next Chapter](../Chapter-06/README.md)
