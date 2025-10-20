import zipfile
import os
from pathlib import Path

source_dir = Path('.temp/solutions/NRMSConditionAssessment/CanvasApps/nrms_NRMSConditionAssessment')
output_file = Path('output/NaturalEnglandConditionAssessment.msapp')

# Remove existing file
if output_file.exists():
    output_file.unlink()

with zipfile.ZipFile(output_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for file_path in source_dir.rglob('*'):
        if file_path.is_file():
            # Use forward slashes and relative path
            arcname = str(file_path.relative_to(source_dir)).replace(os.sep, '/')
            zipf.write(file_path, arcname)
            print(f'Added: {arcname}')

print(f'\nCreated {output_file} with forward slash paths')
print(f'File size: {output_file.stat().st_size} bytes')
