# Configuring Linux Email Notifications using Amazon SES (SMTP Relay & IAM Role)

## Overview

Configured email notification services on multiple Linux servers to enable automated alerts from monitoring scripts and applications. 
Depending on the project requirements and server architecture, two different Amazon SES integration methods were implemented:

* **Method 1:** Sendmail configured with Amazon SES SMTP Relay using SMTP authentication.
* **Method 2:** Amazon SES integration using an EC2 IAM Role and AWS CLI without storing SMTP credentials or AWS access keys.

Both implementations were validated successfully by sending test emails and confirming reliable email delivery.

---

# Environment

| Component           | Details                           |
| ------------------- | --------------------------------- |
| Cloud Platform      | Amazon Web Services (AWS)         |
| Email Service       | Amazon Simple Email Service (SES) |
| Operating System    | Red Hat Enterprise Linux          |
| Mail Transfer Agent | Sendmail                          |
| Mail Utility        | AWS CLI                           |
| Authentication      | SMTP Credentials / IAM Role       |
| Verified Domain     | beonemobile.com.my                |

---

# Servers Configured

* Jump Server
* APP1
* APP2
* CDR Recon 1
* BKP/CDR1
* PostgreSQL
* Oracle 1

---

# Implementation Approach

Depending on the application architecture and security requirements, two different implementation methods were used.

---

# Method 1 – Sendmail with Amazon SES SMTP Relay

### Overview

Configured Sendmail to relay outbound emails through the Amazon SES SMTP endpoint using authenticated SMTP connections with TLS 
encryption.

### Install Required Packages

```bash
dnf install sendmail sendmail-cf mailx m4 -y
```

### Configure Sendmail

Configured:

* Amazon SES SMTP endpoint
* SMTP Authentication
* TLS Encryption
* Smart Host

Example configuration:

```text
SMART_HOST(`email-smtp.<aws-region>.amazonaws.com')
FEATURE(`authinfo')
```

Configured authentication:

```text
AuthInfo:email-smtp.<aws-region>.amazonaws.com \
"U:SMTP_USERNAME" \
"I:SMTP_USERNAME" \
"P:SMTP_PASSWORD"
```

Generate configuration:

```bash
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
```

Create authentication database:

```bash
makemap hash /etc/mail/authinfo.db < /etc/mail/authinfo
```

Enable service:

```bash
systemctl enable sendmail
systemctl restart sendmail
```

Verify:

```bash
systemctl status sendmail
```

Test mail:

```bash
echo "Amazon SES Mail Test" | mail -s "SES SMTP Test" admin@example.com
```

---

# Method 2 – Amazon SES using EC2 IAM Role

### Overview

For some application servers, instead of configuring Sendmail and SMTP authentication, Amazon SES was integrated directly using the AWS 
CLI. The EC2 instances were configured with an IAM Role that granted permission to send emails through Amazon SES. This eliminated the 
need to store SMTP credentials or AWS access keys on the servers.

---

## Verify IAM Authentication

Verify the attached IAM Role.

```bash
aws sts get-caller-identity
```

Check the IAM Role assigned to the EC2 instance.

```bash
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

Verify AWS CLI configuration.

```bash
aws configure list
```

---

## Send Test Email

```bash
aws ses send-email \
--from no-reply@xxxxx.com \
--destination "ToAddresses=prathaps8675@gmail.com" \
--message "Subject={Data=SES CLI Test},Body={Text={Data=CLI is working}}" \
--region ap-southeast-5
```

Expected output:

```json
{
  "MessageId": "010xxxxxxxxxxxxxxxxxxxxxxxx"
}
```

The same command was integrated into application and monitoring scripts to generate automated email alerts.

---

# Validation

Performed end-to-end validation after configuration.

Verified:

* Sendmail service status (SMTP Relay implementation)
* Amazon SES authentication
* IAM Role permissions (IAM implementation)
* SMTP connectivity
* AWS CLI connectivity
* Monitoring scripts successfully generated email alerts
* Test emails were delivered successfully
* No authentication or relay errors observed

---

# Outcome

* Successfully configured Amazon SES for outbound email notifications across multiple Linux servers.
* Implemented both SMTP Relay and IAM Role–based integrations depending on project requirements.
* Enabled automated email alerts for monitoring scripts and applications.
* Eliminated the need for local mail servers by leveraging Amazon SES.
* Used IAM Role–based authentication where applicable, avoiding storage of AWS access keys or SMTP credentials on EC2 instances.
* Successfully validated email delivery from all configured servers.

---

# Technologies Used

* Amazon Web Services (AWS)
* Amazon Simple Email Service (SES)
* AWS CLI
* IAM Roles
* Sendmail
* Mailx
* SMTP Relay
* TLS
* Red Hat Enterprise Linux

---

# Key Learning

This project provided experience implementing **multiple Amazon SES integration methods** based on infrastructure requirements.

* **SMTP Relay with Sendmail** is suitable for legacy applications and scripts that rely on a local Mail Transfer Agent.
* **IAM Role with AWS CLI** is the preferred AWS-native approach for EC2 instances, as it removes the need to store long-lived 
credentials while simplifying secure email delivery.

Understanding both approaches allows the selection of the most appropriate solution depending on application architecture, security 
requirements, and operational practices.
