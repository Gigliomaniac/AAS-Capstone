# AAS-Capstone
A proof-of-concept. Not production ready.  It was created for academic demonstration and portfolio purposes.
# Cloud Lab Automation Platform (Capstone Project)

## Overview
This project is a proof-of-concept platform that automates the provisioning of cloud lab environments on AWS.  
It integrates a Python API with Terraform infrastructure as code (IaC) to create and tear down isolated environments for training and experimentation.  

## Features
- **API-Driven Workflow:** Python (`apiREAL.py`) triggers Terraform deployments on demand.  
- **Infrastructure as Code:** AWS resources defined and deployed through Terraform modules.  
- **Secure State Management:** Remote backend with S3 (and optional DynamoDB for state locking).  
- **Role-Based Access:** IAM configuration for ephemeral users and restricted permissions.    
- **Documentation & Testing:** Includes data-flow diagram (DFD), test logs, and user guides.  


**High-Level Flow:**
1. User/API request triggers lab creation.  
2. API calls Terraform to apply infrastructure templates.  
3. Terraform provisions AWS resources (VPC, EC2, IAM, S3, etc.).  
4. Ephemeral user credentials are returned for lab access.  
5. After a defined period, lab resources are destroyed and cleaned up.  

## Getting Started
> ⚠️ **Note:** This is a proof-of-concept project, not production-ready. It was created for academic demonstration and portfolio purposes. Many and more items are in need of refinement to function at the level imagined.

### Prerequisites
- AWS account (Free Tier or sandbox recommended)  
- Terraform (v1.9+) installed  
- Python 3.9+  

