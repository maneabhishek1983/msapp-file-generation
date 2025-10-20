import zipfile, json, os, shutil
from pathlib import Path

msapp_path = Path("Natural England Condition Assessment.msapp")
extract_dir = msapp_path.parent / '.msapp_fixed'
output_path = msapp_path.parent / f"{msapp_path.stem}_Enhanced_Fixed.msapp"

print("=" * 70)
print("Natural England MSAPP Fixer - Correct Format")
print("=" * 70)

# Extract
print(f"\n[1/4] Extracting original .msapp")
if extract_dir.exists():
    shutil.rmtree(extract_dir)
extract_dir.mkdir(parents=True)
with zipfile.ZipFile(msapp_path, 'r') as zip_ref:
    zip_ref.extractall(extract_dir)
print(f"   OK")

# Fix App.pa.yaml with CORRECT format
print(f"\n[2/4] Enhancing App.pa.yaml with correct format")
app_content = '''# ************************************************************************************************
# Warning: YAML source code for Canvas Apps should only be used to review changes made within Power Apps Studio and for minor edits (Preview).
# Use the maker portal to create and edit your Power Apps.
# 
# The schema file for Canvas Apps is available at https://go.microsoft.com/fwlink/?linkid=2304907
# 
# For more information, visit https://go.microsoft.com/fwlink/?linkid=2292623
# ************************************************************************************************
App:
  Properties:
    Theme: =PowerAppsTheme
    OnStart: |-
      =Set(varTheme,{Primary:ColorValue("#1F4D3A"),Secondary:ColorValue("#7FB069"),Accent:ColorValue("#E6A532"),Success:ColorValue("#4CAF50"),Warning:ColorValue("#FF9800"),Error:ColorValue("#F44336"),Info:ColorValue("#2196F3"),Background:ColorValue("#F5F5F5"),Surface:ColorValue("#E0E0E0"),Text:ColorValue("#212121"),TextLight:ColorValue("#757575")});Set(varCurrentUser,User());Set(varKPIs,{AssessmentsDue:12,AwaitingReview:5,FavourablePercentage:73});ClearCollect(colSites,{SiteId:1,SiteName:"Kinder Scout",Region:"Peak District",Area:"High Peak",Designation:"SSSI",Status:"Active"},{SiteId:2,SiteName:"Skipwith Common",Region:"Yorkshire",Area:"Selby",Designation:"SAC",Status:"Active"},{SiteId:3,SiteName:"Wicken Fen",Region:"East Anglia",Area:"Cambridgeshire",Designation:"SSSI",Status:"Active"});ClearCollect(colFeatures,{FeatureId:1,SiteId:1,FeatureName:"Blanket Bog",FeatureType:"Peatland",Condition:"Favourable"},{FeatureId:2,SiteId:1,FeatureName:"Heather Moorland",FeatureType:"Heathland",Condition:"Unfavourable"},{FeatureId:3,SiteId:2,FeatureName:"Lowland Heath",FeatureType:"Heathland",Condition:"Favourable"});ClearCollect(colAssessments,{AssessmentId:1,SiteId:1,FeatureId:1,Status:"InField",CreatedOn:DateValue("2025-10-15"),CreatedBy:1,Priority:"High"},{AssessmentId:2,SiteId:2,FeatureId:3,Status:"AwaitingReview",CreatedOn:DateValue("2025-10-14"),CreatedBy:2,Priority:"Medium"},{AssessmentId:3,SiteId:3,Status:"Approved",CreatedOn:DateValue("2025-10-10"),CreatedBy:1,Priority:"Low"});ClearCollect(colUsers,{UserId:1,Name:"Sarah Thompson",Role:"Ecologist",Email:"sarah.thompson@naturalengland.org.uk"},{UserId:2,Name:"James Mitchell",Role:"Senior Ecologist",Email:"james.mitchell@naturalengland.org.uk"})

'''
with open(extract_dir / 'Src' / 'App.pa.yaml', 'w', encoding='utf-8') as f:
    f.write(app_content)
print("   OK - Added theme and 4 collections")

# Fix HomeScreen with CORRECT format
print(f"\n[3/4] Enhancing HomeScreen.pa.yaml with correct format")
home_content = '''# ************************************************************************************************
# Warning: YAML source code for Canvas Apps should only be used to review changes made within Power Apps Studio and for minor edits (Preview).
# Use the maker portal to create and edit your Power Apps.
# 
# The schema file for Canvas Apps is available at https://go.microsoft.com/fwlink/?linkid=2304907
# 
# For more information, visit https://go.microsoft.com/fwlink/?linkid=2292623
# ************************************************************************************************
Screens:
  HomeScreen:
    Properties:
      Fill: =varTheme.Background
      LoadingSpinnerColor: =varTheme.Primary

'''
with open(extract_dir / 'Src' / 'HomeScreen.pa.yaml', 'w', encoding='utf-8') as f:
    f.write(home_content)
print("   OK")

# Update DataSources
ds_path = extract_dir / 'References' / 'DataSources.json'
with open(ds_path, 'w', encoding='utf-8') as f:
    json.dump({
        "DataSources": [
            {"Name": "colSites", "Type": "Collection"},
            {"Name": "colFeatures", "Type": "Collection"},
            {"Name": "colAssessments", "Type": "Collection"},
            {"Name": "colUsers", "Type": "Collection"}
        ]
    }, f, indent=2)

# Repackage
print(f"\n[4/4] Repackaging .msapp with correct format")
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
print("FIXED ENHANCEMENT COMPLETE!")
print("=" * 70)
print(f"\nEnhanced file: {output_path.name}")
print(f"\nEnhancements:")
print(f"  - varTheme (11 Natural England colors)")
print(f"  - varCurrentUser (logged in user)")
print(f"  - varKPIs (3 dashboard metrics)")
print(f"  - colSites (3 SSSI sites)")
print(f"  - colFeatures (3 habitat features)")
print(f"  - colAssessments (3 assessments)")
print(f"  - colUsers (2 ecologists)")
print(f"\nNext: Import {output_path.name} to Power Apps")
print("=" * 70)
