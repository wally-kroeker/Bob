# OPNsense DNS Management Skill

Programmatic management of OPNsense Unbound DNS host overrides via REST API.

## Quick Start

### 1. Configure API Credentials

```bash
# Edit the .env file and add your OPNsense API credentials
nano ~/.claude/skills/opnsense-dns/data/.env
```

Add your API key and secret:
```bash
OPNSENSE_HOST=10.10.10.1
OPNSENSE_API_KEY=your_actual_api_key
OPNSENSE_API_SECRET=your_actual_api_secret
OPNSENSE_VERIFY_SSL=false
```

### 2. Install Dependencies

```bash
pip install requests python-dotenv
```

### 3. Test the Setup

```bash
# List existing DNS records
~/.claude/skills/opnsense-dns/opnsense_dns.py list
```

## Usage Examples

### Add Single DNS Record

```bash
~/.claude/skills/opnsense-dns/opnsense_dns.py add \
  --hostname host1 \
  --domain infra.fablab.local \
  --ip 10.10.10.10 \
  --description "Proxmox Host One"
```

### Add All Infrastructure Tier Records (Bulk)

```bash
~/.claude/skills/opnsense-dns/opnsense_dns.py bulk-add \
  --file ~/.claude/skills/opnsense-dns/data/infrastructure-tier.json
```

This will add all 8 Infrastructure Tier DNS records at once:
- opnsense.infra.fablab.local → 10.10.10.1
- opnsense-mgmt.infra.fablab.local → 10.10.40.1
- switch.infra.fablab.local → 10.10.10.5
- switch-mgmt.infra.fablab.local → 10.10.40.5
- host1.infra.fablab.local → 10.10.10.10
- host1-mgmt.infra.fablab.local → 10.10.40.10
- host2.infra.fablab.local → 10.10.10.12
- host2-mgmt.infra.fablab.local → 10.10.40.12

### List All DNS Records

```bash
# Human-readable format
~/.claude/skills/opnsense-dns/opnsense_dns.py list

# JSON format
~/.claude/skills/opnsense-dns/opnsense_dns.py list --json
```

### Delete DNS Record

```bash
~/.claude/skills/opnsense-dns/opnsense_dns.py delete --uuid <record-uuid>
```

### Apply DNS Changes (Manual Restart Required)

After adding, updating, or deleting DNS records, you **must manually restart Unbound** for changes to take effect.

**SSH to OPNsense and run:**
```bash
configctl unbound restart
```

**Note:** The API reconfigure/restart endpoints require additional permissions. The skill will remind you to restart manually after any DNS changes.

## Bulk Import Format

Create a JSON file with DNS records:

```json
[
  {
    "hostname": "service-name",
    "domain": "subdomain.fablab.local",
    "ip": "10.10.x.x",
    "description": "Service description"
  }
]
```

Then import with:
```bash
~/.claude/skills/opnsense-dns/opnsense_dns.py bulk-add --file your-records.json
```

## Available Commands

| Command | Description |
|---------|-------------|
| `add` | Add single DNS host override |
| `list` | List all DNS host overrides |
| `delete` | Delete DNS host override by UUID |
| `bulk-add` | Add multiple records from JSON file |
| `reconfigure` | Reconfigure Unbound (apply changes) |
| `restart` | Restart Unbound service |

## Python Module Usage

You can also import and use the OPNsenseDNS class in Python scripts:

```python
from opnsense_dns import OPNsenseDNS

# Initialize client
client = OPNsenseDNS()

# Add a DNS record
client.add_host_override(
    hostname="myserver",
    domain="apps.fablab.local",
    ip="10.10.10.50",
    description="My Application Server"
)

# Apply changes
client.reconfigure()

# List all records
records = client.search_host_overrides()
for record in records:
    print(f"{record['hostname']}.{record['domain']} → {record['server']}")
```

## FabLab DNS Tiers

Pre-configured JSON files for each tier:

- `data/infrastructure-tier.json` - OPNsense, switches, Proxmox hosts
- `data/management-tier.json` - Authentik, Guacamole, VDI (create as needed)
- `data/application-tier.json` - TaskMan, n8n, AIChat (create as needed)
- `data/storage-tier.json` - OMV NAS devices (create as needed)

## Security Notes

- **Never commit `.env` file** - Contains sensitive API credentials
- API credentials stored in gitignored `data/.env` file
- Self-signed certificate verification disabled by default
- Recommend creating dedicated API user with minimum permissions

## Troubleshooting

### "Missing API credentials" Error

Make sure `.env` file exists and contains all required variables:
```bash
cat ~/.claude/skills/opnsense-dns/data/.env
```

### SSL Certificate Errors

Set `OPNSENSE_VERIFY_SSL=false` in `.env` for self-signed certificates.

### API Permission Errors

Ensure your API key has permissions for:
- Unbound DNS settings (read/write)
- Service control (restart/reconfigure)

### Module Not Found Errors

Install required dependencies:
```bash
pip install requests python-dotenv
```

## References

- [OPNsense Unbound API Documentation](https://docs.opnsense.org/development/api/core/unbound.html)
- [William Lam's Bulk DNS Guide](https://williamlam.com/2025/03/automating-bulk-opnsense-unbound-dns-host-overrides.html)
- [FabLab DNS Implementation Plan](/home/walub/projects/fablab/docs/DNS_IMPLEMENTATION_PLAN.md)
