## Chapter 6
### Variables

Variables can be set in different ways. Can be stored in vars files, can be
set in playbooks, overrided in command line in ansible-playbook command, or
set (or generated) through tasks.

#### syntax

The base syntax is straightforward:

```
variable: "string"
variable: number
variable: boolean
```

#### Dictonaries

Defining the dictionary:

```
var_dict:
  field1: "string"
  field2: "string"
  field3: number
```

To access the value, use:

```
var_dict.field2
```

or

```
var_dict['field2']
```

It is possible to create a more compicated dictionary:

```
var_dict:
  me:
    name: "John"
    age: 40
  you:
    name: "Mike"
    age: 65
```

Access to this variable is simple:

```
- name: Print phone records
  debug:
    msg: "{{ item.value.name }} is {{ item.value.age }}, and the name in the dictionary is {{ item.key }}"
  loop: "{{ lookup('dict', users) }}"
```

This code will print all records from dictionary.

#### Defining variables in playbook

Variables have to be declared with some values. If not registered in tasks,
have to be set, or imported.  
Set variables in playbook:

```
vars:
  - var1: "value"
  - var2: "value"
```

Import var files:

```
vars_file:
  - "path/to/file/vars.yml"
```

#### Ansible facts

Very good example of dictionary is Ansible facts. You can take them in the
task:

```
- debug: info=ansible_facts
```

or:

```
- debug:
  info: ansible_facts
```

Method `debug` is responsible for printing data during execution.

You can access the specific fact directly as a variable:

```
{{ ansible_facts['devices']['xvda']['model'] }}
```

This example from documentation will store model of the device xvda.

#### Register variable

Registering variables gives you more flexibility to use new variable:

For example, you can register as variable the refference to HEAD in github repo.
Why? For deployments, for example.

```
- name: Get HEAD from branch
  command: git ls-remote URL_to_repo | grep 'refs/heads/master'
  register: last_commit
```

Now, you can use this refference later.

#### Set your fact

Ansible offers module called `set_fact`. The most useful feature of it is to
set facts-like variable, specific for each host where playbook is run.

Example:

```
- name: Register fact
  set_fact:
    first_fact: "value"
    other_fact: "other value"
```

`set_fact` can be used with `register`. For example, when you register a
dictionary (like in our example with repo HEAD), you wish to have only the hash
to latest state.

```
- name: Get HEAD from branch
  command: git ls-remote URL_to_repo | grep 'refs/heads/master'
  register: last_commit

- name: Set hash from branch
  set_fact:
    last_commit_hash="{{last_commit.stdout_lines[0][0:7]}}"
```
