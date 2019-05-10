## Chapter 8
### Create first EC2 instance

Let's start to build EC2 instance. In this case you need another playbook.
`provision.yml` is for provisioning purpose. So, let's create `createec2.yml`.

This time the playbook will use localhost as a target. Why? Well, there is no
instance to provision, and the create process will be executed. Think about it
like about running AWS CLI command. Those commands are executing on your
machine, and work with cloud.

Remember to copy proper values in the fields. You need to provide VPC ID,
Subnets ID, Security Group, etc.

```
---
- hosts: 127.0.0.1
  connection: local
  gather_facts: false

  tasks:
    - name: Create new instance
      local_action:
        module: ec2
        region: "eu-west-1"
        vpc_subnet_id: "<VPC Subnet ID>"
        assign_public_ip: "yes"
        instance_type: "t2.micro"
        image: "ami-08d658f84a6d84a80"
        group_id: "<security group id>"
        key_name: "ansibletutorial"
        count: 1
        wait: yes
        instance_tags:
          Name: "ansibletest"
          Environment:  "testing"
          Purpose: "nginx"
          Provisioned: "Ansible"

    - name: Waiting for SSH
      local_action: wait_for host={{new_instance.instances[0].public_ip}} port=22  state=started


```

First of all, gathering facts is off, you don't need it here. Then the task
is running module `ec2` as a `local_action`. There are 3 ways to run tasks
locally, and some say thay local_action is the less apropriate, but I like to
use it for its clarity.  
module `ec2` has some parameters which are obligate to set. As you probably
know, to run ec2 in AWS you need to set region, subnet, security group,
instance type, AMI and ssh key. Additionally, in the code above you can see,
that the ec2 will have public ip (no matter what is the subnet setting), there
will be some tags for describing the new resource and only one entity will be
created.

When finish, run this playbook:

```
(ansible)$ AWS_PROFILE=ansible ansible-playbook -i environment/testing/ createec2.yml
```

And, if you see this:

```
PLAY [127.0.0.1] *******************************************************************************************************

TASK [Create new instance] *********************************************************************************************
changed: [127.0.0.1 -> localhost]

TASK [Waiting for SSH] *************************************************************************************************
ok: [127.0.0.1 -> localhost]

PLAY RECAP *************************************************************************************************************
127.0.0.1                  : ok=2    changed=1    unreachable=0    failed=0  
```

Run awscli command, and check the output:

```
(ansible)$ aws --profile ansible --region eu-west-1 ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`]| [0].Value]'
[
    [
        "i-09c05b24b4c0f9a79",
        "t2.micro",
        "52.123.45.678",
        "ansibletest"
    ]
]
```

__Congratulations!__ you successfully started your first EC2 instance using
Ansible!

You should be able to connect to your new instance

```
$ ssh -i ~/.ssh/ansibletutorial ubuntu@52.123.45.678
```

Now, do not forget to remove the instance :D

```
(ansible)$ aws --profile ansible --region eu-west-1 ec2 terminate-instances --instance-ids i-09c05b24b4c0f9a79
{
    "TerminatingInstances": [
        {
            "InstanceId": "i-09c05b24b4c0f9a79",
            "CurrentState": {
                "Code": 32,
                "Name": "shutting-down"
            },
            "PreviousState": {
                "Code": 16,
                "Name": "running"
            }
        }
    ]
}
```