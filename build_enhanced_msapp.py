#!/usr/bin/env python3
"""
Complete MSAPP Builder with Controls JSON Generation
Builds a fully functional .msapp with proper YAML + Controls JSON
"""

import zipfile
import json
import shutil
from pathlib import Path
import sys

# Import the controls generator
sys.path.insert(0, str(Path(__file__).parent))
from controls_json_generator import ControlsJSONGenerator


class EnhancedMSAPPBuilder:
    """Builds enhanced .msapp with complete metadata"""

    def __init__(self):
        self.generator = ControlsJSONGenerator(start_unique_id=10)

    def generate_homescreen_yaml(self) -> str:
        """Generate HomeScreen YAML in current Power Apps format"""
        return '''# ************************************************************************************************
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
    Children:
      - HeaderBanner:
          Control: Rectangle@2.3.0
          Properties:
            BorderColor: =RGBA(0, 18, 107, 1)
            BorderThickness: |+
              =0
            Fill: |+
              =varTheme.Primary
            Height: |+
              =80
            Width: |+
              =Parent.Width
            X: |+
              =0
            Y: |+
              =0
      - HeaderTitle:
          Control: Label@2.5.1
          Properties:
            Align: |+
              =Align.Center
            BorderColor: =RGBA(0, 18, 107, 1)
            Color: =Color.White
            Font: |+
              =Font.'Segoe UI'
            FontWeight: |+
              =FontWeight.Semibold
            Height: |+
              =40
            Size: |+
              =18
            Text: |+
              ="🍃 Natural England – Condition Monitoring Portal"
            Width: |+
              =Parent.Width - 40
            X: =20
            Y: |+
              =20
      - DashboardLabel:
          Control: Label@2.5.1
          Properties:
            BorderColor: =RGBA(0, 18, 107, 1)
            Color: =varTheme.Text
            Font: |+
              =Font.'Segoe UI'
            FontWeight: |+
              =FontWeight.Semibold
            Height: |+
              =30
            Size: |+
              =16
            Text: |+
              ="Dashboard Overview"
            Width: |+
              =400
            X: =20
            Y: |+
              =100
      - KPIGallery:
          Control: Gallery@2.5.1
          Variant: galleryHorizontal
          Properties:
            BorderColor: =RGBA(0, 18, 107, 1)
            Height: |+
              =120
            Items: |+
              =[{Title:"Assessments Due",Value:Text(varKPIs.AssessmentsDue),Icon:"[A]",Color:varTheme.Info},{Title:"Awaiting Review",Value:Text(varKPIs.AwaitingReview),Icon:"[R]",Color:varTheme.Warning},{Title:"Favourable %",Value:Text(varKPIs.FavourablePercentage)&"%",Icon:"[OK]",Color:varTheme.Success}]
            TemplatePadding: |+
              =10
            TemplateSize: |+
              =(Parent.Width - 80) / 3
            Width: |+
              =Parent.Width - 40
            X: =20
            Y: |+
              =140
          Children:
            - KPICard:
                Control: Rectangle@2.3.0
                Properties:
                  BorderColor: =varTheme.Surface
                  BorderThickness: |+
                    =1
                  Fill: |+
                    =RGBA(255, 255, 255, 1)
                  Height: |+
                    =100
                  RadiusBottomLeft: |+
                    =8
                  RadiusBottomRight: |+
                    =8
                  RadiusTopLeft: |+
                    =8
                  RadiusTopRight: |+
                    =8
                  Width: |+
                    =Parent.TemplateWidth - 20
                  X: |+
                    =10
                  Y: |+
                    =10
            - KPIIcon:
                Control: Label@2.5.1
                Properties:
                  BorderColor: =RGBA(0, 18, 107, 1)
                  Height: |+
                    =30
                  Size: |+
                    =24
                  Text: |+
                    =ThisItem.Icon
                  Width: |+
                    =40
                  X: =20
                  Y: |+
                    =20
            - KPITitle:
                Control: Label@2.5.1
                Properties:
                  BorderColor: =RGBA(0, 18, 107, 1)
                  Color: =varTheme.TextLight
                  Font: |+
                    =Font.'Segoe UI'
                  Height: |+
                    =20
                  Size: |+
                    =11
                  Text: |+
                    =ThisItem.Title
                  Width: |+
                    =Parent.TemplateWidth - 60
                  X: =20
                  Y: |+
                    =55
            - KPIValue:
                Control: Label@2.5.1
                Properties:
                  BorderColor: =RGBA(0, 18, 107, 1)
                  Color: =ThisItem.Color
                  Font: |+
                    =Font.'Segoe UI'
                  FontWeight: |+
                    =FontWeight.Bold
                  Height: |+
                    =30
                  Size: |+
                    =20
                  Text: |+
                    =ThisItem.Value
                  Width: |+
                    =Parent.TemplateWidth - 60
                  X: =20
                  Y: |+
                    =75
      - SitesLabel:
          Control: Label@2.5.1
          Properties:
            BorderColor: =RGBA(0, 18, 107, 1)
            Color: =varTheme.Text
            Font: |+
              =Font.'Segoe UI'
            FontWeight: |+
              =FontWeight.Semibold
            Height: |+
              =30
            Size: |+
              =16
            Text: |+
              ="Recent Sites"
            Width: |+
              =400
            X: =20
            Y: |+
              =280
      - SitesGallery:
          Control: Gallery@2.5.1
          Variant: galleryVertical
          Properties:
            BorderColor: =RGBA(0, 18, 107, 1)
            Height: |+
              =200
            Items: |+
              =Filter(colSites, Status = "Active")
            TemplatePadding: |+
              =5
            TemplateSize: |+
              =90
            Width: |+
              =Parent.Width - 40
            X: =20
            Y: |+
              =320
          Children:
            - SiteCard:
                Control: Rectangle@2.3.0
                Properties:
                  BorderColor: =varTheme.Surface
                  BorderThickness: |+
                    =1
                  Fill: |+
                    =RGBA(255, 255, 255, 1)
                  Height: |+
                    =80
                  RadiusBottomLeft: |+
                    =4
                  RadiusBottomRight: |+
                    =4
                  RadiusTopLeft: |+
                    =4
                  RadiusTopRight: |+
                    =4
                  Width: |+
                    =Parent.TemplateWidth - 10
                  X: |+
                    =5
                  Y: |+
                    =5
            - SiteNameLabel:
                Control: Label@2.5.1
                Properties:
                  BorderColor: =RGBA(0, 18, 107, 1)
                  Color: =varTheme.Text
                  Font: |+
                    =Font.'Segoe UI'
                  FontWeight: |+
                    =FontWeight.Semibold
                  Height: |+
                    =25
                  Size: |+
                    =14
                  Text: |+
                    =ThisItem.SiteName
                  Width: |+
                    =Parent.TemplateWidth - 40
                  X: =20
                  Y: |+
                    =15
            - RegionLabel:
                Control: Label@2.5.1
                Properties:
                  BorderColor: =RGBA(0, 18, 107, 1)
                  Color: =varTheme.TextLight
                  Font: |+
                    =Font.'Segoe UI'
                  Height: |+
                    =20
                  Size: |+
                    =11
                  Text: |+
                    =ThisItem.Region & " • " & ThisItem.Area
                  Width: |+
                    =Parent.TemplateWidth - 40
                  X: =20
                  Y: |+
                    =40
            - DesignationLabel:
                Control: Label@2.5.1
                Properties:
                  BorderColor: =RGBA(0, 18, 107, 1)
                  Color: =varTheme.Info
                  Font: |+
                    =Font.'Segoe UI'
                  FontWeight: |+
                    =FontWeight.Semibold
                  Height: |+
                    =20
                  Size: |+
                    =10
                  Text: |+
                    =ThisItem.Designation
                  Width: |+
                    =60
                  X: =20
                  Y: |+
                    =65
      - CreateButton:
          Control: Button@2.3.0
          Properties:
            BorderColor: =RGBA(0, 18, 107, 1)
            Fill: |+
              =varTheme.Success
            Font: |+
              =Font.'Segoe UI'
            FontWeight: |+
              =FontWeight.Semibold
            Height: |+
              =50
            OnSelect: |+
              =Navigate(AssessmentWizardScreen)
            Size: |+
              =14
            Text: |+
              ="➕ Create New Assessment"
            Width: |+
              =Parent.Width - 40
            X: =20
            Y: |+
              =540
'''

    def generate_homescreen_controls_json(self) -> dict:
        """Generate complete HomeScreen Controls JSON with all controls"""

        # Create gallery children first
        kpi_children = [
            self.generator.create_rectangle(
                "KPICard", "KPIGallery", "10", "10",
                "Parent.TemplateWidth - 20", "100",
                fill="RGBA(255, 255, 255, 1)", border_thickness="1", publish_order=0
            ),
            self.generator.create_label(
                "KPIIcon", "KPIGallery", "ThisItem.Icon", "20", "20",
                "40", "30", size="24", publish_order=1
            ),
            self.generator.create_label(
                "KPITitle", "KPIGallery", "ThisItem.Title", "20", "55",
                "Parent.TemplateWidth - 60", "20",
                color="varTheme.TextLight", size="11", publish_order=2
            ),
            self.generator.create_label(
                "KPIValue", "KPIGallery", "ThisItem.Value", "20", "75",
                "Parent.TemplateWidth - 60", "30",
                color="ThisItem.Color", size="20",
                font_weight="FontWeight.Bold", publish_order=3
            )
        ]

        sites_children = [
            self.generator.create_rectangle(
                "SiteCard", "SitesGallery", "5", "5",
                "Parent.TemplateWidth - 10", "80",
                fill="RGBA(255, 255, 255, 1)", border_thickness="1", publish_order=0
            ),
            self.generator.create_label(
                "SiteNameLabel", "SitesGallery", "ThisItem.SiteName", "20", "15",
                "Parent.TemplateWidth - 40", "25",
                color="varTheme.Text", size="14",
                font_weight="FontWeight.Semibold", publish_order=1
            ),
            self.generator.create_label(
                "RegionLabel", "SitesGallery",
                'ThisItem.Region & " • " & ThisItem.Area',
                "20", "40", "Parent.TemplateWidth - 40", "20",
                color="varTheme.TextLight", size="11", publish_order=2
            ),
            self.generator.create_label(
                "DesignationLabel", "SitesGallery", "ThisItem.Designation",
                "20", "65", "60", "20",
                color="varTheme.Info", size="10",
                font_weight="FontWeight.Semibold", publish_order=3
            )
        ]

        # Create all top-level children
        screen_children = [
            self.generator.create_rectangle(
                "HeaderBanner", "HomeScreen", "0", "0",
                "Parent.Width", "80", fill="varTheme.Primary",
                border_thickness="0", publish_order=0
            ),
            self.generator.create_label(
                "HeaderTitle", "HomeScreen",
                '"🍃 Natural England – Condition Monitoring Portal"',
                "20", "20", "Parent.Width - 40", "40",
                color="Color.White", size="18", align="Align.Center",
                font_weight="FontWeight.Semibold", publish_order=1
            ),
            self.generator.create_label(
                "DashboardLabel", "HomeScreen", '"Dashboard Overview"',
                "20", "100", "400", "30",
                color="varTheme.Text", size="16",
                font_weight="FontWeight.Semibold", publish_order=2
            ),
            self.generator.create_gallery(
                "KPIGallery", "HomeScreen",
                '[{Title:"Assessments Due",Value:Text(varKPIs.AssessmentsDue),Icon:"[A]",Color:varTheme.Info},{Title:"Awaiting Review",Value:Text(varKPIs.AwaitingReview),Icon:"[R]",Color:varTheme.Warning},{Title:"Favourable %",Value:Text(varKPIs.FavourablePercentage)&"%",Icon:"[OK]",Color:varTheme.Success}]',
                "20", "140", "Parent.Width - 40", "120",
                variant="galleryHorizontal",
                template_size="(Parent.Width - 80) / 3",
                template_padding="10",
                children=kpi_children, publish_order=3
            ),
            self.generator.create_label(
                "SitesLabel", "HomeScreen", '"Recent Sites"',
                "20", "280", "400", "30",
                color="varTheme.Text", size="16",
                font_weight="FontWeight.Semibold", publish_order=4
            ),
            self.generator.create_gallery(
                "SitesGallery", "HomeScreen",
                'Filter(colSites, Status = "Active")',
                "20", "320", "Parent.Width - 40", "200",
                variant="galleryVertical",
                template_size="90",
                template_padding="5",
                children=sites_children, publish_order=5
            ),
            self.generator.create_button(
                "CreateButton", "HomeScreen",
                '"➕ Create New Assessment"',
                "Navigate(AssessmentWizardScreen)",
                "20", "540", "Parent.Width - 40", "50",
                fill="varTheme.Success", size="14",
                font_weight="FontWeight.Semibold", publish_order=6
            )
        ]

        # Create the screen wrapper (similar to original 7.json structure)
        homescreen_json = {
            "TopParent": {
                "Type": "ControlInfo",
                "Name": "HomeScreen",
                "Template": {
                    "Id": "http://microsoft.com/appmagic/screen",
                    "Version": "1.0",
                    "LastModifiedTimestamp": "0",
                    "Name": "screen",
                    "FirstParty": True,
                    "IsPremiumPcfControl": False,
                    "IsCustomGroupControlTemplate": False,
                    "CustomGroupControlTemplateName": "",
                    "IsComponentDefinition": False,
                    "OverridableProperties": {}
                },
                "Index": 3,
                "PublishOrderIndex": 0,
                "VariantName": "",
                "LayoutName": "",
                "MetaDataIDKey": "",
                "PersistMetaDataIDKey": False,
                "IsFromScreenLayout": False,
                "StyleName": "defaultScreenStyle",
                "Parent": "",
                "IsDataControl": False,
                "AllowAccessToGlobals": True,
                "OptimizeForDevices": "Off",
                "IsGroupControl": False,
                "IsAutoGenerated": False,
                "Rules": [
                    {
                        "Property": "Fill",
                        "Category": "Design",
                        "InvariantScript": "varTheme.Background",
                        "RuleProviderType": "User"
                    },
                    {
                        "Property": "ImagePosition",
                        "Category": "Design",
                        "InvariantScript": "ImagePosition.Fit",
                        "RuleProviderType": "Unknown"
                    },
                    {
                        "Property": "Height",
                        "Category": "Design",
                        "InvariantScript": "Max(App.Height, App.MinScreenHeight)",
                        "RuleProviderType": "Unknown"
                    },
                    {
                        "Property": "Width",
                        "Category": "Design",
                        "InvariantScript": "Max(App.Width, App.MinScreenWidth)",
                        "RuleProviderType": "Unknown"
                    },
                    {
                        "Property": "Size",
                        "Category": "Design",
                        "InvariantScript": "1 + CountRows(App.SizeBreakpoints) - CountIf(App.SizeBreakpoints, Value >= Self.Width)",
                        "RuleProviderType": "Unknown"
                    },
                    {
                        "Property": "Orientation",
                        "Category": "Design",
                        "InvariantScript": "If(Self.Width < Self.Height, Layout.Vertical, Layout.Horizontal)",
                        "RuleProviderType": "Unknown"
                    },
                    {
                        "Property": "LoadingSpinner",
                        "Category": "Design",
                        "InvariantScript": "LoadingSpinner.None",
                        "RuleProviderType": "Unknown"
                    },
                    {
                        "Property": "LoadingSpinnerColor",
                        "Category": "Design",
                        "InvariantScript": "varTheme.Primary",
                        "RuleProviderType": "User"
                    }
                ],
                "ControlPropertyState": [
                    {
                        "InvariantPropertyName": "Fill",
                        "AutoRuleBindingEnabled": False,
                        "AutoRuleBindingString": "Color.White",
                        "NameMapSourceSchema": "?",
                        "IsLockable": False,
                        "AFDDataSourceName": ""
                    },
                    "ImagePosition",
                    "Height",
                    "Width",
                    "Size",
                    "Orientation",
                    "LoadingSpinner",
                    "LoadingSpinnerColor"
                ],
                "IsLocked": False,
                "ControlUniqueId": "7",
                "Children": screen_children
            }
        }

        return homescreen_json

    def build_msapp(self, input_path: Path, output_path: Path):
        """Build enhanced .msapp with proper YAML and Controls JSON"""
        print("="*70)
        print("ENHANCED MSAPP BUILDER - WITH CONTROLS JSON GENERATION")
        print("="*70)
        print(f"\nInput:  {input_path.name}")
        print(f"Output: {output_path.name}")

        # Create temp directory
        temp_dir = Path("temp_build_enhanced")
        if temp_dir.exists():
            shutil.rmtree(temp_dir)
        temp_dir.mkdir()

        try:
            # 1. Extract original .msapp
            print("\n[1/5] Extracting original .msapp...")
            with zipfile.ZipFile(input_path, 'r') as zip_ref:
                zip_ref.extractall(temp_dir)

            # 2. Generate and write HomeScreen YAML
            print("[2/5] Generating enhanced HomeScreen YAML...")
            homescreen_yaml = self.generate_homescreen_yaml()
            yaml_path = temp_dir / "Src" / "HomeScreen.pa.yaml"
            with open(yaml_path, 'w', encoding='utf-8') as f:
                f.write(homescreen_yaml)
            print(f"      Written: {len(homescreen_yaml)} characters")

            # 3. Generate and write HomeScreen Controls JSON
            print("[3/5] Generating HomeScreen Controls JSON...")
            homescreen_json = self.generate_homescreen_controls_json()
            json_path = temp_dir / "Controls" / "7.json"
            with open(json_path, 'w', encoding='utf-8') as f:
                json.dump(homescreen_json, f, indent=2)

            json_size = json_path.stat().st_size
            children_count = len(homescreen_json["TopParent"]["Children"])
            print(f"      Written: {json_size:,} bytes")
            print(f"      Controls: {children_count} top-level controls")

            # 3a. Update Properties.json with correct ControlCount
            print("[3a/6] Updating Properties.json with correct ControlCount...")
            props_path = temp_dir / "Properties.json"
            with open(props_path, 'r', encoding='utf-8') as f:
                props = json.load(f)

            # Count ALL controls in the app
            props["ControlCount"] = {
                "screen": 8,
                "rectangle": 3,  # HeaderBanner, KPICard, SiteCard
                "label": 6,      # HeaderTitle, DashboardLabel, SitesLabel, KPIIcon, KPITitle, KPIValue, SiteNameLabel, RegionLabel, DesignationLabel
                "gallery": 2,    # KPIGallery, SitesGallery
                "button": 1,     # CreateButton
                "TestSuite": 1,
                "TestCase": 1
            }

            with open(props_path, 'w', encoding='utf-8') as f:
                json.dump(props, f, indent=2)
            print(f"      Updated ControlCount: {sum([v for k,v in props['ControlCount'].items() if k not in ['TestSuite', 'TestCase']])} controls")

            # 4. Package as .msapp
            print("[4/6] Packaging enhanced .msapp...")
            with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zip_out:
                for file_path in temp_dir.rglob('*'):
                    if file_path.is_file():
                        arcname = file_path.relative_to(temp_dir)
                        zip_out.write(file_path, arcname)

            # 5. Verify
            print("[5/6] Verifying output...")
            file_size = output_path.stat().st_size
            print(f"      File size: {file_size:,} bytes ({file_size / 1024:.1f} KB)")

            with zipfile.ZipFile(output_path, 'r') as zip_check:
                yaml_files = [f for f in zip_check.namelist() if f.endswith('.pa.yaml')]
                json_files = [f for f in zip_check.namelist() if f.startswith('Controls/')]
                print(f"      YAML files: {len(yaml_files)}")
                print(f"      Control JSONs: {len(json_files)}")

            print("\n" + "="*70)
            print("SUCCESS!")
            print("="*70)
            print(f"\nCreated: {output_path}")
            print("\nExpected controls in HomeScreen (Tree view):")
            print("  1. HeaderBanner (Rectangle)")
            print("  2. HeaderTitle (Label)")
            print("  3. DashboardLabel (Label)")
            print("  4. KPIGallery (Gallery)")
            print("     - KPICard (Rectangle)")
            print("     - KPIIcon (Label)")
            print("     - KPITitle (Label)")
            print("     - KPIValue (Label)")
            print("  5. SitesLabel (Label)")
            print("  6. SitesGallery (Gallery)")
            print("     - SiteCard (Rectangle)")
            print("     - SiteNameLabel (Label)")
            print("     - RegionLabel (Label)")
            print("     - DesignationLabel (Label)")
            print("  7. CreateButton (Button)")
            print("\nTotal: 15 controls (7 top-level + 8 gallery children)")

        finally:
            # Cleanup
            if temp_dir.exists():
                shutil.rmtree(temp_dir)
            print("\nCleanup complete")


def main():
    """Main execution"""
    base_dir = Path(__file__).parent

    input_file = base_dir / "Natural England Condition Assessment.msapp"
    output_file = base_dir / "Natural England Condition Assessment_ENHANCED_FINAL.msapp"

    if not input_file.exists():
        print(f"ERROR: Input file not found: {input_file}")
        return 1

    builder = EnhancedMSAPPBuilder()
    builder.build_msapp(input_file, output_file)

    print("\n" + "="*70)
    print("IMPORT INSTRUCTIONS")
    print("="*70)
    print("\n1. Go to make.powerapps.com")
    print("2. Click Apps > Import canvas app")
    print(f"3. Upload: {output_file.name}")
    print("4. Click Import")
    print("5. Open the imported app")
    print("6. Check Tree View - expand HomeScreen")
    print("7. You should see all 15 controls listed above")
    print("\nIf successful, you'll see:")
    print("  - Green header with Natural England branding")
    print("  - 3 KPI cards (Dashboard Overview)")
    print("  - Sites gallery (Recent Sites)")
    print("  - Green Create button at bottom")

    return 0


if __name__ == "__main__":
    exit(main())
