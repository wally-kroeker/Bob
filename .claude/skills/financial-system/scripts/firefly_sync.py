#!/usr/bin/env python3
"""
Firefly III Sync Script

Fetches current month transactions from Firefly III API and exports to markdown cache.

Usage:
    python firefly_sync.py                    # Sync current month
    python firefly_sync.py --month 2025-10   # Sync specific month
    python firefly_sync.py --all              # Sync all months
"""

import os
import sys
import json
import requests
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
import argparse


class FireflySyncError(Exception):
    """Custom exception for Firefly sync errors"""
    pass


class FireflySync:
    def __init__(self, api_url: str, api_token: str, data_dir: str = None):
        """Initialize Firefly sync client"""
        self.api_url = api_url.rstrip('/')
        self.api_token = api_token
        self.headers = {
            'Authorization': f'Bearer {api_token}',
            'Accept': 'application/json'
        }

        # Set data directory
        if data_dir is None:
            script_dir = Path(__file__).parent.parent
            data_dir = script_dir / 'data'
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(exist_ok=True)

        # Ensure entity subdirectories exist
        self.personal_dir = self.data_dir / 'personal'
        self.goodfields_dir = self.data_dir / 'goodfields'
        self.fablab_dir = self.data_dir / 'fablab'

        self.personal_dir.mkdir(exist_ok=True)
        self.goodfields_dir.mkdir(exist_ok=True)
        self.fablab_dir.mkdir(exist_ok=True)

        # Account mapping (will be populated after discovering accounts)
        self.accounts = {}
        self.account_to_entity = {}

    def _get(self, endpoint: str, params: Dict = None) -> Dict:
        """Make GET request to Firefly API"""
        url = f"{self.api_url}/api/v1{endpoint}"
        try:
            response = requests.get(url, headers=self.headers, params=params, timeout=10)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            raise FireflySyncError(f"API error on {endpoint}: {str(e)}")

    def discover_accounts(self) -> None:
        """Discover asset accounts and map to entities"""
        try:
            data = self._get('/accounts', params={'type': 'asset'})

            if 'data' not in data:
                raise FireflySyncError("No accounts found in Firefly")

            for account in data['data']:
                account_id = account['id']
                account_name = account['attributes']['name']
                self.accounts[account_id] = account_name

                # Map account name to entity
                name_lower = account_name.lower()
                if 'personal' in name_lower or 'checking' in name_lower:
                    self.account_to_entity[account_id] = 'personal'
                elif 'goodfields' in name_lower or 'business' in name_lower:
                    self.account_to_entity[account_id] = 'goodfields'
                elif 'fablab' in name_lower or 'operations' in name_lower:
                    self.account_to_entity[account_id] = 'fablab'
                else:
                    # Default to personal if can't determine
                    self.account_to_entity[account_id] = 'personal'
                    print(f"Warning: Account '{account_name}' mapped to 'personal' (ambiguous name)")

            print(f"Discovered {len(self.accounts)} accounts:")
            for acc_id, acc_name in self.accounts.items():
                entity = self.account_to_entity[acc_id]
                print(f"  - {acc_name} ({entity})")

        except FireflySyncError as e:
            print(f"Error discovering accounts: {str(e)}")
            raise

    def fetch_transactions(self, account_id: str, start_date: str, end_date: str) -> List[Dict]:
        """Fetch transactions for account in date range"""
        transactions = []
        page = 1

        while True:
            data = self._get(
                f'/accounts/{account_id}/transactions',
                params={
                    'start': start_date,
                    'end': end_date,
                    'page': page
                }
            )

            if 'data' not in data or not data['data']:
                break

            transactions.extend(data['data'])

            # Check if there are more pages
            if 'meta' in data and data['meta'].get('pagination', {}).get('total_pages', 0) <= page:
                break

            page += 1

        return transactions

    def format_transaction(self, transaction: Dict) -> Dict:
        """Extract relevant fields from transaction"""
        attrs = transaction['attributes']

        # Get transaction amount (sum of splits)
        amount = 0
        if 'transactions' in attrs:
            for split in attrs['transactions']:
                amount += float(split['amount'])

        return {
            'date': attrs['date'],
            'amount': amount,
            'description': attrs['description'],
            'category': attrs.get('category_name', 'Uncategorized'),
            'tags': attrs.get('tags', []),
            'budget': attrs.get('budget_name', '')
        }

    def generate_markdown(self, entity: str, month_str: str, transactions: List[Dict], balance: float) -> str:
        """Generate markdown file for entity's transactions"""

        # Parse month string (format: 2025-11)
        try:
            month_dt = datetime.strptime(month_str, '%Y-%m')
            month_display = month_dt.strftime('%B %Y')
        except ValueError:
            month_display = month_str

        # Calculate totals
        total_spent = sum(t['amount'] for t in transactions if t['amount'] < 0)
        total_income = sum(t['amount'] for t in transactions if t['amount'] > 0)

        # Group by category
        by_category = {}
        for t in transactions:
            cat = t['category']
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(t)

        # Sort categories by amount
        sorted_categories = sorted(
            by_category.items(),
            key=lambda x: abs(sum(t['amount'] for t in x[1])),
            reverse=True
        )

        # Generate markdown
        md = f"# {entity.title()} Finances - {month_display}\n\n"
        md += "## Summary\n"
        md += f"- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
        md += f"- Account Balance: ${balance:,.2f}\n"
        md += f"- Total Transactions: {len(transactions)}\n"
        md += f"- Total Income: ${total_income:,.2f}\n"
        md += f"- Total Spent: ${abs(total_spent):,.2f}\n"
        md += f"- Net: ${total_income + total_spent:,.2f}\n\n"

        # Transactions by category
        md += "## Transactions by Category\n\n"

        for category, cat_transactions in sorted_categories:
            category_total = sum(t['amount'] for t in cat_transactions)
            md += f"### {category}\n"
            md += f"**Total: ${category_total:,.2f}** ({len(cat_transactions)} transactions)\n\n"
            md += "| Date | Description | Amount |\n"
            md += "|------|-------------|--------|\n"

            # Sort transactions by date (newest first)
            for t in sorted(cat_transactions, key=lambda x: x['date'], reverse=True):
                md += f"| {t['date']} | {t['description'][:50]} | ${t['amount']:,.2f} |\n"

            md += "\n"

        return md

    def sync_month(self, month_str: Optional[str] = None) -> None:
        """Sync transactions for specific month"""

        if month_str is None:
            # Default to current month
            today = datetime.now()
            month_str = today.strftime('%Y-%m')

        # Parse month
        try:
            month_dt = datetime.strptime(month_str, '%Y-%m')
        except ValueError:
            raise FireflySyncError(f"Invalid month format: {month_str}. Use YYYY-MM")

        # Calculate date range
        start_date = month_dt.strftime('%Y-%m-01')
        if month_dt.month == 12:
            next_month = month_dt.replace(year=month_dt.year + 1, month=1)
        else:
            next_month = month_dt.replace(month=month_dt.month + 1)
        end_date = (next_month - timedelta(days=1)).strftime('%Y-%m-%d')

        print(f"Syncing {month_str}...")

        # Fetch and process each account
        for account_id, account_name in self.accounts.items():
            entity = self.account_to_entity[account_id]

            print(f"  Fetching {entity} ({account_name})...", end=" ")

            try:
                # Fetch transactions
                transactions = self.fetch_transactions(account_id, start_date, end_date)
                formatted = [self.format_transaction(t) for t in transactions]

                # Get account balance (from first transaction)
                account_data = self._get(f'/accounts/{account_id}')
                balance = float(account_data['data']['attributes']['current_balance'])

                # Generate markdown
                markdown = self.generate_markdown(entity, month_str, formatted, balance)

                # Write to file
                entity_dir = getattr(self, f'{entity}_dir')
                filepath = entity_dir / f"{month_str}-transactions.md"
                filepath.write_text(markdown)

                print(f"✓ ({len(formatted)} transactions)")

            except FireflySyncError as e:
                print(f"✗ Error: {str(e)}")

    def sync_all_months(self, months_back: int = 6) -> None:
        """Sync last N months of transactions"""
        today = datetime.now()

        for i in range(months_back):
            month = today - timedelta(days=30*i)
            month_str = month.strftime('%Y-%m')
            self.sync_month(month_str)

    def print_status(self) -> None:
        """Print sync status"""
        print("Firefly III Sync Status")
        print(f"API URL: {self.api_url}")
        print(f"Data Directory: {self.data_dir}")
        print(f"Accounts: {len(self.accounts)}")
        print("")


