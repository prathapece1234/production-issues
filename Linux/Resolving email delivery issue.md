**Production Incident: Resolving Email Delivery Failure Caused by Microsoft 365 DMARC Policy Enforcement**

## Overview

A production issue was reported where email notifications from the **ATT DR Site** were either delayed or not delivered to external recipients. 
Although the Linux mail server logs indicated that emails had been successfully handed over to Microsoft 365, recipients never received the messages.

Initial investigation suggested a mail relay or SMTP issue. However, a detailed analysis of mail server logs, Exchange Online message tracing, and 
email security policies revealed that the messages were being rejected due to **DMARC policy enforcement**.

After coordinating with the Microsoft 365 administration team and updating the mail security configuration to whitelist the DR site's public IP 
address, email delivery was restored successfully.

---

## Environment

| Component           | Details                          |
| ------------------- | -------------------------------- |
| Operating System    | Red Hat Enterprise Linux         |
| Mail Transfer Agent | Sendmail                         |
| Mail Platform       | Microsoft 365 (Exchange Online)  |
| Email Security      | Exchange Online Protection (EOP) |
| Environment         | Production                       |
| Source Server       | ATTDRMSPAPP2.att.com             |

---

## Problem Statement

The application team reported that email notifications generated from the **ATT DR Site** were either significantly delayed or not delivered.

The Linux mail logs showed that messages had been accepted by Microsoft 365, but recipients were not receiving them.

The objective was to determine where the messages were being stopped and restore reliable email delivery.

---

## Requirements

* Verify Linux mail server functionality.
* Confirm whether messages reached Microsoft 365.
* Identify whether the issue existed on the sender or receiver side.
* Determine whether Exchange Online security policies were blocking messages.
* Restore reliable mail delivery for the DR site.

---

## Investigation

### Step 1 – Verify Linux Mail Server

The investigation began by validating the Sendmail service on the application server.

Verified:

* Sendmail service status
* Mail queue
* SMTP connectivity
* Application mail logs

Reviewed mail logs:

```bash
tail -f /var/log/maillog
```

The logs showed that messages were accepted and forwarded successfully.

Example:

```text
stat=Sent
Queued mail for delivery
```

**Result**

* Sendmail service healthy.
* No mail queue backlog.
* SMTP relay completed successfully.
* Messages were accepted by Microsoft 365.

At this stage, the Linux mail server was ruled out as the source of the issue.

---

### Step 2 – Verify Message Delivery

Although the sender reported **"Sent"**, recipients did not receive the emails.

This suggested the issue existed after the messages reached Exchange Online.

A request was raised with the Microsoft 365 administration team to:

* Run a message trace.
* Check quarantine.
* Verify Exchange Online Protection (EOP).
* Review transport rules.
* Check sending limits.

---

### Step 3 – Exchange Online Analysis

The Exchange message trace confirmed that Microsoft 365 had received the messages but did not deliver them to the recipient mailbox.

Further analysis revealed the following rejection:

```text
550 5.7.509 Access denied,
sending domain ATTDRMSPAPP2.att.com
does not pass DMARC verification
and has a DMARC policy of reject
```

This confirmed that the issue was not related to Linux or SMTP connectivity.

The messages were being rejected during Microsoft 365 email security validation.

---

### Step 4 – Analyze Email Security

Compared the sending infrastructure with the configured email security policies.

Observed:

* Sendmail successfully relayed the message.
* Microsoft 365 accepted the SMTP session.
* DMARC verification failed during message processing.
* Exchange Online Protection rejected the message before mailbox delivery.

The issue affected all alert emails originating from the DR Site.

---

## Root Cause

The ATT DR Site public mail source was not trusted by the recipient's Microsoft 365 environment.

As a result:

* Messages successfully left the Linux mail server.
* Microsoft 365 received the messages.
* Exchange Online Protection evaluated the sender.
* DMARC validation failed.
* Microsoft 365 rejected the messages before delivery.

The problem was caused by email security policy enforcement rather than a Linux mail server or application issue.

---

## Resolution

Coordinated with the Microsoft 365 administration team.

Requested the public IP address used by the ATT DR Site mail server to be trusted.

Whitelisted:

```text
200.57.84.110
```

After updating the mail security configuration:

* Exchange Online accepted the sender.
* Messages passed policy evaluation.
* Email delivery resumed successfully.

---

## Validation

Performed end-to-end testing after implementing the change.

Verified:

* Sendmail reported successful delivery.
* Message trace completed successfully.
* Recipient mailbox received test emails.
* No delivery delays observed.
* Production alert emails were delivered normally.

---

## Outcome

* Successfully restored email delivery from the ATT DR Site.
* Confirmed Linux mail infrastructure was functioning correctly.
* Identified Microsoft 365 DMARC policy enforcement as the actual cause.
* Eliminated production alert delivery failures.
* Improved mail reliability through sender whitelisting.

---

## Root Cause Analysis (RCA)

| Component                  | Status                                             |
| -------------------------- | -------------------------------------------------- |
| Linux Server               | Healthy                                            |
| Sendmail                   | Healthy                                            |
| SMTP Relay                 | Successful                                         |
| Mail Queue                 | Normal                                             |
| Microsoft 365              | Received Message                                   |
| Exchange Online Protection | Rejected Message                                   |
| DMARC Validation           | Failed                                             |
| **Root Cause**             | Sender IP not trusted, causing DMARC/EOP rejection |

---

## Technologies Used

* Red Hat Enterprise Linux
* Sendmail
* SMTP
* Microsoft 365
* Exchange Online
* Exchange Online Protection (EOP)
* DMARC
* Message Trace
* Email Security
* Production Incident Management
* Root Cause Analysis

---

## Key Learning

A successful SMTP relay from a Linux mail server does not guarantee email delivery. Modern email platforms such as Microsoft 365 perform additional 
security checks, including SPF, DKIM, DMARC, and Exchange Online Protection policies, after accepting a message. By tracing the email path from the 
Linux mail server through Exchange Online and correlating mail logs with message trace results, the investigation accurately identified the 
rejection point. Coordinating with the email security team to trust the authorized sending IP restored reliable delivery without modifying the Linux 
mail infrastructure.

---

