
Stratus Sagathians
A cloud-based lab deployment system that launches isolated environments via a simple API call, backed by Terraform and Python automation. Designed for educational scalability and ease of use.
🚀 Quick Start
Prerequisites
•	EC2 instance with required Terraform and Python setup
•	.pem key for RDP access
•	Visual Studio Code (or terminal access)
•	Python installed
Instructions
1.	Start your EC2 instance and obtain its public IP.
2.	RDP into the instance using the .pem key.
3.	Open Visual Studio Code and launch a Bash terminal.
4.	Navigate to the project folder and run:
bash
CopyEdit
python apiREAL.py
5.	In another Bash terminal, test lab creation via:
bash
CopyEdit
curl -X POST http://<EC2_PUBLIC_IP>:5000/create-lab
________________________________________
📁 Directory Map
python
CopyEdit
.
├── apiREAL.py                        # Python API server to trigger lab creation
├── main.tf.txt / maintest.tf.txt    # Experimental Terraform configurations (not used in final deployment)
├── s3_and_security_group.tf         # Terraform config for S3 backend and security group setup
├── terraform.tfstate*               # Terraform state tracking
├── vpc_and_security_configurations.tf # Terraform VPC, NACL, and Security Group configurations
├── .terraform/                      # Terraform provider binaries (auto-generated)
└── firstsetup/
    ├── backend.tf                   # S3 backend configuration for remote Terraform state
    ├── IAM.tf                       # IAM roles, users, and permissions for lab users
    ├── locals.tf                    # Local values used across Terraform config
    ├── resources.tf                 # Main resource definitions for lab environments
    ├── variables.tf                 # Input variable declarations
    ├── lab_activity.log             # Custom log file for tracking lab creation
    └── .terraform/                  # Provider binaries and Terraform state for `firstsetup`

Tests
ID	DB01
Feature Tested	The user logs in and is directed to the right interface.
Input	Make test user data and try to log in with said data.
Expected Result	Pass. The user should be able to login without having issues.
Pass/Fail	Fail.
Result	The user was not able to log in and the application output errors. 

ID	DB02
Feature Tested	Usability for application login.

Input	Using it to see if there is anything that could lead to frustration on the user’s side.
Expected Result	Pass. 
Pass/Fail	Fail  It seems fine, but I must test it more when the login works.
Result	The interface is simple but needs to function.

ID	DB03
Feature Tested	Front-end validation.

Input	Trying to sign in without a requirement.
Expected Result	Pass. It is implanted while coding so it should work as intended and be noticed right away.
Pass/Fail	Pass.
Result	The user got messages from the application saying what needed to be submitted.

ID	TPLSD01
Feature Tested	Production of lab infrastructure. Anticipate infrastructure to be readily available and correctly assembled as per coded instruction.

Input	Run Terraform apply and confirm in AWS console everything listed was produced as instructed. 
Expected Result	Fail – there were 41 resources at the time of test. Anticipated many coding errors in resource production as many dynamic generated items were being referenced simultaneously. Anticipate many instances of plan/apply commands being rejected on this premise.
Pass/Fail	Pass.
Result	Seems that referencing resources by name is exactly all that’s required for a computer to identify what’s required to attach it to, regardless of dynamic aspects.

ID	TPLSD02
Feature Tested	Destruction of lab infrastructure. Anticipate infrastructure to be destroyed on demand, including generated files.

Input	Run Terraform destroy and confirm in AWS console.
Expected Result	Pass. It’s intuitive that all which is easily created by Terraform can be destroyed by it.
Pass/Fail	Fail.
Result	Generated files for user login credentials using local exec do not get stored in state.

ID	TPLSD025
Feature Tested	Destruction of lab infrastructure. Anticipate infrastructure to be destroyed on demand, including generated files.

Input	Run Terraform destroy and confirm visually in AWS console.
Expected Result	Fail. We were unsure which items to use to ensure file destruction.
Pass/Fail	Pass.
Result	Generated files for user login credentials using local exec does not get stored in state for future use but can be destroyed by another local exec with a “depends on” clause.

