#!/bin/bash
# KiCad Component Import Script
# Usage: ./import_kicad_component.sh "/home/spencer/Downloads/COMPONENT_FOLDER"

DOWNLOADS_PATH="$1"
PROJECT_PATH="/home/spencer/Applications/KiCad/10k-Hour-Timer-RP2040/kicad/Project_Libraries"

if [ -z "$DOWNLOADS_PATH" ]; then
    echo "Usage: $0 <path_to_downloaded_component_folder>"
    echo "Example: $0 '/home/spencer/Downloads/S2B_PH_K_S_LF__SN_'"
    exit 1
fi

if [ ! -d "$DOWNLOADS_PATH" ]; then
    echo "Error: Directory '$DOWNLOADS_PATH' does not exist"
    exit 1
fi

echo "Importing KiCad component from: $DOWNLOADS_PATH"

# Copy entire folder to imports_source for backup
echo "Creating backup in imports_source..."
cp -r "$DOWNLOADS_PATH" "$PROJECT_PATH/imports_source/"

# Copy symbol files
echo "Copying symbol files..."
find "$DOWNLOADS_PATH" -name "*.kicad_sym" -exec cp {} "$PROJECT_PATH/symbols/" \;

# Copy footprint files
echo "Copying footprint files..."
find "$DOWNLOADS_PATH" -name "*.kicad_mod" -exec cp {} "$PROJECT_PATH/footprints/" \;

# Copy 3D models
echo "Copying 3D model files..."
find "$DOWNLOADS_PATH" -name "*.step" -exec cp {} "$PROJECT_PATH/3dmodels/" \;

echo "Files copied successfully!"

# Regenerate the combined symbol library
echo "Regenerating combined symbol library..."
"$PROJECT_PATH/scripts/combine_symbols.sh"

echo ""
echo "IMPORTANT: Remember to rename symbol files from timestamp format to descriptive names:"
echo "1. Check symbol file content to identify the component"
echo "2. Rename from YYYY-MM-DD_HH-MM-SS.kicad_sym to COMPONENT_NAME.kicad_sym"
echo "3. Run ./scripts/combine_symbols.sh again after renaming"
echo ""
echo "Symbol files in project:"
ls -la "$PROJECT_PATH/symbols/"*.kicad_sym | tail -5