# LCSL Home Security Lab

A self-built lab I use to practise detection engineering, blue-team work and
infrastructure outside of my job. It's a segmented Windows domain environment with
an isolated attack network and full log forwarding into a SIEM, built to be broken
and rebuilt.

## Purpose

Somewhere to run attacker techniques against a realistic environment, see what they
generate in the logs, and write detections for them. It also gives me a place to stand
up and learn new software from scratch, such as SIEM platforms, forwarders, firewalls
and domain services, and to do the firewall, domain and forwarder work I can't safely
try in production.

## Architecture

    ┌──────────────────────────────────────────────────────┐
    │  Host (currently a home workstation under Hyper-V,     │
    │   with a planned migration to a dedicated Proxmox box) │
    │                                                        │
    │   ┌─────────┐   green (LAN)                            │
    │   │ IPFire  │──────────┬──────────┬──────────┐         │
    │   │firewall │          │          │          │         │
    │   └────┬────┘     ┌────┴────┐ ┌───┴────┐ ┌───┴────┐    │
    │        │          │ Windows │ │ Ubuntu │ │ Ubuntu │    │
    │      blue         │ Server  │ │ Splunk │ │ Docker │    │
    │   (isolated)      │  (DC)   │ │ (SIEM) │ │  host  │    │
    │   ┌────┴────┐     └─────────┘ └────────┘ └────────┘    │
    │   │  Kali   │          │                               │
    │   │ attack  │     ┌────┴────┐                          │
    │   └─────────┘     │ Windows │                          │
    │                   │11 client│                          │
    │                   └─────────┘                          │
    └──────────────────────────────────────────────────────┘

## Components

**IPFire** — perimeter firewall segmenting the network into zones. The attack network
sits in an isolated segment with its own access rules, so offensive tooling can't
reach the domain except where I deliberately allow it.

**Windows Server 2025** — domain controller running AD DS, DHCP, DNS and file services.
The core of the environment and the main target for detection work.

**Windows 11 client** — a domain-joined workstation, standing in for a normal endpoint.

**Ubuntu + Splunk** — the SIEM. Universal Forwarders on the Windows hosts ship event
logs here, which is where detection and threat-hunting work happens.

**Kali** — the attack box, in the isolated segment. Used to emulate attacker behaviour
against the domain so I can test whether the telemetry catches it.

**Ubuntu Docker host** — a headless Linux host running Docker Engine, used to build and
run containerised tooling and to host the CI/CD work for my projects (for example the
cve-asset-matcher pipeline, which builds a container image and runs it here).

## Things I've built and fixed

- Deployed and troubleshot Splunk Universal Forwarders across the estate
- Recovered IPFire static routing after a misconfiguration broke inter-zone traffic
- Set up remote access over OpenVPN with dynamic DNS
- Segmented the attack network so the Kali host is contained rather than free-roaming

## Current state

Runs on a home workstation under Hyper-V. The plan was to migrate the lab onto a
dedicated Proxmox host, but that hardware failed during setup, so it stays on the
workstation for now. It's kept portable so it can move cleanly onto Proxmox once the
hardware is replaced.

## Planned

- A malware-analysis zone (FlareVM, REMnux) with a deliberately vulnerable target,
  fully isolated from the rest of the lab
- Infrastructure as Code for the lab itself: defining the VMs, network and firewall
  zones in Terraform and Ansible so the whole environment rebuilds from config rather
  than by hand
- Detection-as-code: detection rules kept in version control and validated
  automatically through a CI pipeline on commit
- Automated asset inventory feeding my cve-asset-matcher from live host data instead
  of a hand-maintained file
