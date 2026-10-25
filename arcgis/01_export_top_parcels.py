"""Export the top-N scored parcels from PostGIS (via .sde) to a file geodatabase
and export a PDF map of them.
Run with the Python from ArcGIS Pro (Python Command Prompt), not system Python."""
import os
import arcpy
arcpy.env.overwriteOutput = True
# ---------- 1. ----------
SDE_FILE = r"C:\Users\Admin\Documents\ArcGIS\Projects\dzialki_radomysl\dzialki_radomysl(1).sde"
# feature class name, as shown in Catalog
SOURCE_FC = SDE_FILE + r"\dzialki_radomysl.analysis.parcel_score"
# path to the ArcGIS Pro project (.aprx)
APRX_FILE = r"C:\Users\Admin\Documents\ArcGIS\Projects\dzialki_radomysl\dzialki_radomysl.aprx"
# path to dzialki_radomysl.gdb
OUT_GDB = r"C:\Users\Admin\Documents\ArcGIS\Projects\dzialki_radomysl\dzialki_radomysl.gdb"
OUT_FC = "top_parcels"
# e.g. a folder in your repo's docs/ + file name .pdf
OUT_PDF = r"C:\LPA\Projects\parce-scoring-radomysl\parcel-scoring-radomysl\docs\result.pdf"
TOP_N = 50

# ---------- 2. Check that the source exists ----------

if not arcpy.Exists(SOURCE_FC):
    raise SystemExit(
        "Source feature class not found. Check SDE_FILE and SOURCE_FC.")

# ---------- 3. Export the best parcels to the geodatabase ----------

where = f"score_rank <= {TOP_N}"

out_path = os.path.join(OUT_GDB, OUT_FC)

export = arcpy.conversion.ExportFeatures(SOURCE_FC, out_path, where)

# ---------- 4. Report how many parcels were exported ----------
count = arcpy.management.GetCount(out_path)[0]
print(f"Exported {count} parcels to {out_path}")


# ---------- 5. Add the layer to the project map and export a PDF ----------
aprx = arcpy.mp.ArcGISProject(APRX_FILE)

#       map_obj.addDataFromPath(out_path)

map_obj = aprx.listMaps()[0]

map_obj.addDataFromPath(out_path)
#       layout.exportToPDF(OUT_PDF, resolution=150)
layout = aprx.listLayouts()[0]
layout.exportToPDF(OUT_PDF, resolution=150)

print(f"PDF saved to {OUT_PDF}")
