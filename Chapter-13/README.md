## Chapter 13
### Remove resources from AWS

Ansible allows to create and manage resources, but also to remove them.

Let's create a new instance first. Use example from last chapters.

```
(ansible)$ AWS_PROFILE=ansible ansible-playbook -i environment/testing/ createec2.yml \
 -e ec2_name="ansibletest1" -e ec2_region="eu-west-1" -e ec2_zone="eu-west-1a" \
 -e ec2_environment="testing"
```

Check instance

```
$ aws --profile ansible --region eu-west-1 ec2 describe-instances --query \
'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,SubnetId,Tags[?Key==`Name`]| [0].Value]' \
--output table

-----------------------------------------------------------------------------------------
|                                   DescribeInstances                                   |
+----------------------+-----------+----------------+------------------+----------------+
|  i-00864ef538763c8af |  t2.micro |  34.123.456.78 |  subnet-827233e6 |  ansibletest1  |
+----------------------+-----------+----------------+------------------+----------------+
```

All is ok, so, copy code below to new file `removeec2.yml`.

```
---
- hosts: 127.0.0.1
  connection: local
  gather_facts: false


  vars_files:
    - "environment/{{ec2_environment}}/group_vars/tag_Purpose_nginx/vars.yml"

  tasks:
    - name: Gather ec2 facts
      local_action:
        module: ec2_remote_facts
        region: "{{ec2_region}}"
        filters:
          instance-state-name: running
          "tag:Name": "{{ec2_name}}"
          "tag:Environment": "{{ec2_environment}}"
      register: ec2_facts

    - name: Remove instance
      local_action:
        module: ec2
        region: "{{ec2_region}}"
        instance_ids: "{{ec2_facts['instances'][0]['id']}}"
        wait: true
        state: absent

```
First task is very important. As this playbook is executed locally, and
gathering facts is off, we need to pass somehow instance id to the next task.
This is why we need to gather facts data from this ec2 - what is captured and
stored in `ec2_facts` variable.

Second task removes the instance. instance_id is passed to this task using
`{{ec2_facts['instances'][0]['id']}}`. We are using variable registered before,
and as it is a dictionary, we extract instance_id from it.  
Notice `state: absent`. It means, this resource shouldn't be available any
longer.

As you see, this playbook requires 3 parameters:
* ec2_region
* ec2_environment
* ec2_name

Let's remove the instance created just a moment ago.

```
(ansible)$ AWS_PROFILE=ansible ansible-playbook -i environment/testing/ removeec2.yml \
 -e ec2_name="ansibletest1" -e ec2_region="eu-west-1"  -e ec2_environment="testing"
```

Let's check:

```
$ aws --profile ansible --region eu-west-1 ec2 describe-instances --query \
'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,SubnetId,Tags[?Key==`Name`]| [0].Value]' \
--output table
---------------------------------------------------------------------
|                         DescribeInstances                         |
+----------------------+-----------+-------+-------+----------------+
|  i-00864ef538763c8af |  t2.micro |  None |  None |  ansibletest1  |
+----------------------+-----------+-------+-------+----------------+

```

This can be little confusing. The ec2 is removed, but still listed? Yes,
ec2 is removed and it is in terminated state. You can observe, there is no
Public IP assigned and no Subnet. That is a prompt, but let's check it more
deeply, and improve the check:

```
$ aws --profile ansible --region eu-west-1 ec2 describe-instances --query \ 'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,SubnetId,State.Name,Tags[?Key==`Name`]| [0].Value]' \
--output table
-----------------------------------------------------------------------------------
|                                DescribeInstances                                |
+----------------------+-----------+-------+-------+-------------+----------------+
|  i-00864ef527763c8af |  t2.micro |  None |  None |  terminated |  ansibletest1  |
+----------------------+-----------+-------+-------+-------------+----------------+
```

As you can see, I added `State.Name` field, and the instance is indeed
terminated. AWS shows terminated resource for some period of time. Don't worry
about it.

And, as always... no, not this time. You removed the instance already ;)

## [Next Chapter](../Chapter-14/README.md)
