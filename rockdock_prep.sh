MOL_PER_RUN=$2
mkdir dock_output
/usr/bin/obabel -imol2 $1 -O dock_output/separated.mol2 -m
TOTAL_MOL=`more $1 | grep MOL | wc -l`
cd dock_output
for i in `seq 0 $(($TOTAL_MOL/$MOL_PER_RUN))`
do
mkdir set_$i
cd set_$i
for MOL in `seq $((($i)*$MOL_PER_RUN)) $((($i+1)*$MOL_PER_RUN))`
do

more ../separated$MOL.mol2 >> set_$i.mol2
done
echo "conformer_search_type                                        flex
user_specified_anchor                                        no
write_conformations                                          no
calculate_rmsd                                               no
limit_max_anchors                                            no
min_anchor_size                                              5
pruning_use_clustering                                       yes
pruning_max_orients                                          1000
pruning_clustering_cutoff                                    100
pruning_conformer_score_cutoff                               100.0
pruning_conformer_score_scaling_factor                       1.0
use_clash_overlap                                            no
write_growth_tree                                            no
use_internal_energy                                          yes
internal_energy_rep_exp                                      12
internal_energy_cutoff                                       100.0
ligand_atom_file                                             set_$i.mol2
limit_max_ligands                                            no
skip_molecule                                                no
read_mol_solvation                                           no
use_database_filter                                          no
orient_ligand                                                yes
automated_matching                                           yes
receptor_site_file                                           ../../input_location/selected_spheres.sph
max_orientations                                             100
critical_points                                              no
chemical_matching                                            no
use_ligand_spheres                                           no
bump_filter                                                  no
score_molecules                                              yes
contact_score_primary                                        no
contact_score_secondary                                      no
grid_score_primary                                           yes
grid_score_secondary                                         no
grid_score_rep_rad_scale                                     1
grid_score_vdw_scale                                         1
grid_score_es_scale                                          1
grid_score_grid_prefix                                       ../../input_location/grid
multigrid_score_secondary                                    no
dock3.5_score_secondary                                      no
continuous_score_secondary                                   no
footprint_similarity_score_secondary                         no
pharmacophore_score_secondary                                no
descriptor_score_secondary                                   no
gbsa_zou_score_secondary                                     no
gbsa_hawkins_score_secondary                                 no
SASA_score_secondary                                         no
amber_score_secondary                                        no
minimize_ligand                                              yes
minimize_anchor                                              yes
minimize_flexible_growth                                     yes
use_advanced_simplex_parameters                              no
simplex_max_cycles                                           2
simplex_score_converge                                       0.1
simplex_cycle_converge                                       1.5
simplex_trans_step                                           1.5
simplex_rot_step                                             0.2
simplex_tors_step                                            15
simplex_anchor_max_iterations                                100
simplex_grow_max_iterations                                  100
simplex_grow_tors_premin_iterations                          0
simplex_random_seed                                          0
simplex_restraint_min                                        no
atom_model                                                   all
vdw_defn_file                                                ../../parameters/vdw_AMBER_parm99.defn
flex_defn_file                                               ../../parameters/flex.defn
flex_drive_file                                              ../../parameters/flex_drive.tbl
ligand_outfile_prefix                                        flex.out
write_orientations                                           no
num_scored_conformers                                        10
cluster_conformations                                        yes
cluster_rmsd_threshold                                       2.5
rank_ligands                                                 no" > flex.in
echo "#!/bin/bash
# example MPI+OpenMP job script for SLURM
#
# Tell SLURM which project's account to use:
#SBATCH -A abnffidp
#
#
# SLURM defaults to the directory you were working in when you submitted the job.
# Output files are also put in this directory. To set a different working directory add:
#
#
#SBATCH --mail-type=END
#SBATCH --mail-user=s.xu24@newcastle.ac.uk
# Tell SLURM if you want to be emailed when your job starts, ends, etc.
# Currently mail can only be sent to addresses @ncl.ac.uk
#
#
# This example has 4 MPI tasks, each with 22 cores
#
# number of tasks
#SBATCH  --nodes=1
#SBATCH  --ntasks=1
# number of cores per task
#SBATCH -c 1
# use Intel programming tools
#SBATCH -t 48:00:00
#
# set the \$OMP_NUM_THREADS variable
ompthreads=\$SLURM_CPUS_PER_TASK
export OMP_NUM_THREADS=\$ompthreads
#
# SLURM recommend using srun instead of mpirun for better job control.
../../bin/dock6 -i flex.in " > set_Dock_$i.sh
echo "#!/bin/bash
# example MPI+OpenMP job script for SLURM
#
# Tell SLURM which project's account to use:
#SBATCH -A abnffidp
#
#
# SLURM defaults to the directory you were working in when you submitted the job.
# Output files are also put in this directory. To set a different working directory add:
#
#
#SBATCH --mail-type=END
#SBATCH --mail-user=s.xu24@newcastle.ac.uk
# Tell SLURM if you want to be emailed when your job starts, ends, etc.
# Currently mail can only be sent to addresses @ncl.ac.uk
#
#
# This example has 4 MPI tasks, each with 22 cores
#
# number of tasks
#SBATCH  --nodes=1
#SBATCH  --ntasks=1
# number of cores per task
#SBATCH -c 1
# use Intel programming tools
#SBATCH -t 48:00:00
#
# set the \$OMP_NUM_THREADS variable
ompthreads=\$SLURM_CPUS_PER_TASK
export OMP_NUM_THREADS=\$ompthreads
#
# SLURM recommend using srun instead of mpirun for better job control.
../../bin/hydescorer -i flex.out_scored.mol2 -p ../../input_location/receptor.pdb -r ../../input_location/center.mol2 -o scored_seesar_$i.sdf --thread-count 1  " > set_Score_$i.sh
cd ..
done
rm separated*mol2
