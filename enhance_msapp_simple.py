import zipfile, json, os, shutil
from pathlib import Path
from datetime import datetime

msapp_path = Path("Natural England Condition Assessment.msapp")
extract_dir = msapp_path.parent / '.msapp_enhanced'
backup_path = msapp_path.parent / f"{msapp_path.stem}_backup.msapp"
output_path = msapp_path.parent / f"{msapp_path.stem}_Enhanced.msapp"

print("=" * 70)
print("Natural England MSAPP Enhancer")
print("=" * 70)

# Backup
print(f"\n[1/6] Creating backup: {backup_path.name}")
shutil.copy2(msapp_path, backup_path)
print("   OK")

# Extract
print(f"\n[2/6] Extracting .msapp")
if extract_dir.exists():
    shutil.rmtree(extract_dir)
extract_dir.mkdir(parents=True)
with zipfile.ZipFile(msapp_path, 'r') as zip_ref:
    zip_ref.extractall(extract_dir)
print(f"   OK - Extracted {len(list(extract_dir.rglob('*')))} files")

# Enhance App.pa.yaml
print(f"\n[3/6] Enhancing App.pa.yaml")
app_content = '''App As appinfo:
    BackEnabled: =false
    OnStart: =Set(varTheme,{Primary:ColorValue("#1F4D3A"),Secondary:ColorValue("#7FB069"),Success:ColorValue("#4CAF50")});Set(varKPIs,{AssessmentsDue:12,AwaitingReview:5});ClearCollect(colSites,{SiteId:1,SiteName:"Kinder Scout",Region:"Peak District",Designation:"SSSI",Status:"Active"},{SiteId:2,SiteName:"Skipwith Common",Region:"Yorkshire",Designation:"SAC",Status:"Active"});ClearCollect(colUsers,{UserId:1,Name:"Sarah Thompson",Role:"Ecologist"})
    Theme: =PowerAppsTheme
'''
with open(extract_dir / 'Src' / 'App.pa.yaml', 'w') as f:
    f.write(app_content)
print("   OK - Added theme and collections")

# Enhance HomeScreen
print(f"\n[4/6] Enhancing HomeScreen.pa.yaml")
home_content = '''HomeScreen As screen:
    Fill: =varTheme.Background
    LoadingSpinnerColor: =varTheme.Primary
'''
with open(extract_dir / 'Src' / 'HomeScreen.pa.yaml', 'w') as f:
    f.write(home_content)
print("   OK")

# Update DataSources
print(f"\n[5/6] Updating DataSources.json")
ds_path = extract_dir / 'References' / 'DataSources.json'
with open(ds_path, 'w') as f:
    json.dump({"DataSources": [{"Name": "colSites", "Type": "Collection"}, {"Name": "colUsers", "Type": "Collection"}]}, f, indent=2)
print("   OK - Added 2 collections")

# Repackage
print(f"\n[6/6] Repackaging .msapp")
if output_path.exists():
    output_path.unlink()
with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for file_path in extract_dir.rglob('*'):
        if file_path.is_file():
            arcname = str(file_path.relative_to(extract_dir)).replace(os.sep, '/')
            zipf.write(file_path, arcname)
file_size = output_path.stat().st_size
print(f"   OK - Created {output_path.name} ({file_size/1024:.1f} KB)")

# Cleanup
shutil.rmtree(extract_dir)

print("\n" + "=" * 70)
print("ENHANCEMENT COMPLETE!")
print("=" * 70)
print(f"\nFiles created:")
print(f"  - Enhanced: {output_path.name}")
print(f"  - Backup:   {backup_path.name}")
print(f"\nNext: Import {output_path.name} to Power Apps")
