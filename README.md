# Sec VPC

🔐 Secure VPC for personal needs. Helps you create your own VPN server in a separate VPC in a few simple steps. 

🏗 Like [Crash CDK] (https://github.com/hex22a/crash-cdk) but in [Terraform](https://www.terraform.io/)!

💸 Suits for [AWS Free Tier](https://aws.amazon.com/free/) instances

☀️ Fast, but verbose setup

👯‍ Mostly copy-pasting 

💥 Easy to destroy

## Pre-requirements

🚜 Tarraform. [tfswitch](https://github.com/warrensbox/terraform-switcher) is recomended to manage Terraform versions

🧾 [AWS](https://aws.amazon.com/) Account

🚜 [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

🔌 [EC2 Instance Connect CLI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html#ec2-instance-connect-install-eic-CLI)

🤖 [IAM User](https://console.aws.amazon.com/iam/home#/users) with following policies:

1. [AmazonEC2FullAccess](https://console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/AmazonEC2FullAccess$serviceLevelSummary)

3. [EC2InstanceConnect](https://console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/EC2InstanceConnect$serviceLevelSummary)

💭 **Important**: Create a separate user instead of using default sudo-level access.

💭 **Important 2**: Best practice is to attach permissions to a [group](https://console.aws.amazon.com/iam/home#/groups) and then add users to that group, rather than giving permissions to user directly. In this particular case there's not much difference, so you can do either.

## Configure AWS CLI

```bash
aws configure
```

The tool will prompt for an IAM credentials. Fill in ones, created before.

## Deploy

```bash
# Make sure you're on correct version of terraform
tfswich

# Init terraform state
terraform init

# Plan your infra
terraform plan

# Deploy
tarraform apply
```

## Get the admin password

If you properly setup [EC2InstanceConnect](https://console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/EC2InstanceConnect$serviceLevelSummary) you should be able to SSH into the instance throuh AWS Console.

```bash
# One you connected to the instance output the content of /usr/local/openvpn_as/init.log and look for openvpn default superuser password
cat /usr/local/openvpn_as/init.log
```

💭 **Important 3**
__Don't forget to change your admin password after first login!__

Instance configuration is complete 🎉

## Set up VPN

### Server

Log in as  `openvpn` user at `https://PUBLIC_IP:943/admin`. Ignore SSL warning, or add SSL Cert as trusted to the keychain. You can find your public ip in [AWS Console](https://console.aws.amazon.com/). To bypass Google Chrome's "Not Secure" warning, just type in "thisisunsafe" while the tab is open. 

Update __Hostname or IP Address__ at __Network Settings__ (https://PUBLIC_IP:943/admin/network_settings). Value in the field should be your PUBLIC_IP.

Create 👩‍💻 VPN users, click "More Settings" to set password, enable auto-login

__Don't forget to "Update Running Server"__

### Client

Login as a 👩‍💻 VPN user [https://PUBLIC_IP:943/?src=connect](https://PUBLIC_IP:943/?src=connect)

Download client app if you haven't yet

Click `Yourself (autologin profile)` to download `client.ovpn` file. Use this file to establish your custom VPN connection.

## 🚨 Destroy

```bash
terraform destroy
```

## Troubleshooting

```
Unrecognized option or missing or extra parameter(s) in configuration: (line 4): dhcp-pre-release (2.4.4)
``` 

If you're configuring WiFi router with `.ovpn` autologin profile like above, try adding following lines to the `.ovpn` file in your favorite text editor

```
## Add this right after comments block, just for better arrangemnt
pull-filter ignore "dhcp-pre-release"
pull-filter ignore "dhcp-renew"
pull-filter ignore "dhcp-release"
pull-filter ignore "register-dns"
pull-filter ignore "block-ipv6"
```

