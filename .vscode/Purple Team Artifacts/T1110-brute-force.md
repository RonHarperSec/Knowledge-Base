# Purple Team: Brute Force Against a Domain Controller (T1110)

**MITRE ATT&CK:** [T1110 — Brute Force](https://attack.mitre.org/techniques/T1110/)

## Goal

Purple teaming tests whether an attack is actually visible to my monitoring, and
where the gaps are. That includes three kinds of gap: activity that isn't logged at
all, activity that is logged but has no detection built for it, and detections that
exist but don't fire. This exercise tests my coverage of credential brute forcing
against my Domain Controller, and produces a detection to close whatever gap it finds.

## Hypothesis

I want to test whether my monitoring can detect an attacker brute forcing my Domain
Controller (Windows_Server_2025). I don't currently have a detection rule for this, so
this is as much about finding the gap as testing an existing control.

## Prediction

A brute-force attempt will generate a burst of Event ID 4625 (failed logon) in the
Windows Security log, against a single targeted account, from a single source, in a
short time window. A detection should alert on a threshold of failed logons per account
per source over a set period.

The specific fields I expect to rely on in each 4625 event:

- **Account Name** — the account being targeted
- **Source Network Address / Workstation Name** — where the attempts are coming from
- **Failure Reason / Sub Status** — distinguishes a wrong password from a disabled or
  non-existent account, which changes what the attack looks like

## Scenario

**Assumed breach.**

An attacker has gained a foothold in the network by getting a backdoor onto a client of
the DC, delivered through a trojanised file. They've used that foothold to bring an
attacker-controlled host (Kali Linux) onto the internal network, giving them the tooling
to attack the DC directly.

This is a realistic framing for brute forcing a Domain Controller. A DC should never be
internet-facing, so external brute force isn't the real threat. The real threat is
lateral movement: an attacker already inside the network attempting to brute force
domain credentials to escalate access. That's what this models.

## What I'm testing

1. **Is the activity logged?** Does the DC record failed logons (4625) when the brute
   force runs? If audit logging for logon failures isn't enabled, the attack will
   generate nothing and that's a visibility gap in its own right.
2. **Can I detect it?** If the events are there, can I write a rule that reliably
   catches the pattern without alerting on someone simply mistyping their password?

## Method

*(to be filled in as I run it)*

- Confirm failed-logon auditing is enabled on the DC
- Run a controlled brute-force attempt from the Kali host against a test account on the DC
- Record the exact tool, command and timestamp
- Search Splunk for the resulting events and confirm the prediction
- Build and tune a detection
- Note false-positive sources

## Detection

*(to be filled in)*

## False positives

*(to be filled in)*

## Outcome

*(to be filled in)*