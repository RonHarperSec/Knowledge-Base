# Knowledge Base

A collection of personal IT and cybersecurity projects, scripts, tools and labs I've built
while learning and experimenting outside of work. This repo is the index; larger projects
live in their own repositories with their own documentation.

I work in SOC and detection engineering day to day, and most of what ends up here reflects
that: detection work, automation, security tooling, data pipelines, and the infrastructure
I build to practise skills adjacent to my role.

## Projects

| Project | Description |
|---|---|
| [cve-asset-matcher](https://github.com/RonHarperSec/cve-asset-matcher) | Vulnerability intelligence pipeline. Pulls CISA KEV and NVD data and matches it against an inventory of a real environment, so the output is vulnerabilities that affect *this* estate rather than a feed of everything. Python, with containerisation and SIEM output planned. |
| [Purple Team Artefacts](https://github.com/RonHarperSec/Knowledge-Base/tree/main/Purple%20Team%20Artifacts) | Detection-focused exercises: run an attacker technique in the lab, confirm what it generates in the logs, and build a detection to catch it. First up is a brute-force detection (T1110) against a Domain Controller, including finding and fixing the telemetry gaps that were hiding the attack. |

*More projects will be added as they're built out.*

## Home lab

Most of these projects are built against or tested in a self-built lab environment: a segmented network with a firewall, a Windows domain, client machines, an isolated attack network, and log forwarding into a SIEM, plus a Linux Docker host for running containerised tooling and CI/CD work. Built, broken and rebuilt by me.

## About

Each project has its own README or write-up covering what it does, how to run it, the
design decisions behind it, and a roadmap where relevant.

Nothing here is production code from my employer. Everything is either built
independently or uses only publicly available data.

## Contact

GitHub: [@RonHarperSec](https://github.com/RonHarperSec)
