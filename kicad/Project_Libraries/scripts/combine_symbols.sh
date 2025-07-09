#!/bin/bash
# KiCad Symbol Library Combiner Script
# Combines all individual .kicad_sym files into one project library file

PROJECT_PATH="/home/spencer/Applications/KiCad/10k-Hour-Timer-RP2040/kicad/Project_Libraries"
SYMBOLS_DIR="$PROJECT_PATH/symbols"
OUTPUT_FILE="$SYMBOLS_DIR/Project_Library.kicad_sym"

echo "Combining individual symbol files into project library..."

# Start with the library header
cat > "$OUTPUT_FILE" << 'EOF'
(kicad_symbol_lib (version 20211014) (generator kicad_symbol_editor)
EOF

# Process each individual symbol file (excluding the combined library and generic connector)
for symbol_file in "$SYMBOLS_DIR"/*.kicad_sym; do
    # Skip the output file itself and the large generic connector file
    if [[ "$symbol_file" == "$OUTPUT_FILE" || "$symbol_file" == *"Connector_Generic_MountingPin"* ]]; then
        continue
    fi
    
    # Check if file exists and is readable
    if [[ -f "$symbol_file" && -r "$symbol_file" ]]; then
        filename=$(basename "$symbol_file")
        echo "  Adding symbols from: $filename"
        
        # Extract symbol definitions (skip the header and footer)
        sed -n '/^  (symbol /,/^  )$/p' "$symbol_file" >> "$OUTPUT_FILE"
    fi
done

# Close the library
echo ")" >> "$OUTPUT_FILE"

echo "Combined symbol library created: $OUTPUT_FILE"
echo ""
echo "Library contains symbols from:"
ls -1 "$SYMBOLS_DIR"/*.kicad_sym | grep -v "Project_Library.kicad_sym" | grep -v "Connector_Generic_MountingPin" | xargs -I {} basename {} | sed 's/^/  - /'
echo ""
echo "To use in KiCad, add this library file to your project symbol libraries."