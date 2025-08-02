#!/bin/bash
# KiCad Library Component Copy Script
# Copies components from KiCad system libraries to local project library
# Usage: ./copyKicadComponent <component_name> [symbol_library]

COMPONENT_NAME="$1"
SYMBOL_LIBRARY="$2"
PROJECT_PATH="/home/spencer/Applications/KiCad/10k-Hour-Timer-RP2040/kicad/Project_Libraries"
KICAD_LIB_PATH="/usr/share/kicad"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "copyKicadComponent - Copy KiCad library components to local project"
    echo ""
    echo "USAGE:"
    echo "  copyKicadComponent <component_name> [symbol_library]"
    echo "  copyKicadComponent -h | --help"
    echo ""
    echo "PARAMETERS:"
    echo "  component_name    Name or pattern to search for (required)"
    echo "  symbol_library    KiCad symbol library name (optional, auto-detect if not provided)"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help       Show this help message and exit"
    echo ""
    echo "EXAMPLES:"
    echo "  copyKicadComponent MountingHole_4mm              # Copy exact match only"
    echo "  copyKicadComponent MountingHole_4mm*             # Copy all MountingHole_4mm variants"
    echo "  copyKicadComponent MountingHole_4mm Mechanical   # Specify symbol library"
    echo "  copyKicadComponent USB_C_Receptacle Connector    # Copy USB-C connector"
    echo "  copyKicadComponent TestPoint_*                   # Copy all TestPoint variants"
    echo ""
    echo "DESCRIPTION:"
    echo "  This script copies components from KiCad system libraries to your local"
    echo "  project library. It will:"
    echo ""
    echo "    1. Search for footprints matching the component name/pattern"
    echo "    2. Copy matching footprints to local project library"
    echo "    3. Extract symbol from specified library (or auto-detect)"
    echo "    4. Add symbol to local project library"
    echo "    5. Regenerate combined symbol library"
    echo ""
    echo "  MATCHING BEHAVIOR:"
    echo "    - Without wildcards: Copies exact match only, shows additional matches"
    echo "    - With wildcards (*): Copies all matches for the pattern"
    echo "    - Smart symbol detection for common patterns (MountingHole_*, TestPoint_*)"
    echo ""
    echo "  The copied components will be available in your local KiCad project"
    echo "  and can be edited without affecting the system libraries."
    echo ""
    exit 1
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

if [ -z "$COMPONENT_NAME" ]; then
    echo -e "${RED}Error: Component name is required${NC}"
    usage
fi

echo -e "${BLUE}=== KiCad Library Component Copy Tool ===${NC}"
echo -e "${BLUE}Component: ${YELLOW}$COMPONENT_NAME${NC}"
echo -e "${BLUE}Symbol Library: ${YELLOW}${SYMBOL_LIBRARY:-"Auto-detect"}${NC}"
echo ""

# Function to copy footprints
copy_footprints() {
    echo -e "${BLUE}Searching for footprints...${NC}"
    
    # Check if component name contains wildcard characters
    if [[ "$COMPONENT_NAME" == *"*"* ]] || [[ "$COMPONENT_NAME" == *"?"* ]]; then
        # User explicitly used wildcards - use as-is
        echo -e "${BLUE}Using wildcard pattern: $COMPONENT_NAME${NC}"
        FOOTPRINT_FILES=$(find "$KICAD_LIB_PATH/footprints" -name "*${COMPONENT_NAME}*" -type f 2>/dev/null)
    else
        # No wildcards - check for exact and partial matches
        EXACT_FILES=$(find "$KICAD_LIB_PATH/footprints" -name "${COMPONENT_NAME}.kicad_mod" -type f 2>/dev/null)
        PARTIAL_FILES=$(find "$KICAD_LIB_PATH/footprints" -name "*${COMPONENT_NAME}*" -type f 2>/dev/null)
        
        # Count matches
        EXACT_COUNT=$(echo "$EXACT_FILES" | grep -c . 2>/dev/null || echo 0)
        PARTIAL_COUNT=$(echo "$PARTIAL_FILES" | grep -c . 2>/dev/null || echo 0)
        
        if [ "$EXACT_COUNT" -gt 0 ] && [ "$PARTIAL_COUNT" -gt "$EXACT_COUNT" ]; then
            # Found exact match but also additional partial matches
            echo -e "${YELLOW}Found exact match plus $((PARTIAL_COUNT - EXACT_COUNT)) additional matches:${NC}"
            echo -e "${GREEN}Exact match:${NC}"
            echo "$EXACT_FILES" | while read -r file; do
                [ -n "$file" ] && echo "  $(basename "$file")"
            done
            echo -e "${BLUE}Additional matches:${NC}"
            echo "$PARTIAL_FILES" | grep -v "${COMPONENT_NAME}.kicad_mod" | while read -r file; do
                [ -n "$file" ] && echo "  $(basename "$file")"
            done
            echo ""
            echo -e "${YELLOW}Copying only exact match. To copy all matches, use: ${COMPONENT_NAME}*${NC}"
            FOOTPRINT_FILES="$EXACT_FILES"
        elif [ "$PARTIAL_COUNT" -gt 0 ]; then
            # Only partial matches or exact match without additional matches
            FOOTPRINT_FILES="$PARTIAL_FILES"
        else
            FOOTPRINT_FILES=""
        fi
    fi
    
    if [ -z "$FOOTPRINT_FILES" ]; then
        echo -e "${YELLOW}No footprints found matching '$COMPONENT_NAME'${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Found footprints to copy:${NC}"
    echo "$FOOTPRINT_FILES" | while read -r file; do
        [ -n "$file" ] && basename "$file"
    done
    echo ""
    
    # Copy footprints
    echo -e "${BLUE}Copying footprints to local library...${NC}"
    echo "$FOOTPRINT_FILES" | while read -r file; do
        if [ -f "$file" ]; then
            cp "$file" "$PROJECT_PATH/footprints/"
            echo -e "${GREEN}Copied: $(basename "$file")${NC}"
        fi
    done
    
    return 0
}

