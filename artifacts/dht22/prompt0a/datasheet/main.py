import pymupdf4llm
import sys

inputfile = sys.argv[1]
outputfile = sys.argv[2]

# Convert datasheet: Drop diagrams AND strip headers/footers
md_text = pymupdf4llm.to_markdown(
    inputfile,
    # 1. Eliminate Clutter & Layout Noise
    header=False,            # Disables top headers/titles
    footer=False,            # Disables bottom footers/page numbers
    
    # 2. Ignore Diagrams (from previous step)
    write_images=False,      
    ignore_images=True,      
    ignore_graphics=True,    
    force_text=True          
)

# Save clean datasheet content
with open(outputfile, "w", encoding="utf-8") as f:
    f.write(md_text)

