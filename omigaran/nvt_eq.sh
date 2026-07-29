# NVT equilibration

#!/bin/bash
# redirect stdout/stderr to a file
set -e
mkdir -p nvt_eq
{
    echo "NVT EQUILIBRATION"
    echo "DID YOU REMEBER??? DID YOU REMEBER??? to edit the .top file? :3"
    gmx grompp -f mdp_files/nvt_eq.mdp \
               -c em_sd/em.gro \
               -p structure/omigaran.top \
               -r em_sd/em.gro \
               -o nvt_eq/nvt.tpr
    # grompp: pre-processes the input files for GROMACS
    # -f : input mdp file (parameters for the simulation) <- In this case the parameters for NVT equilibration
    # -c : input structure file (.gro)
    # -p : input topology file (.top)
    # -r : reference structure file (.gro) for position restraints
    # -o : output file for the pre-processed input (.tpr)
    ##
    gmx mdrun -v -deffnm nvt_eq/nvt
    # mdrun: runs the simulation
    # -v : verbose output
    # -deffnm : default filename for input/output files (nvt_eq/nvt)
    ##
    echo "NVT EQUILIBRATION COMPLETE"
    echo "Plotting the temperature..."
    echo -e "Temperature" | gmx energy -f nvt_eq/nvt.edr -o nvt_eq/temperature.xvg
    python ploting.py --file nvt_eq/temperature.xvg --title "Temperature" --folder nvt_eq --rolling_average
} 2>&1 | tee nvt_eq/nvt_eq.log