ID	TPLSD03
Feature Tested	Confirm the infrastructure the prototype lab produces is solvable with the exact instructions given for the ephemeral lab user.
Input	Run Terraform code, access AWS console through ephemeral user login and admin access, then run through lab to completion
Expected Result	Pass
Pass/Fail	Fail. Realized I did not know how to complete the lab I had created.
Result	Misconfigured items and ignorance resulted in a need to reestablish understanding of lab again.

ID	TPLSD035
Feature Tested	Confirm the infrastructure the prototype lab produces is solvable with the exact instructions given for the ephemeral lab user.
Input	Run Terraform code, access AWS console through ephemeral user login and admin access, then run through lab to completion
Expected Result	Pass
Pass/Fail	Pass. Completed lab from beginning to end with both access areas.
Result	Items reconfigured. Completed lab from beginning to end with both access areas.

ID	TPLSD04
Feature Tested	Confirming dynamically named resources can be reliably called for associations within code.
Input	Running Terraform code, confirming terminal does not result in errors or once complete, infrastructure is as intended; named and all related resources attached accurately.
Expected Result	Fail. It appeared complex and I was unsure if resources could attach appropriately.
Pass/Fail	Pass.
Result	Running the code was easier than I believed. Appears referencing resources by name, even in an array or count successfully attaches to all resources under the name.

ID	TPLSD05
Feature Tested	* Successful creation of a terraform state backend to reference and return to when resources are created by lab users rather than terraform files. *
Input	Not yet completed.
Expected Result	Initial failure before pass. I imagine difficulty implementing this feature.
Pass/Fail	N/A – incomplete testing.
Result	N/A – incomplete implementation and testing.


ID	TPSLE01
Feature Tested	There must be a starting point for the lab recreation, and that will be with the VPC as it is the easiest resource to make out of this group, due to only needing one VPC. 

Input	Use Terraform to code a VPC in a region, clarify that Terraform has deployed the resources in AWS.
Expected Results	Pass. Simple to code, not much required as there isn’t anything integrated with it yet.
Pass/Fail	Pass
Result	The VPC was created which allowed the first step to starting the recreation of a Plural sight lab that we can use in our own application. 


ID	TPSLE02
Feature Tested	Following the VPC, there needed to be subnets to have access to the VPC. Both public and private access.
Input	This is the first run with subnets which use count as I need three subnets (one public and two private) in us-east-1a and three subnets (one public and two private) in us-east-1b.
Expected Results	Pass. Once again it was near the start so there wasn’t a whole lot integrated yet that could potentially break. 
Pass/Fail	Fail
Result	The result worked for what it was at the time, however when adding in IGW and NGW was when I realized that this wasn’t the solution for what was required.




ID	TPSLE025
Feature Tested	Following the VPC, there needed to be subnets to have access to the VPC. Both public and private access.
Input	This is the second run with subnets where I ended up using local so I could define each subnet and call them for the route tables, IGW, and NGW.
Expected Results	Pass. It is the second attempt to make the subnets connect to the needed resources.
Pass/Fail	Pass
Result	It ended up working and provided me with an insight into how focusing on one resource at a time could cause potential compatibility issues with future resources.


ID	TPSLE03
Feature Tested	Public and Private Route table
Input	Creating a public route table using the previously created subnets as well as the private route table that used the private subnets.
Expected Results	Pass. To have public and private subnets connected to their respective route tables.
Pass/Fail	Fail
Result	This is where I could physically see that my flow log for the VPC wasn’t following the lab as I had intended. 


ID	TPSLE04
Feature Tested	Public and Private Route table
Input	Recreating the route tables that were made to fit with the new subnet layout.
Expected Results	The route tables are connected to the subnets which can then be used for the IGW and the NGW that will be created next.
Pass/Fail	Pass
Result	Public and Private route tables are now associated with the current subnets that are being used.


ID	TPSLE05
Feature Tested	Internet Gateway
Input	Utilizing the public route table that was created to link the public subnets with public internet access.
Expected Results	After creating the new route tables and subnets, it will be easier to call the resources in an IGW.
Pass/Fail	Pass
Result	They were able to connect properly, and you could see how they flowed into each other via the VPC flow log.


