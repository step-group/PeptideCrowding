#!/bin/bash
# MD production run of omigaran + post-processing (trajectory fixing, RMSD, Rg)
set -eo pipefail


{
    # Fix periodicity: make molecules whole and center on the peptide
    echo "Protein System" | gmx trjconv -s md_sym/md.tpr \
        -f md_sym/md.xtc \
        -o md_sym/md_center.xtc \
        -pbc mol -center
    # trjconv: correct for periodic boundary conditions (PBC)
    # -s : input structure + mass file (.tpr)
    # -f : input trajectory file (.xtc)
    # -o : output trajectory file (.xtc)
    # -pbc mol : make molecules whole (no broken molecules across PBC)
    # -center : center the system on the peptide (first group) and put solvent around

    # Extract the last frame
    echo "System" | gmx trjconv -s md_sym/md.tpr \
        -f md_sym/md_center.xtc \
        -o md_sym/md_last_frame.gro -dump 999999
    
    # trjconv: correct for periodic boundary conditions (PBC)
    # -s : input structure + mass file (.tpr)
    # -f : input trajectory file (.xtc)
    # -o : output trajectory file (.xtc)
    # -dump 999999 : extract the last frame of the trajectory (at 999999 ps)
    # echo "System" to get the whole system (peptide + solvent) in the output file

    echo "Protein" | gmx trjconv -s md_sym/md.tpr -f md_sym/md_last_frame.gro \
    -o omiganan_crowded_final.pdb

    # same as before but echo "Protein" to get only the peptide in the output file.

    # RMSD: root mean square deviation
    echo "Backbone Backbone" | gmx rms -s md_sym/md.tpr \
        -f md_sym/md_center.xtc \
        -o md_sym/rmsd.xvg -tu ns
    # -s : input structure + mass file (.tpr)
    # -f : input trajectory file (.xtc)
    # -o : output file for RMSD values (.xvg)
    # -tu ns : time unit for output (ns)

    # Radius of gyration
    echo "Protein" | gmx gyrate -s md_sym/md.tpr \
        -f md_sym/md_center.xtc \
        -o md_sym/gyrate.xvg
    # -s : input structure + mass file (.tpr)
    # -f : input trajectory file (.xtc)
    # -o : output file for radius of gyration values (.xvg)

    # Plotting the RMSD and radius of gyration
    python ploting.py --file md_sym/rmsd.xvg --title "RMSD" --folder md_sym
    python ploting.py --file md_sym/gyrate.xvg --title "Radius_of_Gyration" --folder md_sym --cols 1 2 3 4

    # compress the md_sym folder to save space
    tar --exclude=".*" -czvf md_sym.tar.gz md_sym
} 2>&1 | tee md_sym/md_sym_postprocess.log