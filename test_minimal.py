import zipfile, json, os, shutil
from pathlib import Path

print("Testing MINIMAL enhancement - OnStart only")

msapp_path = Path("Natural England Condition Assessment.msapp")
extract_dir = Path('.test_minimal')
output_path = Path("Natural England Condition Assessment_Test_Minimal.msapp")

# Extract
if extract_dir.exists():
    shutil.rmtree(extract_dir)
extract_dir.mkdir()
with zipfile.ZipFile(msapp_path, 'r') as zip_ref:
    zip_ref.extractall(extract_dir)

# Read original App.pa.yaml
with open(extract_dir / 'Src' / 'App.pa.yaml', 'r', encoding='utf-8') as f:
    original = f.read()

print("Original App.pa.yaml:")
print(original)
print("\n" + "="*70 + "\n")

# Try MINIMAL OnStart - just one variable
minimal_content = '''# ************************************************************************************************
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
    OnStart: =Set(varTest, "Hello Natural England")

'''

with open(extract_dir / 'Src' / 'App.pa.yaml', 'w', encoding='utf-8') as f:
    f.write(minimal_content)

print("Modified App.pa.yaml:")
print(minimal_content)

# Repackage
if output_path.exists():
    output_path.unlink()
with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for file_path in extract_dir.rglob('*'):
        if file_path.is_file():
            arcname = str(file_path.relative_to(extract_dir)).replace(os.sep, '/')
            zipf.write(file_path, arcname)

# Cleanup
shutil.rmtree(extract_dir)

print(f"\nCreated: {output_path.name}")
print("Try importing this MINIMAL test file first")
print("If this works, the OnStart format is OK")
print("If this fails too, there's a deeper structural issue")
