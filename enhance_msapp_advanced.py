#!/usr/bin/env python3
"""
Advanced MSAPP Enhancer - Creates proper Controls JSON + YAML
This script generates complete HomeScreen with header, KPI cards, sites gallery, and button
"""

import zipfile
import json
import os
import shutil
import uuid
from pathlib import Path

class PowerAppsControlGenerator:
    """Generates Power Apps controls with proper metadata"""

    def __init__(self):
        self.control_counter = 12  # Start after existing controls (1-11)

    def generate_control_json(self, name, control_type, parent_index, template_name="", is_component=False):
        """Generate Control JSON file"""
        control_index = self.control_counter
        self.control_counter += 1

        return {
            "Index": control_index,
            "Name": name,
            "ControlUniqueId": str(uuid.uuid4()),
            "ParentIndex": parent_index,
            "TemplateName": template_name,
            "Type": control_type,
            "IsComponent": is_component,
            "AllowAccessToGlobals": False
        }

    def generate_homescreen_yaml(self):
        """Generate complete HomeScreen YAML with all controls"""
        return '''# HomeScreen with Natural England branding and controls
Screens:
  HomeScreen As screen:
    Fill: =varTheme.Background
    LoadingSpinnerColor: =varTheme.Primary

    HeaderBanner As rectangle:
        Fill: =varTheme.Primary
        Height: =80
        Width: =Parent.Width
        X: =0
        Y: =0
        BorderThickness: =0

    HeaderTitle As label:
        Align: =Align.Center
        Color: =RGBA(255, 255, 255, 1)
        Font: =Font.'Segoe UI'
        FontWeight: =FontWeight.Semibold
        Height: =40
        Size: =18
        Text: ="🍃 Natural England – Condition Monitoring Portal"
        Width: =Parent.Width - 40
        X: =20
        Y: =20

    DashboardLabel As label:
        Color: =varTheme.Text
        Font: =Font.'Segoe UI'
        FontWeight: =FontWeight.Semibold
        Height: =30
        Size: =16
        Text: ="Dashboard Overview"
        Width: =400
        X: =20
        Y: =100

    KPIGallery As gallery.galleryHorizontal:
        Height: =120
        Items: =[{Title:"Assessments Due",Value:Text(varKPIs.AssessmentsDue),Icon:"📋",Color:varTheme.Info},{Title:"Awaiting Review",Value:Text(varKPIs.AwaitingReview),Icon:"⏳",Color:varTheme.Warning},{Title:"Favourable %",Value:Text(varKPIs.FavourablePercentage)&"%",Icon:"✅",Color:varTheme.Success}]
        TemplatePadding: =10
        TemplateSize: =(Parent.Width - 80) / 3
        Width: =Parent.Width - 40
        X: =20
        Y: =140

        KPICard As rectangle:
            Fill: =RGBA(255, 255, 255, 1)
            BorderColor: =varTheme.Surface
            BorderThickness: =1
            Height: =100
            Width: =Parent.TemplateWidth - 20
            X: =10
            Y: =10
            RadiusTopLeft: =8
            RadiusTopRight: =8
            RadiusBottomLeft: =8
            RadiusBottomRight: =8

        KPIIcon As label:
            Height: =30
            Size: =24
            Text: =ThisItem.Icon
            Width: =40
            X: =25
            Y: =25

        KPIValue As label:
            Color: =ThisItem.Color
            Font: =Font.'Segoe UI'
            FontWeight: =FontWeight.Bold
            Height: =40
            Size: =28
            Text: =ThisItem.Value
            Width: =Parent.TemplateWidth - 90
            X: =70
            Y: =20

        KPITitle As label:
            Color: =varTheme.TextLight
            Font: =Font.'Segoe UI'
            Height: =30
            Size: =11
            Text: =ThisItem.Title
            Width: =Parent.TemplateWidth - 40
            X: =25
            Y: =65

    SitesLabel As label:
        Color: =varTheme.Text
        Font: =Font.'Segoe UI'
        FontWeight: =FontWeight.Semibold
        Height: =30
        Size: =16
        Text: ="Key SSSI Sites"
        Width: =400
        X: =20
        Y: =280

    SitesGallery As gallery.galleryVertical:
        Height: =200
        Items: =Filter(colSites, Status = "Active")
        TemplatePadding: =5
        TemplateSize: =90
        Width: =Parent.Width - 40
        X: =20
        Y: =320

        SiteCard As rectangle:
            Fill: =RGBA(255, 255, 255, 1)
            BorderColor: =varTheme.Surface
            BorderThickness: =1
            Height: =80
            Width: =Parent.TemplateWidth - 10
            RadiusTopLeft: =4
            RadiusTopRight: =4
            RadiusBottomLeft: =4
            RadiusBottomRight: =4

        SiteName As label:
            Color: =varTheme.Text
            Font: =Font.'Segoe UI'
            FontWeight: =FontWeight.Semibold
            Height: =25
            Size: =14
            Text: =ThisItem.SiteName
            Width: =300
            X: =15
            Y: =10

        SiteRegion As label:
            Color: =varTheme.TextLight
            Font: =Font.'Segoe UI'
            Height: =20
            Size: =11
            Text: =ThisItem.Region & " • " & ThisItem.Area
            Width: =300
            X: =15
            Y: =35

        SiteBadge As label:
            Align: =Align.Center
            Color: =RGBA(255, 255, 255, 1)
            Fill: =If(ThisItem.Designation = "SSSI", varTheme.Primary, varTheme.Accent)
            Font: =Font.'Segoe UI'
            FontWeight: =FontWeight.Semibold
            Height: =20
            Size: =9
            Text: =ThisItem.Designation
            Width: =50
            X: =15
            Y: =55

    CreateButton As button:
        BorderRadius: =8
        Color: =RGBA(255, 255, 255, 1)
        Fill: =varTheme.Success
        Font: =Font.'Segoe UI'
        FontWeight: =FontWeight.Semibold
        Height: =50
        OnSelect: =Navigate(AssessmentWizardScreen)
        Size: =14
        Text: ="➕ Create New Assessment"
        Width: =300
        X: =20
        Y: =540

'''

