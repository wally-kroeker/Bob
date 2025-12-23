#!/usr/bin/env python3
"""
Job Analysis Tool - Manual MVP
Analyzes a job posting against Wally's profile and generates recommendation.

Usage:
  python analyze-job.py "job description text"
  python analyze-job.py --file job-posting.txt
  python analyze-job.py --interactive
"""

import sys
import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

# Load profile
SKILL_DIR = Path.home() / ".claude/skills/job-search"
PROFILE_PATH = SKILL_DIR / "data/profile.md"

def load_profile() -> Dict:
    """Load user profile from profile.md"""
    profile = {
        "green_flags": [],
        "red_flags": [],
        "skills": [],
        "deal_breakers": []
    }

    if not PROFILE_PATH.exists():
        return profile

    content = PROFILE_PATH.read_text()

    # Extract green flags section
    green_section = re.search(r'## Green Flags.*?(?=##|$)', content, re.DOTALL)
    if green_section:
        green_text = green_section.group()
        # Extract bullet points
        green_flags = re.findall(r'\*\*([^*]+)\*\*[^\n]*-\s*([^\n]+)', green_text)
        profile["green_flags"] = [f"{title}: {desc}" for title, desc in green_flags]

    # Extract red flags section
    red_section = re.search(r'## Red Flags.*?(?=##|$)', content, re.DOTALL)
    if red_section:
        red_text = red_section.group()
        red_flags = re.findall(r'\*\*([^*]+)\*\*[^\n]*-\s*([^\n]+)', red_text)
        profile["red_flags"] = [f"{title}: {desc}" for title, desc in red_flags]

    # Extract key skills
    skills_section = re.search(r'### Security & Infrastructure.*?(?=###|##|$)', content, re.DOTALL)
    if skills_section:
        skills_text = skills_section.group()
        skills = re.findall(r'^-\s+(.+)$', skills_text, re.MULTILINE)
        profile["skills"] = skills

    # Extract deal-breakers
    deal_section = re.search(r'## Deal-Breakers.*?(?=##|$)', content, re.DOTALL)
    if deal_section:
        deal_text = deal_section.group()
        deal_breakers = re.findall(r'^\d+\.\s+\*\*([^*]+)\*\*', deal_text, re.MULTILINE)
        profile["deal_breakers"] = deal_breakers

    return profile

def detect_flags(job_text: str, profile: Dict) -> Tuple[List[str], List[str]]:
    """Detect green and red flags in job posting"""
    job_lower = job_text.lower()

    green_detected = []
    red_detected = []

    # Green flag keywords
    green_keywords = {
        "remote": ["remote", "work from home", "wfh", "distributed team"],
        "architecture": ["architect", "architecture", "design", "advisory"],
        "contract": ["contract", "contractor", "consulting", "consultant"],
        "clear scope": ["defined scope", "clear responsibilities", "specific goals"],
        "work-life balance": ["work-life balance", "flexible hours", "balanced workload"]
    }

    # Red flag keywords
    red_keywords = {
        "split role": ["and", "plus", "also responsible for", "/", "wear many hats"],
        "on-call": ["24/7", "on-call", "after hours", "weekend support"],
        "vague": ["fast-paced", "dynamic", "startup mentality", "rapidly changing"],
        "family culture": ["we're a family", "family environment"],
        "unrealistic": ["rockstar", "ninja", "guru", "10x engineer"]
    }

    for flag_type, keywords in green_keywords.items():
        if any(kw in job_lower for kw in keywords):
            green_detected.append(flag_type)

    for flag_type, keywords in red_keywords.items():
        if any(kw in job_lower for kw in keywords):
            red_detected.append(flag_type)

    return green_detected, red_detected

def calculate_skills_match(job_text: str, profile: Dict) -> Tuple[int, List[str]]:
    """Calculate rough skills match percentage"""
    job_lower = job_text.lower()
    skills = profile.get("skills", [])

    matched_skills = []
    for skill in skills:
        skill_keywords = skill.lower().split()
        if any(kw in job_lower for kw in skill_keywords):
            matched_skills.append(skill)

    if not skills:
        return 0, []

    match_pct = int((len(matched_skills) / len(skills)) * 100)
    return match_pct, matched_skills

def check_deal_breakers(job_text: str, profile: Dict) -> List[str]:
    """Check for deal-breaker violations"""
    job_lower = job_text.lower()
    violations = []

    deal_breaker_keywords = {
        "Ethical violations": ["surveillance", "weapons", "defense contractor", "fossil fuel"],
        "Split operational roles": ["and", "plus", "devops", "it support"],
        "Location requirement": ["relocation", "must be based in", "on-site only"]
    }

    for breaker, keywords in deal_breaker_keywords.items():
        if any(kw in job_lower for kw in keywords):
            violations.append(breaker)

    return violations

