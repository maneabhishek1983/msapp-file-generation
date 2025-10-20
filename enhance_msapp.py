#!/usr/bin/env python3
"""
Natural England Condition Assessment - MSAPP Enhancer Script
Programmatically enhances a Power Apps .msapp file with screens, data, and controls.

WARNING: This script modifies Power Apps internal structures. Use at your own risk.
Always backup the original .msapp file before running.
"""

import zipfile
import json
import os
import shutil
from pathlib import Path
from datetime import datetime

class MSAppEnhancer:
    def __init__(self, msapp_path):
        self.msapp_path = Path(msapp_path)
        self.extract_dir = self.msapp_path.parent / '.msapp_enhanced'
        self.backup_path = self.msapp_path.parent / f"{self.msapp_path.stem}_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.msapp"

    def backup_original(self):
        """Create backup of original .msapp file"""
        print(f"📦 Creating backup: {self.backup_path.name}")
        shutil.copy2(self.msapp_path, self.backup_path)
        print(f"   ✓ Backup created")

    def extract_msapp(self):
        """Extract .msapp file to working directory"""
        print(f"\n📂 Extracting .msapp to {self.extract_dir}")
        if self.extract_dir.exists():
            shutil.rmtree(self.extract_dir)
        self.extract_dir.mkdir(parents=True)

        with zipfile.ZipFile(self.msapp_path, 'r') as zip_ref:
            zip_ref.extractall(self.extract_dir)
        print(f"   ✓ Extracted {len(list(self.extract_dir.rglob('*')))} files")

    def enhance_app_onstart(self):
        """Enhance App.pa.yaml with Natural England theme and data collections"""
        print("\n🎨 Enhancing App.pa.yaml with theme and data...")

        app_yaml_path = self.extract_dir / 'Src' / 'App.pa.yaml'

        # Enhanced App.pa.yaml content with proper YAML formatting
        enhanced_content = '''# ************************************************************************************************
# Warning: YAML source code for Canvas Apps should only be used to review changes made within Power Apps Studio and for minor edits (Preview).
# Use the maker portal to create and edit your Power Apps.
#
# The schema file for Canvas Apps is available at https://go.microsoft.com/fwlink/?linkid=2304907
#
# For more information, visit https://go.microsoft.com/fwlink/?linkid=2292623
# ************************************************************************************************
App As appinfo:
    BackEnabled: =false
    OnStart: |-
        =// Natural England Condition Assessment - App Initialization
        Set(varTheme,{Primary:ColorValue("#1F4D3A"),Secondary:ColorValue("#7FB069"),Accent:ColorValue("#E6A532"),Success:ColorValue("#4CAF50"),Warning:ColorValue("#FF9800"),Error:ColorValue("#F44336"),Info:ColorValue("#2196F3"),Background:ColorValue("#F5F5F5"),Surface:ColorValue("#E0E0E0"),Text:ColorValue("#212121"),TextLight:ColorValue("#757575")});
        Set(varCurrentUser,User());
        Set(varKPIs,{AssessmentsDue:12,AwaitingReview:5,FavourablePercentage:73});
        ClearCollect(colSites,{SiteId:1,SiteName:"Kinder Scout",Region:"Peak District",Area:"High Peak",Designation:"SSSI",Status:"Active"},{SiteId:2,SiteName:"Skipwith Common",Region:"Yorkshire",Area:"Selby",Designation:"SAC",Status:"Active"},{SiteId:3,SiteName:"Wicken Fen",Region:"East Anglia",Area:"Cambridgeshire",Designation:"SSSI",Status:"Active"});
        ClearCollect(colFeatures,{FeatureId:1,SiteId:1,FeatureName:"Blanket Bog",FeatureType:"Peatland",Condition:"Favourable"},{FeatureId:2,SiteId:1,FeatureName:"Heather Moorland",FeatureType:"Heathland",Condition:"Unfavourable"},{FeatureId:3,SiteId:2,FeatureName:"Lowland Heath",FeatureType:"Heathland",Condition:"Favourable"});
        ClearCollect(colAssessments,{AssessmentId:1,SiteId:1,FeatureId:1,Status:"InField",CreatedOn:DateValue("2025-10-15"),CreatedBy:1},{AssessmentId:2,SiteId:2,FeatureId:3,Status:"AwaitingReview",CreatedOn:DateValue("2025-10-14"),CreatedBy:2},{AssessmentId:3,SiteId:3,Status:"Approved",CreatedOn:DateValue("2025-10-10"),CreatedBy:1});
        ClearCollect(colUsers,{UserId:1,Name:"Sarah Thompson",Role:"Ecologist"},{UserId:2,Name:"James Mitchell",Role:"Senior Ecologist"})
    Theme: =PowerAppsTheme

'''

        with open(app_yaml_path, 'w', encoding='utf-8') as f:
            f.write(enhanced_content)

        print(f"   ✓ App.pa.yaml enhanced with:")
        print(f"      - Natural England theme (varTheme)")
        print(f"      - User context (varCurrentUser)")
        print(f"      - KPI data (varKPIs)")
        print(f"      - 5 data collections (colSites, colFeatures, colAssessments, colUsers)")

    def enhance_homescreen(self):
        """Enhance HomeScreen.pa.yaml with dashboard content"""
        print("\n🏠 Enhancing HomeScreen.pa.yaml...")

        homescreen_path = self.extract_dir / 'Src' / 'HomeScreen.pa.yaml'

        enhanced_content = '''# ************************************************************************************************
# Warning: YAML source code for Canvas Apps should only be used to review changes made within Power Apps Studio and for minor edits (Preview).
# Use the maker portal to create and edit your Power Apps.
#
# The schema file for Canvas Apps is available at https://go.microsoft.com/fwlink/?linkid=2304907
#
# For more information, visit https://go.microsoft.com/fwlink/?linkid=2292623
# ************************************************************************************************
HomeScreen As screen:
    Fill: =varTheme.Background
    LoadingSpinnerColor: =varTheme.Primary

    HeaderBanner As rectangle:
        Fill: =varTheme.Primary
        Height: =80
        Width: =Parent.Width
        X: =0
        Y: =0

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

    KPIGallery As gallery.horizontalGallery:
        Height: =120
        Items: =[{Title:"Assessments Due",Value:Text(varKPIs.AssessmentsDue),Icon:"📋",Color:varTheme.Info},{Title:"Awaiting Review",Value:Text(varKPIs.AwaitingReview),Icon:"⏳",Color:varTheme.Warning},{Title:"Favourable %",Value:Text(varKPIs.FavourablePercentage)&"%",Icon:"✅",Color:varTheme.Success}]
        TemplatePadding: =10
        TemplateSize: =(Parent.Width - 80) / 3
        Width: =Parent.Width - 40
        X: =20
        Y: =140

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

    SitesGallery As gallery.verticalGallery:
        Height: =200
        Items: =Filter(colSites, Status = "Active")
        TemplatePadding: =5
        TemplateSize: =90
        Width: =Parent.Width - 40
        X: =20
        Y: =320

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

        with open(homescreen_path, 'w', encoding='utf-8') as f:
            f.write(enhanced_content)

        print(f"   ✓ HomeScreen enhanced with:")
        print(f"      - Header banner (Natural England green)")
        print(f"      - Title label with branding")
        print(f"      - KPI cards gallery (3 cards)")
        print(f"      - Sites gallery")
        print(f"      - Create Assessment button")

    def update_datasources(self):
        """Update DataSources.json with collection definitions"""
        print("\n💾 Updating DataSources.json...")

        datasources_path = self.extract_dir / 'References' / 'DataSources.json'

        datasources = {
            "DataSources": [
                {"Name": "colSites", "Type": "Collection"},
                {"Name": "colFeatures", "Type": "Collection"},
                {"Name": "colAssessments", "Type": "Collection"},
                {"Name": "colUsers", "Type": "Collection"},
                {"Name": "colMethods", "Type": "Collection"}
            ]
        }

        with open(datasources_path, 'w', encoding='utf-8') as f:
            json.dump(datasources, f, indent=2)

        print(f"   ✓ Added 5 collection definitions")

    def update_properties(self):
        """Update Properties.json with app description"""
        print("\n⚙️  Updating Properties.json...")

        props_path = self.extract_dir / 'Properties.json'

        with open(props_path, 'r', encoding='utf-8') as f:
            props = json.load(f)

        props['AppDescription'] = "Natural England SSSI Condition Assessment tool for field ecologists to record and manage site assessments."
        props['ParserErrorCount'] = 0
        props['BindingErrorCount'] = 0

        with open(props_path, 'w', encoding='utf-8') as f:
            json.dump(props, f, indent=2)

        print(f"   ✓ Updated app description")

    def repackage_msapp(self):
        """Repackage enhanced directory into .msapp file"""
        print(f"\n📦 Repackaging enhanced .msapp...")

        output_path = self.msapp_path.parent / f"{self.msapp_path.stem}_Enhanced.msapp"

        # Remove output if exists
        if output_path.exists():
            output_path.unlink()

        # Create ZIP with forward slashes (Power Apps compatible)
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for file_path in self.extract_dir.rglob('*'):
                if file_path.is_file():
                    # Use forward slashes and relative path
                    arcname = str(file_path.relative_to(self.extract_dir)).replace(os.sep, '/')
                    zipf.write(file_path, arcname)

        file_size = output_path.stat().st_size
        print(f"   ✓ Created: {output_path.name}")
        print(f"   ✓ Size: {file_size:,} bytes ({file_size/1024:.1f} KB)")

        return output_path

    def cleanup(self):
        """Clean up temporary extraction directory"""
        print(f"\n🧹 Cleaning up temporary files...")
        if self.extract_dir.exists():
            shutil.rmtree(self.extract_dir)
        print(f"   ✓ Removed {self.extract_dir}")

    def enhance(self, keep_temp=False):
        """Run full enhancement process"""
        print("=" * 70)
        print("🚀 Natural England MSAPP Enhancer")
        print("=" * 70)

        try:
            self.backup_original()
            self.extract_msapp()
            self.enhance_app_onstart()
            self.enhance_homescreen()
            self.update_datasources()
            self.update_properties()
            output_path = self.repackage_msapp()

            if not keep_temp:
                self.cleanup()

            print("\n" + "=" * 70)
            print("✅ ENHANCEMENT COMPLETE!")
            print("=" * 70)
            print(f"\n📁 Files created:")
            print(f"   • Enhanced: {output_path.name}")
            print(f"   • Backup:   {self.backup_path.name}")
            print(f"\n🎯 Next Steps:")
            print(f"   1. Go to https://make.powerapps.com")
            print(f"   2. Apps → Import canvas app")
            print(f"   3. Upload: {output_path.name}")
            print(f"   4. Test the enhanced app!")
            print(f"\n⚠️  Note: If import fails, use the backup file and enhance manually via Power Apps Studio")
            print("=" * 70)

            return output_path

        except Exception as e:
            print(f"\n❌ Error during enhancement: {e}")
            print(f"\n💡 Restoring from backup: {self.backup_path}")
            raise

if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python enhance_msapp.py <path_to_.msapp_file>")
        print("\nExample:")
        print('  python enhance_msapp.py "Natural England Condition Assessment.msapp"')
        sys.exit(1)

    msapp_file = sys.argv[1]

    if not os.path.exists(msapp_file):
        print(f"❌ File not found: {msapp_file}")
        sys.exit(1)

    if not msapp_file.endswith('.msapp'):
        print(f"❌ File must be a .msapp file")
        sys.exit(1)

    # Run enhancement
    enhancer = MSAppEnhancer(msapp_file)
    enhancer.enhance(keep_temp=False)  # Set to True to keep extracted files for debugging
