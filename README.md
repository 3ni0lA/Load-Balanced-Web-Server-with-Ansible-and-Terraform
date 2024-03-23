# Multi-Instance Load Balanced Web Server with Ansible and Terraform
This project demonstrates the automated provisioning of a highly available web server infrastructure on AWS using Infrastructure as Code (IaC) tools: Terraform and Ansible.

# What it Does:

Creates three EC2 instances running Ubuntu 20.04. (You can modify the AMI in the Terraform code)
Configures an Elastic Load Balancer (ELB) to distribute traffic across the instances.
Sets up a custom domain name (replace 'yourdomain.com.ng' with your actual domain) with AWS Route53 and a subdomain ("terraform-test") pointing to the ELB.
Uses Ansible to connect to the instances (IP addresses obtained from Terraform), install Apache web server, configure the timezone to Africa/Lagos, and deploy a simple HTML page with unique content on each instance.

# Benefits:

Infrastructure as Code (IaC): Manages infrastructure in a repeatable and maintainable way.
High Availability: Load balancing ensures service remains available even if one instance fails.
Dynamic Inventory Management: Ansible uses the Terraform-generated file to automatically discover instances.
Simplified Deployment: Ansible automates web server configuration across all instances.

# Requirements:

AWS Account with appropriate permissions
Terraform installed (https://www.terraform.io/)
Ansible installed (https://www.ansible.com/products/automation-platform-x)
A registered domain name (.com.ng or any other TLD)


# How to Use:

Configure AWS Credentials: Set up AWS credentials for Terraform to access your AWS account.

Replace placeholders:

Update the ami property in Terraform code with the desired Ubuntu AMI ID if needed.
Replace yourdomain.com.ng in the Terraform code with your actual domain name.

Run Terraform:
Initialize Terraform: terraform init
Apply the infrastructure plan: terraform apply
This will create the resources and export public IP addresses to a file named host-inventory.

Run Ansible Playbook:
Ensure Ansible can access your AWS instances (e.g., security group rules).
Run the Ansible playbook: ansible-playbook playbook.yml
This will configure the web server with unique content on each instance.

# Accessing the Application:

Once Terraform and Ansible complete successfully, navigate to http://terraform-test.yourdomain.com.ng in your web browser. You should see a simple HTML page served by one of the instances. Refreshing the page may display content from a different instance due to load balancing.

# Additional Notes:

This is a basic example. You can customize the HTML content and Ansible tasks for your specific application needs.
Security best practices are not covered here. Make sure to implement proper security measures for your production environment.
For further details, refer to the Terraform (main.tf) and Ansible (playbook.yml) code files.

