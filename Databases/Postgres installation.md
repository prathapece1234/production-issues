# **PostgreSQL 16 Installation and Initial Configuration on RHEL Server**

## Overview

A request was received to install **PostgreSQL 16** on a Linux server and perform the necessary initial configuration to make the database server 
ready for client connections.

The installation included PostgreSQL package deployment, database initialization, service configuration, network access configuration, client 
authentication updates, and creation of database credentials for the application team.

---

## Request Details

| Parameter        | Value                    |
| ---------------- | ------------------------ |
| Server           | 192.168.149.6            |
| Operating System | Red Hat Enterprise Linux |
| Software         | PostgreSQL               |
| Required Version | PostgreSQL 16 or above   |

---

## Requirements

* Install PostgreSQL 16.
* Initialize the database cluster.
* Configure PostgreSQL service.
* Enable remote client connectivity.
* Update authentication rules.
* Share database access credentials with the application team.

---

## Implementation

### Install PostgreSQL 16

Installed PostgreSQL 16 server and client packages.

```bash
dnf install postgresql16-server postgresql16 -y
```

---

### Initialize the Database

Initialized the PostgreSQL database cluster.

```bash
/usr/pgsql-16/bin/postgresql-16-setup initdb
```

---

### Enable and Start PostgreSQL

Started the PostgreSQL service and configured it to start automatically after reboot.

```bash
systemctl enable postgresql-16
systemctl start postgresql-16
```

Verified the service status.

```bash
systemctl status postgresql-16
```

---

### Configure Remote Connections

Updated the PostgreSQL configuration file.

Modified **postgresql.conf** to allow remote client connections.

```text
listen_addresses = '*'
```

---

### Configure Client Authentication

Updated **pg_hba.conf** to allow client authentication from the required network.

Example:

```text
host    all    all    0.0.0.0/0    md5
```

*(Configured according to the project/network requirements.)*

---

### Create Database User

reset the password and assigned a secure password.

---

## Validation

Verified that PostgreSQL was listening on the default port.

```bash
ss -tulnp | grep 5432
```

Confirmed PostgreSQL service status.

```bash
systemctl status postgresql-16
```

Verified client connectivity using the newly created database user.

Confirmed successful authentication and database access.

---

## Outcome

* Successfully installed PostgreSQL 16.
* Initialized the database cluster.
* Enabled and started the PostgreSQL service.
* Configured PostgreSQL to accept remote connections.
* Updated `pg_hba.conf` for client authentication.
* Created the required database user.
* Shared the database username and password securely with the application team.
* Validated successful database connectivity.

---

## Technologies Used

* Red Hat Enterprise Linux
* PostgreSQL 16
* Systemd
* Linux Networking
* Database Administration

---

## Key Learning

A PostgreSQL installation involves more than package deployment. Proper post-installation configuration—such as enabling remote connections 
(`listen_addresses`), configuring client authentication (`pg_hba.conf`), creating database users, and validating connectivity—is essential to 
ensure the database is secure, accessible, and ready for application deployment.
