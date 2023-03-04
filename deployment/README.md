This document describes some optional infrastructure helpers to simplify deployment of the node. 

---


## Deployment options and instructions

### Ubuntu (local)

### Docker 
> - Native
> - Terraform

### AWS native
To run a node on AWS, you will need to create an EC2 instance and configure the supporting resources including storage, networking, and security. Additional details are available in the AWS delployment directory, as well as Terraform templates to deploy your infrastructure.

#### *Prerequisites*
- AWS account
> - Admin user with access key and access password for CLU (best practice is to avoid using root).
>> - This account needs admin access to create resources but does not need Account Admin access.

## Reference

### Infrastructure as Code Tools
- [Get Terraform](https://github.com/hashicorp/terraform)
- [Get Docker](https://www.docker.com/)