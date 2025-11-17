# FabLab Financial Tracking

## Overview

FabLab is a cooperative infrastructure project funded from GoodFields business surplus. It's built on parallel society values and mission-driven spending aligned with community capability.

---

## Budget Summary

**Status:** Building (informal structure until GoodFields revenue stabilizes)

### Monthly Funding Plan

- **Source:** GoodFields business surplus
- **Current Allocation:** TBD (after first GoodFields revenue)
- **Target:** $500-1,000/month for equipment and infrastructure
- **Current Budget:** [To be formalized after Hydro contract]

---

## Equipment & Infrastructure (Asset Registry)

See `fablab/equipment.md` for detailed equipment tracking.

### Current Infrastructure
- **Proxmox Hosts (2):** Primary compute infrastructure
- **Networking:** Cisco switch, OPNsense firewall
- **Storage:** OMV NAS systems
- **Services:** Vikunja, n8n, AIChat, hosting

### Equipment Status
[Detailed in asset-registry template]

---

## Infrastructure Spending Plan

### Phase 1 (Current - Foundation)
**Goal:** Document existing infrastructure

- Equipment inventory
- Network topology
- Service catalog
- Maintenance baseline

**Estimated Cost:** $0 (using existing equipment)
**Timeline:** November-December 2025

### Phase 2 (Next - Sovereign Mesh)
**Goal:** Implement security architecture (Authentik + Tailscale + Wazuh)

- Authentik IdP deployment
- Tailscale network setup
- Wazuh SIEM installation
- Service migration to centralized auth

**Estimated Cost:** $500-1,000 (mostly setup time, some tools)
**Timeline:** January-March 2026

### Phase 3 (Future - Infrastructure Upgrades)
**Goal:** Replace aging equipment, add capacity

- Proxmox host upgrade/replacement
- Storage expansion
- Network upgrades (switches, APs)

**Estimated Cost:** $5,000-10,000
**Timeline:** 2026+

---

## Mission Alignment

### Values-Driven Spending
Every FabLab equipment purchase serves:
- **Sovereignty:** Self-hosted infrastructure independent of corporate control
- **Community:** Enables others to build and learn
- **Resilience:** Redundancy and local capacity
- **Demonstration:** Proof-of-concept for clients (GoodFields consulting)

### Strategic Value for GoodFields
- **Expertise Demonstration:** Live working examples for security architecture consulting
- **Client References:** "We've built this, it works, here's what we learned"
- **Competitive Advantage:** Rare combination of security + AI + infrastructure knowledge
- **Thought Leadership:** Document and publish architecture decisions

---

## Equipment Replacement Fund

### Envelope Fund Details
- **Monthly Allocation:** $200 (when GoodFields revenue available)
- **Current Balance:** $0 (awaiting first revenue)
- **Target:** $7,200/year for planned replacements

### Replacement Timeline
| Equipment | Useful Life | Depreciation | Current Value | Replacement Cycle | Next Due |
|-----------|------------|---|---|---|---|
| Proxmox #1 | 5-7 years | 20%/yr | $720 | 4-6 years | 2028-2030 |
| Proxmox #2 | 5-7 years | 20%/yr | $[X] | 4-6 years | 2028-2030 |
| Networking | 7-10 years | 15%/yr | $[X] | 7-10 years | 2031-2033 |
| Storage | 5 years | 20%/yr | $[X] | 5 years | 2028-2029 |

---

## Community Project Funding

**Purpose:** Equipment and resources for community members to build

- **Current Fund:** $0 (awaiting GoodFields revenue)
- **Target Monthly:** $300/month (once revenue stable)
- **Use Cases:**
  - Lending equipment to community members
  - Shared project materials
  - Training resources
  - Documentation grants

---

## Hosting & Infrastructure Costs

### Current Services
- **n8n.vrexplorers.com:** Automation server (internal IP: 10.10.10.22)
- **aichat.vrexplorers.com:** AI chat application (10.10.10.20)
- **TaskMan (Vikunja):** Task management (internal, 10.10.10.32)
- **goodfields.io:** Website (10.10.10.33)
- **wallykroeker.com:** Personal site (external hosting)
- **Other services:** Multiple internal services

### Cost Structure
- **Cloudflare Tunnels:** $0 (free tier for basic use)
- **Domain registrations:** ~$12-15/year per domain
- **Electricity:** ~$50/month (estimated for servers)
- **Internet:** Included in personal household (home office)

**Total Monthly (FabLab-specific):** ~$50-100
**Total Annual:** ~$600-1,200

---

## Strategic Context

### Connected to Telos FabLab Goals
- **G1:** Comprehensive infrastructure documentation (in progress)
- **G2:** Hardware inventory (to be formalized)
- **G3:** Software/service inventory (to be formalized)
- **G4:** Sovereign Mesh architecture (planned, 6-phase implementation)

### Connected to Telos Risk Register
- **R1:** Lack of centralized authentication (Authentik migration planned)
- **R2:** No security monitoring (Wazuh SIEM deployment planned)
- **R3:** Services exposed (Tailscale overlay network planned)
- **R4:** Missing hardware inventory (documentation in progress)
- **R5:** Missing software inventory (documentation in progress)

### Connected to Financial System Mission
- **FabLab = Parallel Society Prototype:** Demonstrates self-hosted infrastructure works
- **Funded from GoodFields Surplus:** Business success enables infrastructure investment
- **Community Benefit:** Others can replicate this stack and build their own
- **Consulting Credibility:** Real-world experience, not theoretical

---

## Financial Rules for FabLab

1. **Only spend from GoodFields surplus** - Never at expense of personal stability or business operations
2. **Mission-driven decisions** - Every purchase must serve parallel society values
3. **Community benefit** - Infrastructure should enable others, not just serve personal use
4. **Durability > consumption** - Choose quality, long-lasting equipment
5. **Documentation > secrecy** - Share learnings, help others build

---

## Sustainability Planning

### Path to Self-Sustaining FabLab
1. **Phase 1 (Now - 2026):** GoodFields funds FabLab
2. **Phase 2 (2026-2027):** FabLab generates community value/grants
3. **Phase 3 (2027+):** FabLab operates sustainably (membership, consulting, training)

### Community Revenue Models (Future)
- Membership fees for access
- Training/workshops
- Equipment rental
- Custom AI/automation services
- Grant funding (foundations interested in resilience)

---

## Action Items

1. **Document current infrastructure**
   - [ ] Complete equipment inventory
   - [ ] Map network topology
   - [ ] Catalog all services and versions
   - [ ] Write maintenance procedures

2. **Plan Sovereign Mesh Phase 1**
   - [ ] Design network VLAN structure
   - [ ] Plan Authentik deployment
   - [ ] Estimate timeline and effort

3. **Set up equipment replacement fund**
   - [ ] Once GoodFields revenue flowing
   - [ ] $200/month allocation
   - [ ] Track depreciation for tax purposes

4. **Define community access model**
   - [ ] Who can use FabLab resources?
   - [ ] What training/onboarding needed?
   - [ ] How to manage equipment safely?

---

**Last Updated:** 2025-11-17
**Last Reviewed by Bob:** [TBD]
**Next Review:** After Manitoba Hydro contract decision + GoodFields revenue established