ID	TPSLE06
Feature Tested	Nat Gateway
Input	Utilize the private subnets and the private route table that is associated with them to provide a private access point. Also created the elastic IP with the NGW.
Expected Results	Pass. The NAT gateway worked as intended and they are close to having a similar function but for private instead of public.
Pass/Fail	Pass
Result	The lab now has access to those private subnets without having them be available to anyone and everyone.


ID	TPSLE07
Feature Tested	Network Access Control List
Input	Creating the inbound and outbound rules for the previously created subnets. 
Expected Results	Pass. The rules are well laid out when looking at them in the lab; it was just the time requirement to make them. 
Pass/Fail	Pass
Result	All the inbound and outbound rules have been created for the public and private subnets. 


ID	TPSLE08
Feature Tested	EC2 Instances
Input	Ensuring that there is an EC2 instance created in us-east-1a and us-east-1b.
Expected Results	Pass. They are similar in design, just a slightly different region. 
Pass/Fail	Pass
Result	Both EC2 instances are up and running as intended when the lab is deployed. 


ID	TPSLE09
Feature Tested	Security Groups
Input	Creating inbound and outbound rules with security groups for the instances themselves. 
Expected Results	Pass. Found their creation similar to creating NACL, a bit repetitive with slight changes here and there.
Pass/Fail	Pass
Result	Security groups were created to control the inbound and outbound rules. 


ID	TPSLE10
Feature Tested	Elastic Block Storage and Auto Scaling Group
Input	Allows there to be storage for instances as well as the ability to scale up or down if ever needed.
Expected Results	Fail. I tested these two at the same time and haven’t created resources like before.
Pass/Fail	Pass
Result	Elastic block storage is now available for both EC2 instances and they both have scalability. 

ID	EI01
Feature Tested	Cron job for auto destruction of lab infrastructure and lab user with their credentials – basis of the ephemeral aspect of user/credentials. Anticipate after a set amount of time the automated destruction of infrastructure and user/credentials.
Input	Placed in the API call script to produce the prototype lab and ephemeral user. Ran API call against running terminal. Waited specified time of five minutes and returned. Used AWS console and VSC to confirm results.
Expected Result	Fail. Never introduced to API calls in depth, studied very briefly, asked a veteran software developer for an explanation as general online documentation presented jargon-heavy information that was unintuitive and potentially nondescriptive of true function.
Pass/Fail	Pass.
Result	API call and cron job worked as intended. Watched infrastructure be correctly produced and automatically spun down five minutes later.

ID	EI02
Feature Tested	Making sure the python script that runs against the code deployed in the relevant directory can handle base deployment task.
Input	Run the file on the local machine. Call from another terminal, wait for infrastructure to run. Confirm on AWS console.
Expected Result	Fail. Anticipate ignorance on the matter to lead to flask/API management failure.
Pass/Fail	Pass
Result	Unexpectedly, running python script and call against it in alternate terminal performed exactly as desired. Confirmation in AWS console.

ID	EI03
Feature Tested	Confirm the python script can handle additional tasks on the local machine; Cron job for automatic tear down, log successful deployment or failure to deploy messages to "lab_activity.log.".
Input	Run the file on the local machine. Call from another terminal, once infrastructure is deployed, confirm automatic tear down of resources and activity log was updated with success or failure.
Expected Result	Pass. Previous tests on infrastructure startup gave confidence in additions of function.
Pass/Fail	Pass.
Result	After the python script was run activity log was updated successfully. Resources were torn down after five minutes, the specified time in the script.

ID	EI04
Feature Tested	*Ensuring the EC2 that hosts this API functionality can only be sent calls from a specific IP address. *
Input	Send requests from device hosting the database and devices associated with admin credentials.
Expected Result	Pass. Configuring AWS security services might be a bit of a tangle to start, but the process is well established in documentation and basic to the discipline.
Pass/Fail	N/A – not yet complete
Result	N/A – not yet complete


ID	IAM01
Feature Tested	Dynamic creation of ephemeral lab user, credentials, and associated IAM policy. Anticipate successful creation of user – able to log in after generation and see relevant resources only.