# Function to find and extract symbol
copy_symbol() {
    local symbol_lib="$1"
    local symbol_name="$COMPONENT_NAME"
    
    echo -e "${BLUE}Searching for symbol...${NC}"
    
    # Smart symbol name detection for common patterns
    if [[ "$COMPONENT_NAME" == MountingHole_* ]]; then
        echo -e "${BLUE}Detected MountingHole pattern, searching for 'MountingHole' symbol...${NC}"
        symbol_name="MountingHole"
    elif [[ "$COMPONENT_NAME" == TestPoint_* ]]; then
        echo -e "${BLUE}Detected TestPoint pattern, searching for 'TestPoint' symbol...${NC}"
        symbol_name="TestPoint"
    elif [[ "$COMPONENT_NAME" == USB_C_* ]]; then
        echo -e "${BLUE}Detected USB-C pattern, searching for USB-C related symbols...${NC}"
        # Will search for the pattern as-is first, then fall back
    fi
    
    # If symbol library is specified, check that library
    if [ -n "$symbol_lib" ]; then
        SYMBOL_FILE="$KICAD_LIB_PATH/symbols/${symbol_lib}.kicad_sym"
        if [ ! -f "$SYMBOL_FILE" ]; then
            echo -e "${RED}Error: Symbol library '$symbol_lib.kicad_sym' not found${NC}"
            return 1
        fi
        
        # Try exact match first, then base pattern
        if grep -q "symbol \"$COMPONENT_NAME\"" "$SYMBOL_FILE" 2>/dev/null; then
            echo -e "${GREEN}Found exact symbol '$COMPONENT_NAME' in '$symbol_lib.kicad_sym'${NC}"
            extract_symbol "$SYMBOL_FILE" "$COMPONENT_NAME"
            return 0
        elif [ "$symbol_name" != "$COMPONENT_NAME" ] && grep -q "symbol \"$symbol_name\"" "$SYMBOL_FILE" 2>/dev/null; then
            echo -e "${GREEN}Found base symbol '$symbol_name' in '$symbol_lib.kicad_sym'${NC}"
            extract_symbol "$SYMBOL_FILE" "$symbol_name"
            return 0
        else
            echo -e "${YELLOW}Warning: Neither '$COMPONENT_NAME' nor '$symbol_name' found in '$symbol_lib.kicad_sym'${NC}"
            return 1
        fi
        
    else
        # Auto-detect: search all symbol libraries
        echo -e "${BLUE}Auto-detecting symbol library...${NC}"
        
        SYMBOL_LIBS=$(find "$KICAD_LIB_PATH/symbols" -name "*.kicad_sym" -type f)
        
        # Try exact match first
        for lib_file in $SYMBOL_LIBS; do
            if grep -q "symbol \"$COMPONENT_NAME\"" "$lib_file" 2>/dev/null; then
                lib_name=$(basename "$lib_file" .kicad_sym)
                echo -e "${GREEN}Found exact symbol '$COMPONENT_NAME' in '$lib_name.kicad_sym'${NC}"
                extract_symbol "$lib_file" "$COMPONENT_NAME"
                return 0
            fi
        done
        
        # If no exact match and we have a different base pattern, try that
        if [ "$symbol_name" != "$COMPONENT_NAME" ]; then
            for lib_file in $SYMBOL_LIBS; do
                if grep -q "symbol \"$symbol_name\"" "$lib_file" 2>/dev/null; then
                    lib_name=$(basename "$lib_file" .kicad_sym)
                    echo -e "${GREEN}Found base symbol '$symbol_name' in '$lib_name.kicad_sym'${NC}"
                    extract_symbol "$lib_file" "$symbol_name"
                    return 0
                fi
            done
        fi
        
        echo -e "${YELLOW}Warning: No matching symbol found for '$COMPONENT_NAME'${NC}"
        if [ "$symbol_name" != "$COMPONENT_NAME" ]; then
            echo -e "${YELLOW}Also searched for base pattern: '$symbol_name'${NC}"
        fi
        return 1
    fi
}

