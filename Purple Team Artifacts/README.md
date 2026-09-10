# Purple Team Artefacts

Detection-focused exercises run in my home lab. The pattern for each is the same: take
a known attacker technique, run it against a realistic target, confirm what it actually
generates in the logs, and build a detection to catch it.

The point isn't to prove I can run an attack — it's to test whether my monitoring can
*see* it, and to find the gaps. Those gaps come in three kinds: activity that isn't
logged at all, activity that's logged but has no detection built for it, and detections
that exist but don't fire. Each write-up documents the technique, what it looked like in
the telemetry, the detection built to catch it, and the false positives worth tuning for.

Environment: a segmented Windows domain lab (Windows Server 2025 DC, Windows client,
Kali attack host, and a Linux Docker host) with logs forwarded into Splunk. See the
[home lab setup](../HomeLabSetup.md) for the architecture.

## Artefacts

| Technique | ATT&CK | What it tests | Outcome |
|---|---|---|---|
| Brute Force | [T1110](https://attack.mitre.org/techniques/T1110/) | Detection of remote failed-logon bursts against a Domain Controller | Found the DC wasn't forwarding Security logs, fixed the telemetry, built and deployed a detection |
| Account Creation & Privilege Escalation | [T1136.002](https://attack.mitre.org/techniques/T1136/002/) / [T1098](https://attack.mitre.org/techniques/T1098/) | Detection of a rogue account being created and elevated to Domain Admins for persistence | Found account-management auditing was disabled entirely, enabled it, and built three detections including a create-then-elevate correlation |

*More techniques will be added here as I work through them.*

---

The two exercises so far trace a small attack chain: **T1110** covers getting in
(brute-forcing credentials), and **T1136.002 / T1098** covers staying in (creating a
privileged account for persistence once inside). More techniques will extend the chain.
