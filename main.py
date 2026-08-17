import os
import subprocess

# constants
pathCurFile = os.path.abspath(__file__)
pathCurDir = os.path.dirname(pathCurFile)
if pathCurDir[-1] != '/': pathCurDir += "/"

exeV4 = os.path.join(pathCurDir, "UIHRaw2ISMRMRD_v4_251205/uih-raw-2-ismrmrd.exe")
xsltV4 = os.path.join(pathCurDir, "UIHRaw2ISMRMRD_v4_251205/prot_convert_default.xslt")

exeV5 = os.path.join(pathCurDir, "UIHRaw2ISMRMRD_v5_260506/uih-raw-2-ismrmrd.exe")
xsltV5 = os.path.join(pathCurDir, "UIHRaw2ISMRMRD_v5_260506/prot_convert_default.xslt")

# prompt for root dir
dirRoot = input("root: ")

if dirRoot == "":
    print("No folder selected")
    exit(-1)
    
# search for all raw file
lstRaw = []
for dirRoot, lstDir, lstFile in os.walk(dirRoot):
    for file in lstFile:
        if file.find("PAL")!=-1: # calib file
            continue # skip calib file
        elif file.endswith(".raw"): # v4 file
            _file = os.path.join(dirRoot, file)
            lstRaw.append((_file, 4))
            break # one valid raw file per folder assumed
        elif file.find(".raw.part")!=-1: # v5 file
            _file = os.path.join(dirRoot, file)
            lstRaw.append((_file, 5))
            break # one valid raw file per folder assumed

if len(lstRaw) == 0:
    print("No raw file found")
    exit(-1)

# convert all raw file to .h5 file
try:
    for fileIn, ver in lstRaw:
        print("="*64)
        head = os.path.dirname(fileIn)
        if head[-1] != '/': head += "/"

        fileOut = f"{head}raw.h5"
        if ver==4: exe, xslt = exeV4, xsltV4
        elif ver==5: exe, xslt = exeV5, xsltV5
        else: raise RuntimeError("ver")

        exe = exe.replace("\\", "/")
        fileIn = fileIn.replace("\\", "/")
        xslt = xslt.replace("\\", "/")
        fileOut = fileOut.replace("\\", "/")
        cmd = [exe, "-f", fileIn, "-x", xslt, "-o", fileOut]
        if 1: subprocess.run(cmd, check=True)
        else: print(cmd)
        print("="*64)
        print("\n")
except Exception as e:
    print(e)
    while 1: pass
finally:
    print("[INFO] Complete")
    input("Press Enter to exit ...")
    