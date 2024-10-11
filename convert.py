import tkinter as tk
from tkinter import filedialog
import os

# setup top-level widget
widget = tk.Tk()
widget.withdraw()  # Hide the root window

# ask for rawdata directory
dirRoot = filedialog.askdirectory(
    title = "",
    initialdir="Z:/Ryan/raw/")
print(f"dirRoot = {dirRoot}")

if dirRoot == "":
    print("No folder selected")
    exit(-1)
    
# search for all rawdata
lstRawdata = []
for dirRoot, lstDir, lstFile in os.walk(dirRoot):
    for file in lstFile:
        if file.endswith(".raw"):
            lstRawdata.append(os.path.join(dirRoot.replace("\\", "/"), file))

if len(lstRawdata) == 0:
    print("No rawdata found")
    exit(-1)

# convert all rawdata to .h5 file
pathCurFile = os.path.abspath(__file__)
pathCurDir = os.path.dirname(pathCurFile).replace("\\", "/")
if pathCurDir[-1] != '/': pathCurDir += "/"

for fileIn in lstRawdata:
    head = os.path.dirname(fileIn)
    if head[-1] != '/': head += "/"

    exe = os.path.join(pathCurDir, "UIHRawdata2ISMRMRD_v240808/uih-raw-2-ismrmrd.exe")
    xslt = os.path.join(pathCurDir, "UIHRawdata2ISMRMRD_v240808/prot_convert_default.xslt")
    fileOut = f"{head}raw.h5"
    os.system(f"{exe} -f \"{fileIn}\" -x \"{xslt}\" -o \"{fileOut}\"")
