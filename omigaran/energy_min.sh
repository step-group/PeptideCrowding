
#!/bin/bash
# redirect stdout/stderr to a file
set -e
mkdir -p em_sd
{
echo "ENERGY MINIMIZATION WITH STEEPES DESCENT"
gmx grompp -f mdp_files/em_sd.mdp -c structure/omigaran.gro -p structure/omigaran.top -o em_sd/em.tpr
gmx mdrun -v -deffnm em_sd/em
### get energy

echo "ENERGY MINIMIZATION COMPLETE"
echo -e "Potential" | gmx energy -f em_sd/em.edr -o em_sd/potential.xvg
# Plot the energy
python ploting.py --file em_sd/potential.xvg --title "Potential Energy" --folder em_sd --log_scale

} 2>&1 | tee nvt_eq/em_sd.log