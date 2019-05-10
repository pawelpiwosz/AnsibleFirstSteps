## Chapter 10
### Customize EC2 task

In last chapter you created an ec2 instance. But the task is... well...
Not ready for multiple use. But it isn't hard to make it customized. Let's
use variables for it.

Below you can see the last example, but after changes:

```
---
- hosts: 127.0.0.1
  connection: local
  gather_facts: false

  vars_files:
  - "environment/{{ec2_environment}}/group_vars/tag_Purpose_nginx/vars.yml"

  tasks:
    - name: Create new instance
      local_action:
        module: ec2
        region: "{{ec2_region}}"
        vpc_subnet_id: "{{ec2_subnet}}"
        assign_public_ip: "yes"
        instance_type: "{{ec2_type}}"
        image: "{{ec2_ami_id}}"
        group_id: "{{ec2_sg}}"
        key_name: "{{ec2_keyname}}"
        count: 1
        wait: yes
        instance_tags:
          Name: "{{ec2_name}}"
          Environment:  "{{ec2_environment}}"
          Purpose: "nginx"
          Provisioned: "Ansible"
      register: new_instance

    - name: Waiting for SSH
      local_action: wait_for host={{new_instance.instances[0].public_ip}} port=22  state=started
```

In order to use proper vars files, you need to include them into the playbook,
using `vars_files:`.

The next step is to fill `environment/testing/group_vars/tag_Purpose_nginx/vars.yml`.

```
---
# Environment name
ec2_environment: "testing"

# ec2 specific variable
ec2_region: "eu-west-1"
ec2_subnet: "<VPC Subnet ID>"
ec2_type: "t2.micro"
ec2_ami_id: "ami-08d658f84a6d84a80"
ec2_sg: "<security group id>"
ec2_keyname: "ansibletutorial"
ec2_name: "ansibletest"

```

Let's execute this version.

```
(ansible)$ AWS_PROFILE=ansible ansible-playbook -i environment/testing/ createec2.yml
```

Check, if all is ok:

```
(ansible)$ aws --profile ansible --region eu-west-1 ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`]| [0].Value]'

[
    [
        "i-05aad1fc0981a3309",
        "t2.micro",
        "34.247.244.79",
        "ansibletest"
    ]
]
```

Let's create another instance, with another name. This time you will use the
variables passed through command line:

```
(ansible)$ AWS_PROFILE=ansible ansible-playbook -i environment/testing/ createec2.yml -e ec2_name="ansibletest2" -e ec2_environment="testing"
```

There are two variables passed to playbook. `ec2_name` and `environment`. The
last one is needed in couple of places in the playbook. For including proper
variable files, and for creating a tag.  
Check again, this time change output to more readable:

```
(ansible)$ aws --profile ansible --region eu-west-1 ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`]| [0].Value]' --output table
----------------------------------------------------------------------
|                         DescribeInstances                          |
+----------------------+-----------+-----------------+---------------+
|  i-05aad1fc0981a3309 |  t2.micro |  34.247.244.79  |  ansibletest  |
|  i-0617cfa41f1cb888c |  t2.micro |  34.244.203.30  |  ansibletest2 |
+----------------------+-----------+-----------------+---------------+
```

As you can see, passing variables through command line, overrided the values
from variable file.

On the end of this chapter, remove all created instances to avoid
unnecessary costs.