def enhance_msapp_advanced():
    """Main enhancement function"""
    print("=" * 70)
    print("Advanced MSAPP Enhancer - Creating Full HomeScreen")
    print("=" * 70)

    msapp_path = Path("Natural England Condition Assessment.msapp")
    extract_dir = Path('.msapp_advanced')
    output_path = Path("Natural England Condition Assessment_Enhanced_Full.msapp")

    # Extract
    print("\n[1/5] Extracting original .msapp...")
    if extract_dir.exists():
        shutil.rmtree(extract_dir)
    extract_dir.mkdir()

    with zipfile.ZipFile(msapp_path, 'r') as zip_ref:
        zip_ref.extractall(extract_dir)
    print("   OK")

    # Enhance App.pa.yaml
    print("\n[2/5] Enhancing App.pa.yaml with full data...")
    app_content = '''# ************************************************************************************************
# Warning: YAML source code for Canvas Apps should only be used to review changes made within Power Apps Studio and for minor edits (Preview).
# Use the maker portal to create and edit your Power Apps.
#
# The schema file for Canvas Apps is available at https://go.microsoft.com/fwlink/?linkid=2304907
#
# For more information, visit https://go.microsoft.com/fwlink/?linkid=2292623
# ************************************************************************************************
App As appinfo:
    BackEnabled: =false
    OnStart: =Set(varTheme,{Primary:ColorValue("#1F4D3A"),Secondary:ColorValue("#7FB069"),Accent:ColorValue("#E6A532"),Success:ColorValue("#4CAF50"),Warning:ColorValue("#FF9800"),Error:ColorValue("#F44336"),Info:ColorValue("#2196F3"),Background:ColorValue("#F5F5F5"),Surface:ColorValue("#E0E0E0"),Text:ColorValue("#212121"),TextLight:ColorValue("#757575")});Set(varCurrentUser,User());Set(varKPIs,{AssessmentsDue:12,AwaitingReview:5,FavourablePercentage:73});ClearCollect(colSites,{SiteId:1,SiteName:"Kinder Scout",Region:"Peak District",Area:"High Peak",Designation:"SSSI",Status:"Active"},{SiteId:2,SiteName:"Skipwith Common",Region:"Yorkshire",Area:"Selby",Designation:"SAC",Status:"Active"},{SiteId:3,SiteName:"Wicken Fen",Region:"East Anglia",Area:"Cambridgeshire",Designation:"SSSI",Status:"Active"});ClearCollect(colFeatures,{FeatureId:1,SiteId:1,FeatureName:"Blanket Bog",FeatureType:"Peatland",Condition:"Favourable"},{FeatureId:2,SiteId:1,FeatureName:"Heather Moorland",FeatureType:"Heathland",Condition:"Unfavourable"},{FeatureId:3,SiteId:2,FeatureName:"Lowland Heath",FeatureType:"Heathland",Condition:"Favourable"});ClearCollect(colAssessments,{AssessmentId:1,SiteId:1,FeatureId:1,Status:"InField",CreatedOn:DateValue("2025-10-15"),CreatedBy:1,Priority:"High"},{AssessmentId:2,SiteId:2,FeatureId:3,Status:"AwaitingReview",CreatedOn:DateValue("2025-10-14"),CreatedBy:2,Priority:"Medium"},{AssessmentId:3,SiteId:3,Status:"Approved",CreatedOn:DateValue("2025-10-10"),CreatedBy:1,Priority:"Low"});ClearCollect(colUsers,{UserId:1,Name:"Sarah Thompson",Role:"Ecologist",Email:"sarah.thompson@naturalengland.org.uk"},{UserId:2,Name:"James Mitchell",Role:"Senior Ecologist",Email:"james.mitchell@naturalengland.org.uk"})
    Theme: =PowerAppsTheme

'''

    with open(extract_dir / 'Src' / 'App.pa.yaml', 'w', encoding='utf-8') as f:
        f.write(app_content)
    print("   OK - Added complete theme and collections")

    # Enhance HomeScreen.pa.yaml
    print("\n[3/5] Generating complete HomeScreen with all controls...")
    generator = PowerAppsControlGenerator()
    home_yaml = generator.generate_homescreen_yaml()

    with open(extract_dir / 'Src' / 'HomeScreen.pa.yaml', 'w', encoding='utf-8') as f:
        f.write(home_yaml)
    print("   OK - Generated HomeScreen with:")
    print("      - Header banner and title")
    print("      - 3 KPI cards (dashboard metrics)")
    print("      - Sites gallery (3 SSSI sites)")
    print("      - Create Assessment button")

    # Update DataSources
    print("\n[4/5] Updating DataSources.json...")
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
    print("   OK")

    # Repackage
    print("\n[5/5] Repackaging enhanced .msapp...")
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
    print("ADVANCED ENHANCEMENT COMPLETE!")
    print("=" * 70)
    print(f"\nEnhanced file: {output_path.name}")
    print(f"\nHomeScreen now includes:")
    print("  ✓ Natural England green header with logo text")
    print("  ✓ 3 KPI cards with icons (📋 ⏳ ✅)")
    print("  ✓ Sites gallery showing 3 SSSI sites")
    print("  ✓ SSSI/SAC designation badges")
    print("  ✓ Create Assessment button (green)")
    print("  ✓ All using Natural England branding")
    print(f"\nTry importing: {output_path.name}")
    print("If this fails, the .pa.yaml format might still have issues")
    print("=" * 70)

if __name__ == "__main__":
    os.chdir("c:/Users/abhis/Documents/DEFRA/NRMS/Condition Assessment/condition-assessment")
    enhance_msapp_advanced()
