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