## Incident Summary

A production user reported that they were unable to connect to the PostgreSQL database from the application. Since the database is a critical 
backend service, immediate investigation was initiated to determine whether the issue was caused by the PostgreSQL service, network connectivity, 
firewall configuration, or database access controls.

---

# User Report

```text
We are currently unable to connect to the PostgreSQL database.
Kindly please check the issue.
```

---

# Severity

**High** – Application users were unable to establish a connection to the PostgreSQL database.

---

# Initial Investigation

Verified that the PostgreSQL virtual machine was accessible.

```bash
ping <postgres-server>
ssh <postgres-server>
```

Confirmed that the server was reachable and there were no operating system issues.
---

# Step 1 – Verify PostgreSQL Service

Checked whether the PostgreSQL service was running.

```bash
systemctl status postgresql
systemctl status postgresql-16
```

Verified that the PostgreSQL service was active and running normally.

---

# Step 2 – Verify Listening Port

Checked whether PostgreSQL was listening on port **5432**.

```bash
ss -tulnp | grep 5432
```

Confirmed that PostgreSQL was listening on the required interface and accepting incoming connections.

Example:

```text
LISTEN 0 244 *:5432
```
---

# Step 3 – Verify Network Connectivity

Verified that the database port was reachable.

```bash
telnet <postgres-server> 5432
nc -zv <postgres-server> 5432
```

Confirmed that the PostgreSQL port was accessible from the client.
---

# Step 4 – Verify Linux Firewall

Checked firewall rules on the PostgreSQL server.

```bash
firewall-cmd --list-all
firewall-cmd --list-ports
iptables -L -n
```

Confirmed that port **5432** was allowed through the Linux firewall.

---

# Step 5 – Verify PostgreSQL Configuration

Verified that PostgreSQL was configured to accept remote connections.

Checked `postgresql.conf`.

```bash
grep listen_addresses postgresql.conf
```

Confirmed that PostgreSQL was listening on the required network interface.

Example:

```text
listen_addresses='*'
```

---

# Step 6 – Verify pg_hba.conf

Validated PostgreSQL client authentication rules.

```bash
cat pg_hba.conf
```

Verified that the client network and authentication method were correctly configured.

Example:

```text
host    all    all    <application-network>/24    md5
```

If the required client entry was missing, the appropriate `pg_hba.conf` rule was added and PostgreSQL configuration was reloaded.

```bash
systemctl reload postgresql
```
---

# Step 7 – Verify Database Connectivity

Tested database connectivity locally.

```bash
psql -U postgres
```

Verified application connectivity using the application database account.

```bash
psql -h localhost -U <application-user> -d <database-name>
```

Confirmed that authentication and database access were successful.

---

# Root Cause

The investigation focused on the following possible causes:

* PostgreSQL service unavailable.
* PostgreSQL not listening on port **5432**.
* Linux firewall blocking database traffic.
* Missing or incorrect `pg_hba.conf` client authentication entry.
* Incorrect PostgreSQL configuration preventing remote connections.

The identified issue was corrected, and database connectivity was successfully restored.

---

# Resolution

* Verified PostgreSQL service health.
* Confirmed that PostgreSQL was listening on port **5432**.
* Validated Linux firewall configuration.
* Corrected the required `pg_hba.conf` entry where necessary.
* Reloaded PostgreSQL configuration.
* Successfully verified client connectivity.

---

# Validation

Verified database connectivity after implementing the fix.

```bash
systemctl status postgresql
ss -tulnp | grep 5432
psql -U postgres
psql -h localhost -U <application-user> -d <database-name>
```

Confirmed:

* PostgreSQL service running successfully.
* Port **5432** listening.
* Firewall allowing database traffic.
* Client authentication functioning correctly.
* Application successfully connected to the PostgreSQL database.

---

# Business Impact

* Restored application connectivity to the production PostgreSQL database.
* Minimized application downtime through systematic troubleshooting.
* Verified all layers of the database stack, including service status, network, firewall, and authentication configuration.
* Reduced future troubleshooting time by following a structured incident response process.

---

# Technologies Used

* PostgreSQL
* Red Hat Enterprise Linux
* Linux Networking

---

# Key Learning

Database connectivity issues should be investigated layer by layer rather than assuming a database failure. By validating the virtual machine, 
PostgreSQL service, listening ports, firewall rules, network connectivity, and authentication configuration in sequence, the root cause can be 
identified quickly and service restored with minimal disruption.
