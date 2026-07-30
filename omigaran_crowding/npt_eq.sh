# NVT equilibration

#!/bin/bash
# redirect stdout/stderr to a file
set -e
mkdir -p npt_eq
{
    echo "NPT EQUILIBRATION"
    echo "I hope you remembered to edit the .top file! :3"
    gmx grompp -f mdp_files/npt_eq.mdp \
               -c nvt_eq/nvt.gro \
               -p structures/omigaran_crowded.top \
               -r nvt_eq/nvt.gro \
               -o npt_eq/npt.tpr
    # grompp: pre-processes the input files for GROMACS
    # -f : input mdp file (parameters for the simulation) <- In this case the parameters for NPT equilibration
    # -c : input structure file (.gro)
    # -p : input topology file (.top)
    # -r : reference structure file (.gro) for position restraints
    # -o : output file for the pre-processed input (.tpr)
    ##
    gmx mdrun -v -deffnm npt_eq/npt
    # mdrun: runs the simulation
    # -v : verbose output
    # -deffnm : default filename for input/output files (npt_eq/npt)
    ##
    echo "NPT EQUILIBRATION COMPLETE"
    echo "Plotting the pressure..."
    echo -e "Pressure" | gmx energy -f npt_eq/npt.edr -o npt_eq/pressure.xvg
    python ploting.py --file npt_eq/pressure.xvg --title "Pressure" \
                      --folder npt_eq --rolling_average
    echo "Plotting the density..."
    echo -e "Density" | gmx energy -f npt_eq/npt.edr -o npt_eq/density.xvg
    python ploting.py --file npt_eq/density.xvg --title "Density" \
                      --folder npt_eq --rolling_average 
    echo "Finished NPT equilibration!"

} 2>&1 | tee npt_eq/npt_eq.log