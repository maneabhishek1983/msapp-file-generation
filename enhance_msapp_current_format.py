#!/usr/bin/env python3
"""
MSAPP Enhancer - CURRENT Power Apps Format (2024+)
Creates HomeScreen with proper Children/Properties structure
"""

import zipfile
import json
import os
import shutil
from pathlib import Path

class CurrentFormatEnhancer:
    """Generates HomeScreen using current Power Apps YAML format"""

    def generate_homescreen_yaml(self):
        """Generate HomeScreen YAML in CURRENT format (Children/Properties)"""
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
              =[{Title:"Assessments Due",Value:Text(varKPIs.AssessmentsDue),Icon:"📋",Color:varTheme.Info},{Title:"Awaiting Review",Value:Text(varKPIs.AwaitingReview),Icon:"⏳",Color:varTheme.Warning},{Title:"Favourable %",Value:Text(varKPIs.FavourablePercentage)&"%",Icon:"✅",Color:varTheme.Success}]
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

    def enhance_msapp(self, input_path, output_path):
        """Enhance .msapp with updated HomeScreen"""
        print(f"Enhancing: {input_path}")

        # Create temp directory
        temp_dir = Path("temp_enhance_current")
        if temp_dir.exists():
            shutil.rmtree(temp_dir)
        temp_dir.mkdir()

        try:
            # Extract original .msapp
            print("Extracting original .msapp...")
            with zipfile.ZipFile(input_path, 'r') as zip_ref:
                zip_ref.extractall(temp_dir)

            # Update HomeScreen.pa.yaml with current format
            homescreen_path = temp_dir / "Src" / "HomeScreen.pa.yaml"
            print(f"Writing enhanced HomeScreen: {homescreen_path}")

            with open(homescreen_path, 'w', encoding='utf-8') as f:
                f.write(self.generate_homescreen_yaml())

            # Repackage as .msapp
            print(f"Creating enhanced .msapp: {output_path}")
            with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zip_out:
                for file_path in temp_dir.rglob('*'):
                    if file_path.is_file():
                        arcname = file_path.relative_to(temp_dir)
                        zip_out.write(file_path, arcname)

            # Get file size
            file_size = os.path.getsize(output_path)
            print(f"\nSuccess! Created: {output_path}")
            print(f"File size: {file_size:,} bytes ({file_size / 1024:.1f} KB)")

            # Verify contents
            print("\nVerifying contents:")
            with zipfile.ZipFile(output_path, 'r') as zip_check:
                yaml_files = [f for f in zip_check.namelist() if f.endswith('.pa.yaml')]
                print(f"  YAML files: {len(yaml_files)}")
                for yaml_file in sorted(yaml_files):
                    print(f"    - {yaml_file}")

        finally:
            # Cleanup
            if temp_dir.exists():
                shutil.rmtree(temp_dir)
            print("\nCleanup complete")

def main():
    """Main execution"""
    base_dir = Path(r"c:\Users\abhis\Documents\DEFRA\NRMS\Condition Assessment\condition-assessment")

    input_file = base_dir / "Natural England Condition Assessment.msapp"
    output_file = base_dir / "Natural England Condition Assessment_Enhanced_V2.msapp"

    if not input_file.exists():
        print(f"ERROR: Input file not found: {input_file}")
        return

    enhancer = CurrentFormatEnhancer()
    enhancer.enhance_msapp(input_file, output_file)

    print("\n" + "="*60)
    print("IMPORT INSTRUCTIONS:")
    print("="*60)
    print("1. Open Power Apps Studio (make.powerapps.com)")
    print("2. Click 'Apps' > 'Import canvas app'")
    print("3. Upload: Natural England Condition Assessment_Enhanced_V2.msapp")
    print("4. Click 'Import'")
    print("5. Open the app and verify HomeScreen has:")
    print("   - Header banner with Natural England green")
    print("   - Dashboard label")
    print("   - KPI gallery (3 cards)")
    print("   - Sites gallery (vertical list)")
    print("   - Create button at bottom")

if __name__ == "__main__":
    main()
