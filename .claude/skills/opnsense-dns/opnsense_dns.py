#!/usr/bin/env python3
"""
OPNsense Unbound DNS Management via REST API

This module provides programmatic access to OPNsense Unbound DNS host overrides.
Uses the OPNsense REST API to add, list, update, and delete DNS records.

Usage:
    python3 opnsense_dns.py add --hostname host1 --domain infra.fablab.local --ip 10.10.10.10
    python3 opnsense_dns.py list
    python3 opnsense_dns.py delete --uuid <uuid>
    python3 opnsense_dns.py bulk-add --file records.json
"""

import os
import sys
import json
import argparse
import requests
from pathlib import Path
from typing import Dict, List, Optional
from dotenv import load_dotenv

# Load environment variables from .env file
SKILL_DIR = Path(__file__).parent
ENV_FILE = SKILL_DIR / "data" / ".env"
load_dotenv(ENV_FILE)


class OPNsenseDNS:
    """OPNsense Unbound DNS API Client"""

    def __init__(self):
        self.host = os.getenv("OPNSENSE_HOST")
        self.api_key = os.getenv("OPNSENSE_API_KEY")
        self.api_secret = os.getenv("OPNSENSE_API_SECRET")
        self.verify_ssl = os.getenv("OPNSENSE_VERIFY_SSL", "false").lower() == "true"

        if not all([self.host, self.api_key, self.api_secret]):
            raise ValueError(
                f"Missing API credentials. Please configure {ENV_FILE}\n"
                f"Copy .env.template to .env and fill in your credentials."
            )

        self.base_url = f"https://{self.host}/api/unbound"
        self.auth = (self.api_key, self.api_secret)

        # Disable SSL warnings if verification is disabled
        if not self.verify_ssl:
            requests.packages.urllib3.disable_warnings()

    def _request(self, method: str, endpoint: str, data: Optional[Dict] = None) -> Dict:
        """Make API request to OPNsense"""
        url = f"{self.base_url}{endpoint}"

        try:
            if method.upper() == "GET":
                response = requests.get(url, auth=self.auth, verify=self.verify_ssl)
            elif method.upper() == "POST":
                headers = {"Content-Type": "application/json"}
                response = requests.post(
                    url, auth=self.auth, json=data, headers=headers, verify=self.verify_ssl
                )
            else:
                raise ValueError(f"Unsupported HTTP method: {method}")

            response.raise_for_status()
            return response.json()

        except requests.exceptions.RequestException as e:
            print(f"API request failed: {e}", file=sys.stderr)
            sys.exit(1)

    def add_host_override(
        self,
        hostname: str,
        domain: str,
        ip: str,
        description: str = "",
        enabled: bool = True,
        rr_type: str = "A"
    ) -> Dict:
        """
        Add a new DNS host override

        Args:
            hostname: Hostname (e.g., 'host1')
            domain: Domain (e.g., 'infra.fablab.local')
            ip: IP address (e.g., '10.10.10.10')
            description: Optional description
            enabled: Whether record is enabled (default: True)
            rr_type: Record type (default: 'A')

        Returns:
            API response with UUID of created record
        """
        data = {
            "host": {
                "enabled": "1" if enabled else "0",
                "hostname": hostname,
                "domain": domain,
                "rr": rr_type,
                "server": ip,
                "description": description
            }
        }

        result = self._request("POST", "/settings/addHostOverride", data)
        print(f"✓ Added: {hostname}.{domain} → {ip}")
        return result

    def get_host_override(self, uuid: Optional[str] = None) -> Dict:
        """
        Get host override(s)

        Args:
            uuid: Optional UUID to get specific record

        Returns:
            Host override data
        """
        endpoint = f"/settings/getHostOverride/{uuid}" if uuid else "/settings/getHostOverride"
        return self._request("GET", endpoint)

    def set_host_override(self, uuid: str, data: Dict) -> Dict:
        """
        Update existing host override

        Args:
            uuid: UUID of record to update
            data: Updated host override data

        Returns:
            API response
        """
        return self._request("POST", f"/settings/setHostOverride/{uuid}", data)

    def delete_host_override(self, uuid: str) -> Dict:
        """
        Delete host override

        Args:
            uuid: UUID of record to delete

        Returns:
            API response
        """
        result = self._request("POST", f"/settings/delHostOverride/{uuid}")
        print(f"✓ Deleted record: {uuid}")
        return result

    def search_host_overrides(self) -> List[Dict]:
        """
        Search/list all host overrides

        Returns:
            List of all DNS host override records
        """
        result = self._request("GET", "/settings/searchHostOverride")

        # Extract rows from search result
        if "rows" in result:
            return result["rows"]
        return []

    def reconfigure(self) -> Dict:
        """
        Reconfigure Unbound service to apply changes

        Returns:
            API response
        """
        result = self._request("POST", "/service/reconfigure")
        print("✓ Unbound reconfigured")
        return result

    def restart(self) -> Dict:
        """
        Restart Unbound service

        Returns:
            API response
        """
        result = self._request("POST", "/service/restart")
        print("✓ Unbound restarted")
        return result

    def bulk_add(self, records: List[Dict]) -> List[str]:
        """
        Add multiple DNS records

        Args:
            records: List of dicts with keys: hostname, domain, ip, description

        Returns:
            List of UUIDs for created records
        """
        uuids = []

        for record in records:
            result = self.add_host_override(
                hostname=record["hostname"],
                domain=record["domain"],
                ip=record["ip"],
                description=record.get("description", "")
            )

            if "uuid" in result:
                uuids.append(result["uuid"])

        return uuids


