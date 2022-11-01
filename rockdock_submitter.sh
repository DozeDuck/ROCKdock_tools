
cd dock_output
for i in set_*
do
cd $i
sbatch set_Dock_*.sh
cd ..
done