# Function to extract symbol from library file
extract_symbol() {
    local source_file="$1"
    local symbol_name="$2"
    local output_file="$PROJECT_PATH/symbols/${symbol_name}.kicad_sym"
    
    echo -e "${BLUE}Extracting symbol to standalone file...${NC}"
    
    # Create standalone symbol file
    cat > "$output_file" << EOF
(kicad_symbol_lib
	(version 20241209)
	(generator "kicad_symbol_editor")
	(generator_version "9.0")
EOF
    
    # Extract the symbol definition and append to file
    grep -A 1000 "symbol \"$symbol_name\"" "$source_file" | \
    grep -B 1000 -m 1 "embedded_fonts no" | \
    sed '$d' >> "$output_file"
    
    # Close the symbol library
    echo -e "\t\t(embedded_fonts no)\n\t)\n)" >> "$output_file"
    
    if [ -f "$output_file" ]; then
        echo -e "${GREEN}Created: $(basename "$output_file")${NC}"
        
        # Add to combined library
        add_to_combined_library "$source_file" "$symbol_name"
    else
        echo -e "${RED}Error: Failed to create symbol file${NC}"
        return 1
    fi
}

# Function to add symbol to combined library
add_to_combined_library() {
    local source_file="$1"
    local symbol_name="$2"
    local combined_file="$PROJECT_PATH/symbols/Project_Library.kicad_sym"
    
    echo -e "${BLUE}Adding symbol to combined library...${NC}"
    
    # Check if symbol already exists in combined library
    if grep -q "symbol \"$symbol_name\"" "$combined_file" 2>/dev/null; then
        echo -e "${YELLOW}Symbol '$symbol_name' already exists in combined library${NC}"
        return 0
    fi
    
    # Create a temporary file with the symbol definition
    local temp_symbol=$(mktemp)
    grep -A 1000 "symbol \"$symbol_name\"" "$source_file" | \
    grep -B 1000 -m 1 "embedded_fonts no" >> "$temp_symbol"
    
    # Insert the symbol before the final closing parenthesis
    sed -i '$d' "$combined_file"  # Remove last line
    echo -e "\t$(cat "$temp_symbol")" >> "$combined_file"
    echo ")" >> "$combined_file"
    
    rm "$temp_symbol"
    echo -e "${GREEN}Added '$symbol_name' to combined library${NC}"
}

# Main execution
echo -e "${BLUE}Starting component copy process...${NC}"
echo ""

# Copy footprints
copy_footprints
FOOTPRINT_SUCCESS=$?

# Copy symbol
copy_symbol "$SYMBOL_LIBRARY"
SYMBOL_SUCCESS=$?

echo ""
echo -e "${BLUE}=== Summary ===${NC}"

if [ $FOOTPRINT_SUCCESS -eq 0 ]; then
    echo -e "${GREEN}✓ Footprints copied successfully${NC}"
else
    echo -e "${YELLOW}⚠ No footprints found or copied${NC}"
fi

if [ $SYMBOL_SUCCESS -eq 0 ]; then
    echo -e "${GREEN}✓ Symbol copied successfully${NC}"
    
    # Regenerate combined library
    echo -e "${BLUE}Regenerating combined symbol library...${NC}"
    if [ -x "$PROJECT_PATH/scripts/combine_symbols.sh" ]; then
        "$PROJECT_PATH/scripts/combine_symbols.sh"
    fi
else
    echo -e "${YELLOW}⚠ Symbol not found or copied${NC}"
fi

echo ""
echo -e "${BLUE}Files now available in local project library:${NC}"

# List copied footprints
echo -e "${BLUE}Footprints:${NC}"
find "$PROJECT_PATH/footprints" -name "*${COMPONENT_NAME}*" -type f | while read -r file; do
    echo -e "  ${GREEN}$(basename "$file")${NC}"
done

# List symbol file
if [ -f "$PROJECT_PATH/symbols/${COMPONENT_NAME}.kicad_sym" ]; then
    echo -e "${BLUE}Symbol:${NC}"
    echo -e "  ${GREEN}${COMPONENT_NAME}.kicad_sym${NC}"
fi

echo ""
echo -e "${GREEN}Component copy completed!${NC}"