#!/usr/bin/env python3
"""
Create renamed .msapp with different internal app name
This forces Power Apps to create a NEW app instead of updating existing
"""

import zipfile
import json
import shutil
from pathlib import Path

def rename_msapp(input_path, output_path, new_name):
    """Rename app inside .msapp package"""
    print(f"Creating renamed version...")
    print(f"  Input: {input_path.name}")
    print(f"  Output: {output_path.name}")
    print(f"  New App Name: {new_name}")

    # Create temp directory
    temp_dir = Path("temp_rename")
    if temp_dir.exists():
        shutil.rmtree(temp_dir)
    temp_dir.mkdir()

    try:
        # Extract
        print("\n1. Extracting original...")
        with zipfile.ZipFile(input_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)

        # Update Properties.json with new name
        props_path = temp_dir / "Properties.json"
        print(f"2. Updating {props_path.name}...")

        with open(props_path, 'r', encoding='utf-8') as f:
            props = json.load(f)

        old_name = props.get('DisplayName', 'Unknown')

        # Update app name fields
        props['DisplayName'] = new_name
        props['Name'] = new_name
        if 'LocalizedDisplayName' in props:
            props['LocalizedDisplayName'] = new_name

        print(f"   Old name: {old_name}")
        print(f"   New name: {new_name}")

        with open(props_path, 'w', encoding='utf-8') as f:
            json.dump(props, f, indent=2)

        # Update Header.json if exists
        header_path = temp_dir / "Header.json"
        if header_path.exists():
            print(f"3. Updating {header_path.name}...")
            with open(header_path, 'r', encoding='utf-8') as f:
                header = json.load(f)

            if 'DocProperties' in header:
                header['DocProperties']['DisplayName'] = new_name

            with open(header_path, 'w', encoding='utf-8') as f:
                json.dump(header, f, indent=2)

        # Repackage
        print(f"4. Creating new .msapp...")
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zip_out:
            for file_path in temp_dir.rglob('*'):
                if file_path.is_file():
                    arcname = file_path.relative_to(temp_dir)
                    zip_out.write(file_path, arcname)

        file_size = output_path.stat().st_size
        print(f"\nSUCCESS!")
        print(f"Created: {output_path}")
        print(f"Size: {file_size:,} bytes ({file_size / 1024:.1f} KB)")

    finally:
        if temp_dir.exists():
            shutil.rmtree(temp_dir)

def main():
    base_dir = Path(r"c:\Users\abhis\Documents\DEFRA\NRMS\Condition Assessment\condition-assessment")

    input_file = base_dir / "Natural England Condition Assessment_Enhanced_V2.msapp"
    output_file = base_dir / "Natural England CA - ENHANCED.msapp"

    new_app_name = "Natural England CA - ENHANCED"

    if not input_file.exists():
        print(f"ERROR: Input file not found: {input_file}")
        return

    rename_msapp(input_file, output_file, new_app_name)

    print("\n" + "="*70)
    print("IMPORT INSTRUCTIONS")
    print("="*70)
    print("\n1. Go to make.powerapps.com")
    print("2. Click Apps > Import canvas app")
    print(f"3. Upload: {output_file.name}")
    print("4. In import settings, make sure 'Import Setup' = 'Create as new'")
    print("5. Click Import")
    print(f"\n6. You should now see TWO apps in your apps list:")
    print(f"   - Natural England Condition Assessment (old)")
    print(f"   - Natural England CA - ENHANCED (new)")
    print("\n7. Open 'Natural England CA - ENHANCED'")
    print("8. Check Tree View - should show 15 items under HomeScreen:")
    print("   - HeaderBanner")
    print("   - HeaderTitle")
    print("   - DashboardLabel")
    print("   - KPIGallery (with 4 child controls)")
    print("   - SitesLabel")
    print("   - SitesGallery (with 4 child controls)")
    print("   - CreateButton")
    print("\n9. If it works, you can delete the old app")

if __name__ == "__main__":
    main()
