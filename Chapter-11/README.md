## Chapter 11
### More customization!

The playbook is already customized, but how about different availability zone?

Let's prepare vars.yml file for this and a few similar cases. This time, you
will create the dictionary, what is a flexible and easy to expand way of
generating "maps" of variables.

The new vars.yml should look like this:

```
---
# Environment name
ec2_environment: "testing"

# ec2 specific variable
ec2_map:
  eu-west-1:
    ec2_ami_id: "ami-08d658f84a6d84a80"
    ec2_sg: "<security group id>"
    eu-west-1a:
      ec2_subnet: "<VPC Subnet1 ID>"
    eu-west-1b:
      ec2_subnet: "<VPC Subnet2 ID>"
ec2_type: "t2.micro"
ec2_keyname: "ansibletutorial"
ec2_name: "ansibletest"
```

Now it is time to change the task:

```
    - name: Create new instance
      local_action:
        module: ec2
        region: "{{ec2_region}}"
        vpc_subnet_id: "{{ec2_map[ec2_region][ec2_zone]['ec2_subnet']}}"
        #vpc_subnet_id: "{{ec2_subnet}}"
        assign_public_ip: "yes"
        instance_type: "{{ec2_type}}"
        image: "{{ec2_map[ec2_region]['ec2_ami_id']}}"
        #image: "{{ec2_ami_id}}"
        group_id: "{{ec2_map[ec2_region]['ec2_sg']}}"
        #group_id: "{{ec2_sg}}"
        key_name: "{{ec2_keyname}}"
        count: 1
        wait: yes
        instance_tags:
          Name: "{{ec2_name}}"
          Environment: "{{ec2_environment}}"
          Purpose: "nginx"
          Provisioned: "Ansible"
      register: new_instance
```

Let's create two instances, in two availability zones:

```
(ansible)$ AWS_PROFILE=ansible ansible-playbook -i environment/testing/ createec2.yml \
 -e ec2_name="ansibletest1" -e ec2_region="eu-west-1" -e ec2_zone="eu-west-1a" \
 -e ec2_environment="testing"

 (ansible)$ AWS_PROFILE=ansible ansible-playbook -i environment/testing/ createec2.yml \
  -e ec2_name="ansibletest2" -e ec2_region="eu-west-1" -e ec2_zone="eu-west-1b" \
  -e ec2_environment="testing"
```


And now check the results:

```
$ aws --profile ansible --region eu-west-1 ec2 describe-instances --query \
'Reservations[].Instances[].[InstanceId,InstanceType,PublicIpAddress,SubnetId,Tags[?Key==`Name`]| [0].Value]' \
--output table
------------------------------------------------------------------------------------------
|                                    DescribeInstances                                   |
+----------------------+-----------+-----------------+------------------+----------------+
|  i-0a562f07f354bdacb |  t2.micro |  54.123.456.78  |  subnet-827233e6 |  ansibletest1  |
|  i-0e55d372a5a77fb6a |  t2.micro |  34.876.543.21  |  subnet-e3a2dd95 |  ansibletest2  |
+----------------------+-----------+-----------------+------------------+----------------+
```

As you can see, ec2 instances were created in different zones. Yes, this
approach forced you to add a lot of variables in command line, but don't worry,
we will handle it later.

And again, do not forget to remove your resources.