Input	Run Terraform apply and wait for users and lab to be generated. Once complete, log in using user credentials and view available resources. Simultaneously, view from admin accesses the creation of everything to compare.
Expected Result	Pass. Expect user to see relevant resources and be able to configure/add them as IAM policy specifies. 
Pass/Fail	Fail.
Result	User was successfully generated, IAM was not successfully attached. While code was present to generate an IAM and attach it to the dynamically generated user, it did not attach, while a default policy was placed instead.

ID	IAM015
Feature Tested	Dynamic creation of ephemeral lab user, credentials, and associated IAM policy. Anticipate successful creation of user – able to log in after generation and see relevant resources only.

Input	Run Terraform apply and wait for users and lab to be generated. Once complete, log in using user credentials and view available resources. Simultaneously, view from admin accesses the creation of everything to compare.
Expected Result	Pass. Expect user to see relevant resources and be able to configure/add them as IAM policy specifies. 
Pass/Fail	Pass.
Result	Code that was active to attach the policy was on the same level of runtime as the user generation. Required a depends on clause to have the command run after the user was generated so the script could see what was made before trying to attach policy to it.

ID	IAM02
Feature Tested	Associate reductive IAM access credentials under the principles of least privilege. Ensure the policies that are attached will prevent the user from having sight and access to services that could damage the company-owned infrastructure. (This still needs work.)
Input	Design IAM JSON code that allows generated users to only interact with resources specified in the lab. Once code runs, confirm user access in AWS console after login with their credentials.
Expected Result	Fail
Pass/Fail	Fail
Result	Initial confirmation allowed users to access everything rather than what was intended.

ID	IAM025
Feature Tested	Associate reductive IAM access credentials under the principles of least privilege. Ensure the policies that are attached will prevent the user from having sight and access to services that could damage the company-owned infrastructure. (This still needs work.)
Input	Design IAM JSON code that allows generated users to only interact with resources specified in the lab. Once code runs, confirm user access in AWS console after login with their credentials.
Expected Result	Fail
Pass/Fail	Pass, but not to the full extent.
Result	While users can only interact with resource types that are specified in the code, they aren’t restricted to only resources created by the code. Tag implementation is required. 

ID	IAM03
Feature Tested	Generation of the credentials the ephemeral user will log in with and sourcing them to a file location for future references.
Input	Input local executor to code, run Terraform code, confirm credentials and login site are placed into separate file.
Expected Result	Pass.
Pass/Fail	Fail. 
Result	Turns out, the local executor is very fragile and can require multiple languages of command to function for compiling tasks. Multiple instances of failure, including desynchronized retrieval of generated user secrets.

ID	IAM03
Feature Tested	Generation of the credentials the ephemeral user will log in with and sourcing them to a file location for future references.
Input	Input local executor to code, run Terraform code, confirm credentials and login site are placed into separate file.
Expected Result	Pass.
Pass/Fail	Pass.
Result	After many iterations login credentials managed to be compiled in the appropriate file.

ID	IAM04
Feature Tested	Deletion of ephemeral user secret (login password) supersedes deletion restrictions AWS has in place to prevent account secret clog.
Input	Input Terraform script an attempt at deleting secrets with the rest of the infrastructure, run Terraform apply, then destroy and confirm on AWS console.
Expected Result	Fail. Normally when rules are in place with unique gimmicks like “wait a certain amount of time”, trying to get around them requires ownership or accesses only the company has rights to.
Pass/Fail	Pass.
Result	Running Terraform destroy accurately deletes the secret along with the user. 

ID	GH01
Feature Tested	Allocation and privacy of repository.
Input	Initial setup of repository on GitHub and login onto my local machine to upload files as needed. Making sure the repository is set to private.
Expected Result	Pass. It’s just setting up one more service in the long list of other services.
Pass/Fail	Pass. 
Result	Setting up GitHub and using it privately, including adding collaborators with distinct permissions went smoothly. 

ID	GH02
Feature Tested	Consolidation and organization of file structure for ease of future lab uploads.
Input	It has not been completed. I will first have to fragment my Terraform files appropriately before upload.
Expected Result	Fail.
Pass/Fail	N/A – remains incomplete
Result	N/A – remains incomplete