def generate_recommendation(
    skills_match: int,
    green_flags: List[str],
    red_flags: List[str],
    deal_breakers: List[str]
) -> Dict:
    """Generate overall recommendation"""

    # Deal-breakers = automatic no
    if deal_breakers:
        return {
            "decision": "SKIP",
            "priority": "low",
            "reason": f"Deal-breaker detected: {', '.join(deal_breakers)}"
        }

    # Calculate score
    score = skills_match
    score += len(green_flags) * 5  # Each green flag adds 5 points
    score -= len(red_flags) * 10   # Each red flag subtracts 10 points

    # Classify
    if score >= 80 and len(red_flags) == 0:
        decision = "APPLY"
        priority = "high"
        reason = "Strong skills match with green flags, no red flags"
    elif score >= 60 and len(red_flags) <= 1:
        decision = "MAYBE"
        priority = "medium"
        reason = "Good skills match but some concerns - ask clarifying questions"
    else:
        decision = "SKIP"
        priority = "low"
        reason = "Low skills match or too many red flags"

    return {
        "decision": decision,
        "priority": priority,
        "score": min(score, 100),
        "reason": reason
    }

def analyze_job(job_text: str) -> Dict:
    """Main analysis function"""
    profile = load_profile()

    green_flags, red_flags = detect_flags(job_text, profile)
    skills_match, matched_skills = calculate_skills_match(job_text, profile)
    deal_breakers = check_deal_breakers(job_text, profile)
    recommendation = generate_recommendation(skills_match, green_flags, red_flags, deal_breakers)

    return {
        "skills_match": skills_match,
        "matched_skills": matched_skills,
        "green_flags": green_flags,
        "red_flags": red_flags,
        "deal_breakers": deal_breakers,
        "recommendation": recommendation
    }

def format_analysis(analysis: Dict) -> str:
    """Format analysis for display"""
    output = []
    output.append("=" * 60)
    output.append("JOB ANALYSIS RESULTS")
    output.append("=" * 60)
    output.append("")

    # Recommendation (top)
    rec = analysis["recommendation"]
    output.append(f"RECOMMENDATION: {rec['decision']} (Priority: {rec['priority']})")
    output.append(f"Reason: {rec['reason']}")
    if 'score' in rec:
        output.append(f"Overall Score: {rec['score']}/100")
    output.append("")

    # Skills match
    output.append(f"SKILLS MATCH: {analysis['skills_match']}%")
    if analysis["matched_skills"]:
        output.append("Matched skills:")
        for skill in analysis["matched_skills"][:5]:  # Show top 5
            output.append(f"  ✓ {skill}")
        if len(analysis["matched_skills"]) > 5:
            output.append(f"  ... and {len(analysis['matched_skills']) - 5} more")
    output.append("")

    # Green flags
    if analysis["green_flags"]:
        output.append(f"GREEN FLAGS ({len(analysis['green_flags'])}): ✓")
        for flag in analysis["green_flags"]:
            output.append(f"  ✓ {flag}")
    else:
        output.append("GREEN FLAGS: None detected")
    output.append("")

    # Red flags
    if analysis["red_flags"]:
        output.append(f"RED FLAGS ({len(analysis['red_flags'])}): ⚠️")
        for flag in analysis["red_flags"]:
            output.append(f"  ⚠️  {flag}")
    else:
        output.append("RED FLAGS: None detected ✓")
    output.append("")

    # Deal-breakers
    if analysis["deal_breakers"]:
        output.append(f"DEAL-BREAKERS ({len(analysis['deal_breakers'])}): ❌")
        for breaker in analysis["deal_breakers"]:
            output.append(f"  ❌ {breaker}")
        output.append("")

    output.append("=" * 60)

    return "\n".join(output)

def main():
    """CLI entry point"""
    if len(sys.argv) < 2:
        print("Usage: analyze-job.py <job_description_text>")
        print("   or: analyze-job.py --file <path>")
        print("   or: analyze-job.py --interactive")
        sys.exit(1)

    if sys.argv[1] == "--file":
        job_text = Path(sys.argv[2]).read_text()
    elif sys.argv[1] == "--interactive":
        print("Paste job description (Ctrl+D when done):")
        job_text = sys.stdin.read()
    else:
        job_text = " ".join(sys.argv[1:])

    analysis = analyze_job(job_text)
    print(format_analysis(analysis))

    # Save to JSON for later processing
    output_file = SKILL_DIR / "data" / "last-analysis.json"
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(json.dumps(analysis, indent=2))
    print(f"\nAnalysis saved to: {output_file}")

if __name__ == "__main__":
    main()
