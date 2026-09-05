# Knowledge Base

A collection of personal IT and cybersecurity projects, scripts, tools and labs I've built
while learning and experimenting outside of work. This repo is the index; each project
lives in its own repository with its own documentation.

I work in SOC and detection engineering day to day, and most of what ends up here reflects
that: automation, security tooling, data pipelines, and the infrastructure I build to
practise skills adjacent to my role.

## Projects

| Project | Description |
|---|---|
| [cve-asset-matcher](https://github.com/RonHarperSec/cve-asset-matcher) | Vulnerability intelligence pipeline. Pulls CISA KEV and NVD data and matches it against an inventory of a real environment, so the output is vulnerabilities that affect *this* estate rather than a feed of everything. Python, with containerisation and SIEM output planned. |

*More projects will be added as they're built out.*

## Home lab

Most of these projects are built against or tested in a self-built lab environment:
a segmented network with a firewall, a Windows domain, client machines, an isolated
attack network, and log forwarding into a SIEM. Built, broken and rebuilt by me.

## About

Each project repository has its own README covering what it does, how to run it, the
design decisions behind it, and a roadmap where relevant.

Nothing here is production code from my employer. Everything is either built
independently or uses only publicly available data.

## Contact

GitHub: [@RonHarperSec](https://github.com/RonHarperSec)
