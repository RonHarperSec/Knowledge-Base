# Roadmap

Where this is all heading. The projects here are built around detection engineering,
purple teaming and the DevSecOps side of security, and the plan is to keep expanding
them so the whole thing tells a coherent story rather than a pile of one-off demos.
Everything gets built in my own lab, documented, and kept honest about what's done
versus what's planned.

## In progress

- **cve-asset-matcher** — a Python tool that matches CISA KEV and NVD data against an
  inventory of my environment, with a CI/CD pipeline that tests, builds and publishes a
  container image. Working, with more planned (see its own repo).
- **Purple team artefacts** — documented exercises where I run an attacker technique in
  the lab, confirm what it generates in the logs, and build a detection to catch it.

## Next projects

- **Detection-as-code** — the next big one. Detection rules kept in version control,
  tested in a pipeline against sample logs, and deployed automatically. This is where my
  detection background and the CI/CD work meet, and it's the natural step up from the
  brute-force detection I've already built.
- **More purple team write-ups** — building out the collection across the ATT&CK
  techniques, things like scheduled-task persistence and credential dumping, each with
  the attack, the telemetry, and the detection.
- **CTF write-ups** — working through boxes and writing them up with a blue-team angle:
  not just how the attack works, but what it would look like in the logs and how I'd
  detect it. Focused on the offensive techniques that make me better at defence.

## Lab and infrastructure

- **Infrastructure as Code for the lab** — defining the VMs, network and firewall zones
  in Terraform and Ansible so the whole environment rebuilds from config rather than by
  hand. Turns the lab itself into a repeatable, version-controlled build.
- **Malware-analysis zone** — a fully isolated segment with FlareVM and REMnux and a
  deliberately vulnerable target, for safely detonating and analysing samples.
- **Pipeline work in other platforms** — rebuilding my CI/CD in Azure DevOps as well as
  GitHub Actions, to show the concept transfers across tooling rather than being tied to
  one platform.

## The direction

The thread through all of it is moving from doing security to engineering it: making
detection repeatable, testable and automated, and being able to stand up, break and
rebuild the environments it runs in. Each project is meant to close a gap and set up the
next one.