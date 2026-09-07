# Purple Team: Brute Force Against a Domain Controller (T1110)

**MITRE ATT&CK:** [T1110 — Brute Force](https://attack.mitre.org/techniques/T1110/)

## Goal

Purple teaming tests whether an attack is actually visible to my monitoring, and where
the gaps are. That includes three kinds of gap: activity that isn't logged at all,
activity that is logged but has no detection built for it, and detections that exist but
don't fire. This exercise tests my coverage of credential brute forcing against my
Domain Controller, and produces a detection to close whatever gap it finds.

## Hypothesis

I want to test whether my monitoring can detect an attacker brute forcing my Domain
Controller (Windows_Server_2025). I don't currently have a detection rule for this, so
this is as much about finding the gap as testing an existing control.

## Prediction

A brute-force attempt will generate a burst of Event ID 4625 (failed logon) in the
Windows Security log, against a single targeted account, from a single source, in a
short time window. A detection should alert on a threshold of failed logons per account
per source over a set period.

The specific fields I expect to rely on in each 4625 event (using the field names
Splunk's Windows add-on extracts):

- **Account_Name** — the account being targeted
- **src_ip** — where the attempts are coming from (the field the detection groups on)
- **Failure_Reason** — distinguishes a wrong password from a disabled or non-existent
  account, which changes what the attack looks like

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

## Environment

- **Domain Controller:** Windows Server 2025 (Windows_Server_2025), 192.168.10.100
- **Attacker host:** Kali Linux, 192.168.10.60, on the same internal LAN segment
- **SIEM:** Splunk, with a Universal Forwarder on the DC

## What I'm testing

1. **Is the activity logged?** Does the DC record failed logons (4625) when the brute
   force runs? If audit logging for logon failures isn't enabled, the attack generates
   nothing and that's a visibility gap in its own right.
2. **Can I detect it?** If the events are there, can I write a rule that reliably catches
   the pattern without alerting on someone simply mistyping their password?

## Method and findings

Before I could detect anything, I had to get the telemetry working. Three gaps surfaced
on the way, each worth documenting because each is a real way a SOC ends up blind.

### Gap 1 — the DC wasn't forwarding its Security log at all

Baseline check for failed logons returned nothing:

    host="Windows_Server_2025" source="WinEventLog:Security" EventCode=4625 | stats count

I created several deliberate failed logins and still got zero. 

I first checked to be certain whether missing 4625s were a logging problem or a forwarding problem, I
checked Event Viewer on the DC directly (Security log, filtered to Event ID 4625). The
failed logins were there. So auditing was on and the events existed, the problem was getting them forwarded, not a logging gap on the DC.
![alt text](<Screenshot 2026-09-07 191722.png>)

Checking the forwarder's inputs.conf next on the DC, the only Windows channel being forwarded was System:

    [WinEventLog://System]

There was no `[WinEventLog://Security]` stanza. So the most security-relevant Windows
log source — authentication, logon failures, account changes — was never reaching the
SIEM. I added the Security channel:

    [WinEventLog://Security]
    disabled = 0
    index = main
    sourcetype = WinEventLog:Security
    renderXml = false
    start_from = newest

After adding this stanza, security logs started being injested
![alt text](<Screenshot 2026-09-07 190944.png>)

### Gap 2 — events arrived but weren't parsed into usable fields

Security events started flowing, but they landed as raw XML with no extracted fields —
no `EventCode`, no `Account_Name`, nothing to build a detection on. The cause was that
Splunk had no add-on to parse Windows event logs. I installed the **Splunk Add-on for
Microsoft Windows** on the search head, after which the fields extracted properly. (The
events still show a sourcetype of `WinEventLog` rather than `WinEventLog:Security`, but
the add-on's extractions apply regardless, so `EventCode`, `Account_Name` and `src_ip`
all became usable fields.)

The lesson: getting logs *into* a SIEM is only half the job. If they aren't parsed, the
events are effectively invisible to detection, because the fields a rule keys on never
exist. "Logged but not usable" is its own kind of gap.
![alt text](<Screenshot 2026-09-07 192917.png>)


### Baseline before the attack

With telemetry working, I captured a baseline of current failed-logon activity:

    host="Windows_Server_2025" source="WinEventLog:Security" EventCode=4625
    | stats count by Account_Name, src_ip

All existing failures came from localhost (0.0.0.0 / 127.0.0.1) — my own console tests
plus normal machine-account noise. Nothing was failing from a remote host. That matters
for detection: a local failure (someone mistyping at the console) looks nothing like a
remote brute force, and the baseline confirmed there was no remote-source failure
activity to confuse the attack with.

### The attack

I ran the brute force from the Kali host against the administrator account over SMB.
SMB is the right target because it's always on and authenticates against Active
Directory, unlike SSH which Windows doesn't run by default.

hydra was my first choice, but its SMB module failed against Server 2025 ("invalid reply
from target") — its SMB negotiation is too old for SMB3. I switched to NetExec (nxc),
which speaks modern SMB:

    nxc smb 192.168.10.100 -u administrator -p /tmp/pw.txt

Re-running the baseline search after the attack:

    host="Windows_Server_2025" source="WinEventLog:Security" EventCode=4625
    | stats count by Account_Name, src_ip

Two new rows appeared, both from the Kali IP (192.168.10.60): the administrator account
(the password guessing) and a blank account (NetExec's null-auth host-fingerprint
probe). Against the baseline, where every failure had been local, the attack stood out
immediately — a burst against a single account from a single remote source.

**Prediction confirmed.** The distinguishing signal is a remote source, a single
account, and a high count in a short window.

### An anomaly worth chasing

The failure count kept climbing between checks without an obvious re-run. In a real SOC,
"failed logons rising on their own" is exactly the sort of thing worth running down, so
I did: checked the Kali host (`ps aux`) — nothing was running — then checked shell
history, which showed the increase was explained by several attack commands (two hydra
runs plus the nxc run) all landing in the same time bucket. hydra's attempts still
generated 4625s even though its SMB module couldn't parse the reply, because the auth
attempts still reached the DC. No rogue process, no loop — the count was correct.

## Detection

A single remote source producing more than five failed logons against the DC in a
15-minute window is worth alerting on. Local console failures are excluded, because
someone mistyping at the machine itself is not a remote brute force.

    host="Windows_Server_2025" source="WinEventLog:Security" EventCode=4625
    src_ip!="0.0.0.0" src_ip!="127.0.0.1"
    | bin _time span=15m
    | stats count by _time, src_ip, Account_Name
    | where count > 5

Filtering localhost out in the base search, rather than after the stats, means those
events are never counted in the first place — the same result with less work at scale.

The rule fired on the attack (both the administrator guessing and the null-auth probe,
from the Kali IP) and stayed quiet on the local failures. The count reflects total
failures in the window, so a heavier attack produces a higher number — useful for
severity.

This was saved as a scheduled Splunk alert (runs every 15 minutes over the last 15
minutes, triggers when results are greater than zero), closing the gap the exercise
found.
![alt text](<Screenshot 2026-09-07 203533.png>)

## False positives

- **Local console failures** — a user mistyping at the machine itself. Handled by
  excluding 0.0.0.0 / 127.0.0.1.
- **Stale service-account credentials** — a service or scheduled task authenticating
  with an old password can hammer the DC and cross the threshold. Mitigation: allowlist
  known service accounts, or scope the rule to interactive/network logons for user
  accounts.
- **Stale saved credentials after a password change** — a cached credential on a mapped
  drive or app retries until updated. A burst from one internal host against one account,
  but benign.
- **Authorised scanning or pentest activity** — can look identical to an attack; needs
  coordination or source allowlisting.

Tuning direction: allowlist known service accounts and scanner IPs, and consider
weighting on Logon Type, since network logons are more attack-relevant than others.

One known limitation of the current rule: it counts within fixed 15-minute buckets, so
an attack straddling a bucket boundary (say four failures at the end of one bucket and
four at the start of the next) could stay under the threshold in each bucket
individually and slip through. A rolling-window approach — for example `streamstats`
counting failures over a moving time span — would be more robust against that.

## Outcome

I started with no visibility of this attack at all — the Security channel wasn't
forwarded, and once it was, the events weren't parsed. I finished with working
telemetry, a validated detection, and a live alert. Three telemetry gaps found and
fixed, and a genuine detection built to close the one this exercise set out to test.