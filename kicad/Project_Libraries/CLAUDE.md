# KiCad Project Libraries

## Finding and Copying KiCad Components

### Finding Components in System Libraries

Search for footprints:
```bash
find /usr/share/kicad/footprints -name "*component_name*" 2>/dev/null
```

Search for symbols:
```bash
rg -l "symbol_name" /usr/share/kicad/symbols/ 2>/dev/null
```

Search for 3D models:
```bash
find /usr/share/kicad/3dmodels -name "*component_name*" 2>/dev/null
```

### Copying Components to Project Libraries

Copy footprints:
```bash
cp "/usr/share/kicad/footprints/Library_Name.pretty/footprint_name.kicad_mod" footprints/
```

Copy symbols:
```bash
cp "/usr/share/kicad/symbols/Library_Name.kicad_sym" symbols/
```

Copy 3D models:
```bash
cp "/usr/share/kicad/3dmodels/Library_Name.3dshapes/model_name.step" 3dmodels/
```

### Examples

USB-C Receptacle JAE DX07S016JA1R1500:
- Footprint: `/usr/share/kicad/footprints/Connector_USB.pretty/USB_C_Receptacle_JAE_DX07S016JA1R1500.kicad_mod`
- Symbol: Found in `/usr/share/kicad/symbols/Connector.kicad_sym`

JST Connector:
- Footprint: `/usr/share/kicad/footprints/Connector_JST.pretty/JST_SH_SM03B-SRSS-TB_1x03-1MP_P1.00mm_Horizontal.kicad_mod`
- Symbol: Found in `/usr/share/kicad/symbols/Connector_Generic_MountingPin.kicad_sym`

## Importing Downloaded Components

### Manual Import Process (for individual files)

1. **Copy entire folder to imports_source for backup:**
```bash
cp -r "/home/spencer/Downloads/COMPONENT_FOLDER" "/path/to/project/Project_Libraries/imports_source/"
```

2. **Copy files to respective project folders:**
```bash
# Copy symbol files
cp "/home/spencer/Downloads/COMPONENT_FOLDER/KiCADv6/*.kicad_sym" "/path/to/project/Project_Libraries/symbols/"

# Copy footprint files  
cp "/home/spencer/Downloads/COMPONENT_FOLDER/KiCADv6/footprints.pretty/*.kicad_mod" "/path/to/project/Project_Libraries/footprints/"

# Copy 3D models (if present)
cp "/home/spencer/Downloads/COMPONENT_FOLDER/KiCADv6/3dmodels/*.step" "/path/to/project/Project_Libraries/3dmodels/"
```

3. **Rename symbol files to descriptive names:**
```bash
# Check symbol file content first to identify the component
# Then rename from timestamp format to descriptive name
mv "/path/to/project/Project_Libraries/symbols/YYYY-MM-DD_HH-MM-SS.kicad_sym" "/path/to/project/Project_Libraries/symbols/COMPONENT_NAME.kicad_sym"
```

### Automated Import Script

Create a reusable import script:
```bash
#!/bin/bash
# Usage: ./import_kicad_component.sh "/home/spencer/Downloads/COMPONENT_FOLDER"

DOWNLOADS_PATH="$1"
PROJECT_PATH="/home/spencer/Applications/KiCad/10k-Hour-Timer-RP2040/kicad/Project_Libraries"

if [ -z "$DOWNLOADS_PATH" ]; then
    echo "Usage: $0 <path_to_downloaded_component_folder>"
    exit 1
fi

# Copy entire folder to imports_source for backup
cp -r "$DOWNLOADS_PATH" "$PROJECT_PATH/imports_source/"

# Copy symbol files
find "$DOWNLOADS_PATH" -name "*.kicad_sym" -exec cp {} "$PROJECT_PATH/symbols/" \;

# Copy footprint files
find "$DOWNLOADS_PATH" -name "*.kicad_mod" -exec cp {} "$PROJECT_PATH/footprints/" \;

# Copy 3D models
find "$DOWNLOADS_PATH" -name "*.step" -exec cp {} "$PROJECT_PATH/3dmodels/" \;

echo "Files copied. Remember to rename symbol files from timestamp format to descriptive names."
```

### Legacy Copy Script (for imports_source workflow)

```bash
cd "/path/to/project/Project_Libraries"
bash scripts/copy_imports.sh
```

The script will automatically:
- Copy all `.kicad_mod` files to `footprints/`
- Copy all `.kicad_sym` files to `symbols/`
- Copy all `.step` files to `3dmodels/`

## Combined Symbol Library

### Creating a Combined Library File

The project maintains a combined symbol library file that contains all individual symbols in one file for easy import into KiCad:

**Location**: `symbols/Project_Library.kicad_sym`

**To regenerate the combined library:**
```bash
cd "/path/to/project/Project_Libraries"
./scripts/combine_symbols.sh
```

This script:
- Combines all individual `.kicad_sym` files (except `Connector_Generic_MountingPin.kicad_sym` which is too large)
- Creates `Project_Library.kicad_sym` containing all project symbols
- Automatically runs when importing new components

**Usage in KiCad:**
1. Add `Project_Library.kicad_sym` to your project's symbol libraries
2. All project symbols will be available in one library instead of multiple individual files

### Example: BLM18PG221SN1D Import Process
1. Downloaded BLM18PG221SN1D.zip to ~/Downloads and extracted
2. Moved folder: `mv "/home/spencer/Downloads/BLM18PG221SN1D" "/home/spencer/Applications/KiCad/10k-Hour-Timer-RP2040/kicad/Project_Libraries/imports_source/"`
3. Ran script: `cd "/home/spencer/Applications/KiCad/10k-Hour-Timer-RP2040/kicad/Project_Libraries" && bash scripts/copy_imports.sh`
4. Components now available in project libraries
5. Combined library automatically updated