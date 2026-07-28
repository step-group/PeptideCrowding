# NVT equilibration

#!/bin/bash
# redirect stdout/stderr to a file
set -e
mkdir -p npt_eq
{
echo "NPT EQUILIBRATION"
echo "I hope you remembered to edit the .top file! :3"
gmx grompp -f mdp_files/npt_eq.mdp -c nvt_eq/nvt.gro -p structure/omigaran.top -r nvt_eq/nvt.gro -o npt_eq/npt.tpr
##
gmx mdrun -v -deffnm npt_eq/npt
##
echo "NPT EQUILIBRATION COMPLETE"
echo "Plotting the pressure..."
echo -e "Pressure" | gmx energy -f npt_eq/npt.edr -o npt_eq/pressure.xvg
python ploting.py --file npt_eq/pressure.xvg --title "Pressure" --folder npt_eq --rolling_average
echo "Plotting the density..."
echo -e "Density" | gmx energy -f npt_eq/npt.edr -o npt_eq/density.xvg
python ploting.py --file npt_eq/density.xvg --title "Density" --folder npt_eq --rolling_average 
echo "Finished NPT equilibration!"

} 2>&1 | tee npt_eq/npt_eq.log