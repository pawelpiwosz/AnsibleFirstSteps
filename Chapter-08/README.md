## Chapter 8
### Prepare AWS ready environment

So, it is time to start thinking, how to build your instance in AWS.  

#### Inventory

First, you need to create new environment structure. Let's name it testing.
So, now you should have:

```
environment
|
|- localenv
|- testing
```

Download two files to testing directory:
* https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py
* https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini

Those two files are responsible for connection to AWS and for which resources
you will be able to reach.

Right now you need to somehow run it. At first, add execute permission to
`ec2.py` file. I'm sure, you are aware of the content of `~/.aws/credentials`
file. So, let's make it somehow universal. Add to this file section:

```
[ansible]
aws_access_key_id = ACCESS_KEY
aws_secret_access_key = SECRET_KEY
```

This entry enables the possibility to create script which can be used by
everyone without changing profile name.

Other option is to export those values:

```
export AWS_ACCESS_KEY="ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="SECRET_KEY"
```

But personally I don't like this way. I prefer to use credentials file.

So, let's check if our config is able to connect to AWS (remember, your AWS
user has to have proper policies, and you need to have the virtualenv enabled!)

```
(ansible)$ ./ec2.py --profile ansible --list
```

Be prepared, the execution can take a while...

If the result will be similar to this:

```
{
  "_meta": {
    "hostvars": {}
  }
}
```

All is working as expected.

So... At last you can check your environments.

```
(ansible)$ ansible -i environment/localenv/ all --list-hosts
  hosts (1):
    mybox
```

for localenv, and:

```
(ansible)$ ansible -i environment/testing/ all --list-hosts
```

Oh, this didn't work, I suppose. If so, it is because of `profile`. Let's fix
it in the simplest, fastest, and... well, not the best way, by passing profile to
execution:

```
(ansible)$ AWS_PROFILE=ansible ansible environment/testing/ec2.py --list
 [WARNING]: provided hosts list is empty, only localhost is available. Note
 that the implicit localhost does not match
'all'

  hosts (0):
```

You should receive something similar to the output above. In this case there is
no resource in the AWS account, but the connection is working.

The example above shows how to use the environments: `-i <env_name>`. Some say,
there is a need to specify somewhere (I even don't remember where) the ec2.py
file, but it is not the truth. You need to specify only the directory, where
the inventory related files are located.

Last thing to prepare is to create vars structure. So, similar to `localenv`,
create `environment/testing/group_vars/tag_Purpose_nginx/`.

#### Create a Key Pair

Prepare a key pair for ssh to ec2. Run using AWS CLI:

```
$ aws ec2 create-key-pair --key-name ansibletutorial --query 'KeyMaterial' --output text > ~/.ssh/ansibletutorial.pem
```

In output you will receive all needed data. Change file permission to `440`.
Then load the key:

```
ssh-add ~/.ssh/ansibletutorial.pem
```