def main():
    """CLI interface for OPNsense DNS management"""
    parser = argparse.ArgumentParser(
        description="OPNsense Unbound DNS Management via API"
    )
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")

    # Add command
    add_parser = subparsers.add_parser("add", help="Add DNS host override")
    add_parser.add_argument("--hostname", required=True, help="Hostname (e.g., host1)")
    add_parser.add_argument("--domain", required=True, help="Domain (e.g., infra.fablab.local)")
    add_parser.add_argument("--ip", required=True, help="IP address")
    add_parser.add_argument("--description", default="", help="Description")
    add_parser.add_argument("--no-reconfigure", action="store_true", help="Skip Unbound reconfigure")

    # List command
    list_parser = subparsers.add_parser("list", help="List all DNS host overrides")
    list_parser.add_argument("--json", action="store_true", help="Output as JSON")

    # Delete command
    delete_parser = subparsers.add_parser("delete", help="Delete DNS host override")
    delete_parser.add_argument("--uuid", required=True, help="UUID of record to delete")
    delete_parser.add_argument("--no-reconfigure", action="store_true", help="Skip Unbound reconfigure")

    # Bulk add command
    bulk_parser = subparsers.add_parser("bulk-add", help="Add multiple DNS records from file")
    bulk_parser.add_argument("--file", required=True, help="JSON file with DNS records")
    bulk_parser.add_argument("--no-reconfigure", action="store_true", help="Skip Unbound reconfigure")

    # Reconfigure command
    subparsers.add_parser("reconfigure", help="Reconfigure Unbound service")

    # Restart command
    subparsers.add_parser("restart", help="Restart Unbound service")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    # Initialize API client
    try:
        client = OPNsenseDNS()
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    # Execute command
    if args.command == "add":
        client.add_host_override(
            hostname=args.hostname,
            domain=args.domain,
            ip=args.ip,
            description=args.description
        )
        print("\n⚠️  MANUAL RESTART REQUIRED")
        print("To apply DNS changes, SSH to OPNsense and run:")
        print("  configctl unbound restart")

    elif args.command == "list":
        records = client.search_host_overrides()

        if args.json:
            print(json.dumps(records, indent=2))
        else:
            print(f"\nFound {len(records)} DNS host override(s):\n")
            for record in records:
                enabled = "✓" if record.get("enabled") == "1" else "✗"
                hostname = record.get("hostname", "")
                domain = record.get("domain", "")
                ip = record.get("server", "")
                desc = record.get("description", "")
                uuid = record.get("uuid", "")

                print(f"{enabled} {hostname}.{domain} → {ip}")
                if desc:
                    print(f"  Description: {desc}")
                print(f"  UUID: {uuid}\n")

    elif args.command == "delete":
        client.delete_host_override(args.uuid)
        print("\n⚠️  MANUAL RESTART REQUIRED")
        print("To apply DNS changes, SSH to OPNsense and run:")
        print("  configctl unbound restart")

    elif args.command == "bulk-add":
        with open(args.file, 'r') as f:
            records = json.load(f)

        uuids = client.bulk_add(records)
        print(f"\n✓ Added {len(uuids)} DNS records")
        print("\n⚠️  MANUAL RESTART REQUIRED")
        print("To apply DNS changes, SSH to OPNsense and run:")
        print("  configctl unbound restart")

    elif args.command == "reconfigure":
        print("⚠️  API reconfigure endpoint not available")
        print("To apply DNS changes, SSH to OPNsense and run:")
        print("  configctl unbound restart")

    elif args.command == "restart":
        print("⚠️  API restart endpoint not available")
        print("To restart Unbound, SSH to OPNsense and run:")
        print("  configctl unbound restart")


if __name__ == "__main__":
    main()