def main():
    parser = argparse.ArgumentParser(
        description='Sync Firefly III transactions to markdown cache'
    )
    parser.add_argument(
        '--month',
        help='Sync specific month (format: YYYY-MM)',
        default=None
    )
    parser.add_argument(
        '--all',
        action='store_true',
        help='Sync all months (6 months back)'
    )
    parser.add_argument(
        '--months-back',
        type=int,
        default=6,
        help='Number of months to sync with --all (default: 6)'
    )
    parser.add_argument(
        '--api-url',
        default='http://10.10.10.34:8080',
        help='Firefly III API URL (default: http://10.10.10.34:8080)'
    )
    parser.add_argument(
        '--data-dir',
        help='Data directory for markdown cache (default: ./data)'
    )

    args = parser.parse_args()

    # Get API token from environment
    api_token = os.getenv('FIREFLY_III_ACCESS_TOKEN')
    if not api_token:
        print("Error: FIREFLY_III_ACCESS_TOKEN environment variable not set")
        print("Set it with: export FIREFLY_III_ACCESS_TOKEN=your-token")
        sys.exit(1)

    try:
        # Initialize sync client
        sync = FireflySync(args.api_url, api_token, args.data_dir)

        # Discover accounts
        print("Discovering accounts...")
        sync.discover_accounts()
        print("")

        # Sync transactions
        if args.all:
            sync.sync_all_months(args.months_back)
        elif args.month:
            sync.sync_month(args.month)
        else:
            # Default to current month
            sync.sync_month()

        print("\nSync complete!")

    except FireflySyncError as e:
        print(f"Sync failed: {str(e)}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {str(e)}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
