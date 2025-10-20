#!/usr/bin/env python3
"""
Diagnostic Script - Verify what's actually inside your .msapp file
Run this to see exactly what controls are in each file
"""

import zipfile
import sys
from pathlib import Path

def analyze_msapp(msapp_path):
    """Analyze .msapp file and show HomeScreen controls"""
    print(f"\n{'='*70}")
    print(f"Analyzing: {msapp_path.name}")
    print(f"{'='*70}")

    if not msapp_path.exists():
        print(f"FILE NOT FOUND: {msapp_path}")
        return

    file_size = msapp_path.stat().st_size
    print(f"File size: {file_size:,} bytes ({file_size / 1024:.1f} KB)")

    try:
        with zipfile.ZipFile(msapp_path, 'r') as zip_ref:
            # Check if HomeScreen.pa.yaml exists
            yaml_path = "Src/HomeScreen.pa.yaml"

            if yaml_path in zip_ref.namelist():
                print(f"\nFOUND: {yaml_path}")

                # Read HomeScreen YAML
                with zip_ref.open(yaml_path) as f:
                    content = f.read().decode('utf-8')
                    lines = content.split('\n')

                print(f"   Lines: {len(lines)}")

                # Count controls (lines that start with "- " and end with ":")
                controls = []
                nested_controls = []

                for line in lines:
                    stripped = line.strip()
                    # Top-level children (under HomeScreen)
                    if line.startswith('      - ') and stripped.endswith(':'):
                        control_name = stripped[2:-1]  # Remove "- " and ":"
                        controls.append(control_name)
                    # Nested children (under galleries)
                    elif line.startswith('            - ') and stripped.endswith(':'):
                        control_name = stripped[2:-1]
                        nested_controls.append(control_name)

                print(f"\nCONTROLS FOUND:")
                print(f"   Top-level controls: {len(controls)}")
                print(f"   Nested controls: {len(nested_controls)}")
                print(f"   TOTAL: {len(controls) + len(nested_controls)}")

                print(f"\nCONTROL LIST:")
                for i, ctrl in enumerate(controls, 1):
                    print(f"   {i}. {ctrl}")

                    # Check if this control has children
                    if ctrl in ['KPIGallery', 'SitesGallery']:
                        # Find nested controls for this gallery
                        in_gallery = False
                        gallery_children = []

                        for line in lines:
                            if f'- {ctrl}:' in line:
                                in_gallery = True
                            elif in_gallery and line.startswith('            - '):
                                child = line.strip()[2:-1]
                                gallery_children.append(child)
                            elif in_gallery and line.startswith('      - '):
                                # Next top-level control, stop
                                break

                        for child in gallery_children:
                            print(f"      └── {child}")

                # Show first 30 lines of YAML for verification
                print(f"\nFIRST 30 LINES OF YAML:")
                print("-" * 70)
                for i, line in enumerate(lines[:30], 1):
                    print(f"{i:3}| {line}")
                print("-" * 70)

            else:
                print(f"NOT FOUND: {yaml_path}")
                print(f"\nAvailable files:")
                for name in sorted(zip_ref.namelist()):
                    if name.endswith('.pa.yaml'):
                        print(f"   - {name}")

    except Exception as e:
        print(f"ERROR reading file: {e}")

def main():
    base_dir = Path(r"c:\Users\abhis\Documents\DEFRA\NRMS\Condition Assessment\condition-assessment")

    files_to_check = [
        "Natural England Condition Assessment.msapp",
        "Natural England Condition Assessment_Enhanced_V2.msapp"
    ]

    print("\n" + "="*70)
    print("MSAPP FILE DIAGNOSTIC TOOL")
    print("="*70)

    for filename in files_to_check:
        file_path = base_dir / filename
        analyze_msapp(file_path)

    print("\n" + "="*70)
    print("ANALYSIS COMPLETE")
    print("="*70)
    print("\nINTERPRETATION:")
    print("- Original should show: ~2 controls (HeaderBanner, HeaderTitle)")
    print("- Enhanced_V2 should show: ~15 controls (with galleries)")
    print("\nIf Enhanced_V2 shows 15 controls but you only see header in Power Apps:")
    print("→ The import didn't actually update the app")
    print("→ Try the alternative import method below")

if __name__ == "__main__":
    main()
