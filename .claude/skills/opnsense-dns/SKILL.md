---
name: opnsense-dns
description: OPNsense Unbound DNS management via API. USE WHEN user mentions 'dns records', 'opnsense dns', 'add dns entry', 'unbound host override', OR needs to manage FabLab DNS infrastructure. Provides programmatic DNS record creation, updates, deletion, and bulk operations.
---

# OPNsense DNS Management Skill

**Purpose**: Manage OPNsense Unbound DNS host overrides via REST API for FabLab infrastructure.

## Capabilities

- **Add DNS Records**: Create individual or bulk host overrides
- **List DNS Records**: Query existing DNS entries by domain/hostname
- **Update DNS Records**: Modify existing host overrides
- **Delete DNS Records**: Remove host overrides by UUID
- **Reconfigure Unbound**: Apply changes and restart DNS service
- **Bulk Operations**: Import DNS records from CSV or structured data

## Configuration

**API Credentials Location**: `~/.claude/skills/opnsense-dns/data/.env`

Required environment variables:
```bash
OPNSENSE_HOST=10.10.10.1
OPNSENSE_API_KEY=your_api_key_here
OPNSENSE_API_SECRET=your_api_secret_here
```

## Usage Patterns

### Add Single DNS Record
```python
python3 ~/.claude/skills/opnsense-dns/opnsense_dns.py add \
  --hostname host1 \
  --domain infra.fablab.local \
  --ip 10.10.10.10 \
  --description "Proxmox Host One"
```

### Add Multiple Records (Bulk)
```python
python3 ~/.claude/skills/opnsense-dns/opnsense_dns.py bulk-add \
  --file /path/to/dns_records.json
```

### List All DNS Records
```python
python3 ~/.claude/skills/opnsense-dns/opnsense_dns.py list
```

### Delete DNS Record
```python
python3 ~/.claude/skills/opnsense-dns/opnsense_dns.py delete \
  --uuid <record-uuid>
```

### Reconfigure Unbound
```python
python3 ~/.claude/skills/opnsense-dns/opnsense_dns.py reconfigure
```

## FabLab DNS Tiers

This skill manages DNS for all FabLab infrastructure tiers:

- **Infrastructure** (`infra.fablab.local`): OPNsense, switches, Proxmox hosts
- **Management** (`mgmt.fablab.local`): Authentik, Guacamole, VDI, Tailscale, Wazuh
- **Applications** (`apps.fablab.local`): TaskMan, n8n, AIChat, GoodFields, Firefly
- **Storage** (`storage.fablab.local`): OMV NAS devices

## API Documentation Reference

- OPNsense Unbound API: https://docs.opnsense.org/development/api/core/unbound.html
- William Lam's Bulk DNS Guide: https://williamlam.com/2025/03/automating-bulk-opnsense-unbound-dns-host-overrides.html

## Security Notes

- API credentials stored in `.env` (gitignored, never committed)
- Uses HTTPS with certificate verification disabled (self-signed OPNsense cert)
- API key/secret should have minimum required permissions
- Backup OPNsense config before bulk operations

## Integration with FabLab

This skill integrates with:
- **FabLab Telos**: DNS records align with IP addressing scheme
- **DNS Implementation Plan**: `/home/walub/projects/fablab/docs/DNS_IMPLEMENTATION_PLAN.md`
- **Publishing Loop**: DNS changes can be documented in FabLab build log
