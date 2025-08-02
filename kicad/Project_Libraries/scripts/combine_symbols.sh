#!/bin/bash
# KiCad Symbol Library Combiner Script
# Combines all individual .kicad_sym files into one project library file
# Only appends new symbols that don't already exist in the combined library
# Deletes individual symbol files after successful combination

PROJECT_PATH="/home/spencer/Applications/KiCad/10k-Hour-Timer-RP2040/kicad/Project_Libraries"
SYMBOLS_DIR="$PROJECT_PATH/symbols"
OUTPUT_FILE="$SYMBOLS_DIR/Project_Library.kicad_sym"
TEMP_FILE="$OUTPUT_FILE.tmp"

echo "Combining individual symbol files into project library..."

# Check if combined library already exists and create backup
if [[ -f "$OUTPUT_FILE" ]]; then
    echo "Existing combined library found. Creating backup..."
    
    # Create timestamp for backup filename
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_FILE="$SYMBOLS_DIR/Archive/Project_Library_backup_$TIMESTAMP.kicad_sym"
    
    # Ensure Archive directory exists
    mkdir -p "$SYMBOLS_DIR/Archive"
    
    # Create backup
    cp "$OUTPUT_FILE" "$BACKUP_FILE"
    echo "  Backup created: $(basename "$BACKUP_FILE")"
    
    echo "Checking for new symbols to add..."
    # Copy existing library to temp file (without closing parenthesis)
    head -n -1 "$OUTPUT_FILE" > "$TEMP_FILE"
else
    echo "Creating new combined library..."
    # Start with the library header
    cat > "$TEMP_FILE" << 'EOF'
(kicad_symbol_lib (version 20211014) (generator kicad_symbol_editor)
EOF
fi

# Array to track files that were successfully processed
processed_files=()

# Process each individual symbol file (excluding the combined library and generic connector)
# Only process files directly in symbols directory, not subdirectories
for symbol_file in "$SYMBOLS_DIR"/*.kicad_sym; do
    # Skip files in subdirectories
    if [[ "$(dirname "$symbol_file")" != "$SYMBOLS_DIR" ]]; then
        continue
    fi
    # Skip the output file itself and the large generic connector file
    if [[ "$symbol_file" == "$OUTPUT_FILE" || "$symbol_file" == *"Connector_Generic_MountingPin"* ]]; then
        continue
    fi
    
    # Check if file exists and is readable
    if [[ -f "$symbol_file" && -r "$symbol_file" ]]; then
        filename=$(basename "$symbol_file")
        
        # Extract symbol names from the individual file
        symbol_names=$(grep -o '(symbol "[^"]*"' "$symbol_file" | sed 's/(symbol "//; s/"//')
        
        # Check if any of these symbols already exist in the combined library
        new_symbols_found=false
        for symbol_name in $symbol_names; do
            if [[ -f "$OUTPUT_FILE" ]] && grep -q "(symbol \"$symbol_name\"" "$OUTPUT_FILE"; then
                echo "  Symbol '$symbol_name' already exists in combined library, skipping"
            else
                new_symbols_found=true
                break
            fi
        done
        
        # Only add if we found new symbols
        if [[ "$new_symbols_found" == true ]]; then
            echo "  Adding new symbols from: $filename"
            
            # Extract symbol definitions (skip the header and footer)
            symbol_content=$(sed -n '/^  (symbol /,/^  )$/p' "$symbol_file")
            
            # Only proceed if we actually extracted content
            if [[ -n "$symbol_content" ]]; then
                echo "$symbol_content" >> "$TEMP_FILE"
                # Mark file for deletion only after successful content extraction
                processed_files+=("$symbol_file")
            else
                echo "  Warning: No symbol content found in $filename, skipping deletion"
            fi
        else
            echo "  All symbols from $filename already exist in combined library"
            # Still mark for deletion since symbols are already in combined library
            processed_files+=("$symbol_file")
        fi
    fi
done

# Close the library
echo ")" >> "$TEMP_FILE"

# Replace the original file with the updated one
mv "$TEMP_FILE" "$OUTPUT_FILE"

# Delete individual symbol files that were successfully processed
if [[ ${#processed_files[@]} -gt 0 ]]; then
    echo ""
    echo "Deleting individual symbol files (symbols now in combined library):"
    for file in "${processed_files[@]}"; do
        filename=$(basename "$file")
        echo "  Deleting: $filename"
        rm "$file"
    done
fi

echo ""
echo "Combined symbol library updated: $OUTPUT_FILE"
echo ""
echo "To use in KiCad, add this library file to your project symbol libraries."
echo "Individual symbol files have been removed to prevent accidental overwrites."