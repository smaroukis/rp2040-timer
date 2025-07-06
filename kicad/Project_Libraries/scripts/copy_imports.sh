#!/bin/bash

# Script to copy KiCad files from imports_source to their respective directories

echo "Copying KiCad files from imports_source..."

# Copy .kicad_mod files to footprints/
find imports_source -name "*.kicad_mod" -exec cp {} footprints/ \;
echo "Copied .kicad_mod files to footprints/"

# Copy .kicad_sym files to symbols/
find imports_source -name "*.kicad_sym" -exec cp {} symbols/ \;
echo "Copied .kicad_sym files to symbols/"

# Copy .step files to 3dmodels/
find imports_source -name "*.step" -exec cp {} 3dmodels/ \;
echo "Copied .step files to 3dmodels/"

echo "Done!"