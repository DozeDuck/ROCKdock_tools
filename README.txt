RockDock – How to use it

Rockdock is a pipeline wrapper that controls submissions of ultra-large libraries for SLURM job managers (i.e. Rocket HPC) that submits, 
ranks and sort molecules. The application uses openbabel, Seesar and Dock6.  The flowchart depicted in figure 1 shows how the docking procedure 
is done within the rockdock scaffold.
1 – Preparation 
Dock6 is used for pose generation. The preparation for setup is done via the default flexible docking protocols explained on the dock6 website. 
All these steps use the dock6 tools. All this process should be done inside the folder named input_location (in bold are the names required by rockdock – 
so when preparing the input use the names in bold):

-	Preparation of the surface file (surface.dms), receptor files with charges (receptor.mol2), a receptor in pdb format for Hyde 
(receptor.pdb) and a ligand center to define the binding site (center.mol2)
-	Creating the spheres for docking suing sphgen: an example input file (INSPH) using the default naming.
-	Selection of binding site spheres – using sphere_selector: this step should generate a selected sphere set that will 
guide your docking (the selected spheres will be named selected_spheres.sph)
-	Generation of the docking box using showbox. Using the previous files, this step will generate a box named box.pdb
-	Generate the grid: generate the grid using the box that surrounds the binding site. Please use the grid.in input file 
located in the input_location folder – this will generate a set of files with the prefix grid (grid.nrg and grid.bmp)

If you want more control over each tranche submission, add your email to the lines “#SBATCH --mail-user=” inside the rockdock_prep.

With he generated input files located in the input_location folder and a selected ligand library in a mol2 format, you can prepare the submission by running : 

	./rockdock_prep  <lib.mol2>  < the number of molecules per thread>
	
This step will generate a new folder (dock_output). This folder will have a series of folders with separated sets for docking – 
each will be used to a single thread (called a submission tranche)
In sequence, for submission of the pose generation via Dock6, run

	./rockdock_submitter.sh
	
This script will submit n tranches ( n = (number of molecules in your library)/(size of the tranche)), each to a single thread. 

With this stage finished, you have two options: 1) rescore using Hyde a subset of the generated poses 2) rescore all generated poses using Hyde.

	Option 1) Subset from dock6
To generate a subset of dock6 output molecules, you first need to generate a concatenated set of all molecules generated within the dock_output folder. This can be done via:

	cat “submission_folder”/dock_output/set_*/flex*mol2 > dock6_fullposes.mol2
	
Inside the tools folder, a script called “ dock6filter” can generate a sorted subset of the generated poses. To use this script, do:

dock6filter -i dock6_fullposes.mol2 -o dock6_top_subset.mol2 -r (gscore or cluster) -n (number of molecules in the subset – usually 1000)

 If you use gscore, you will sort molecules by the lowest AMBER interaction energies calculated by dock6. If you use cluster, it will sort by the cluster size of the pose.
 
Option 2) Rescore all generated poses using Hyde.

If you want to rescore and sort all poses using Hyde (which is time consuming per molecule), you can run.

	./rockdock_rescorer
	
This command will submit a hyde scorer job per generated tranche.
After all, tranches are finished, you may want to sort the generated sdf files to evaluate the top n-th molecules. Similar to dock6filter, there is a script inside the tools folder named seesar_filter.
To use it, first generate the concatenated lib for all molecules after hyde scoring using 

	cat “submission_folder”/dock_output/set_*/flex*sdf  > seesar_rescore_fullposes.sdf

	seesar_filter -i seesar_rescore_fullposes.sdf -o seesar_rescore_subset.sdf  -n (number of molecules in the subset – usually 1000)



RockDock – 如何使用它

Rockdock 是一个管道包装器，用于控制 SLURM 作业管理器（即 Rocket HPC）提交的超大型库的提交，
对分子进行排序和排序。该应用程序使用 openbabel、Seesar 和 Dock6。图 1 中描绘的流程图显示了对接程序如何
是在rockdock 脚手架内完成的。
1 – 准备
Dock6 用于姿势生成。安装准备是通过dock6 网站上解释的默认灵活对接协议完成的。
所有这些步骤都使用了dock6 工具。所有这些过程都应该在名为 input_location 的文件夹中完成（粗体是 Rockdock 所需的名称 -
因此在准备输入时使用粗体名称）：

- 准备表面文件 (surface.dms)、带电荷的受体文件 (receptor.mol2)、海德的 pdb 格式的受体
(receptor.pdb) 和定义结合位点的配体中心 (center.mol2)
- 创建用于对接起诉 sphgen 的球体：使用默认命名的示例输入文件 (INSPH)。
- 选择结合位点球体——使用 sphere_selector：这一步应该生成一个选定的球体集，它将
引导您的对接（选定的球体将命名为 selected_spheres.sph）
- 使用 showbox 生成对接框。使用前面的文件，这一步会生成一个名为 box.pdb 的框
- 生成网格：使用围绕绑定站点的框生成网格。请使用 grid.in 输入文件
位于 input_location 文件夹中——这将生成一组带有 grid 前缀的文件（grid.nrg 和 grid.bmp）

如果您想对每个批次提交进行更多控制，请将您的电子邮件添加到 Rockdock_prep 中的“#SBATCH --mail-user=”行。

使用位于 input_location 文件夹中的生成输入文件和 mol2 格式的选定配体库，您可以通过运行以下命令准备提交：

./rockdock_prep <lib.mol2> <每个线程的分子数>

这一步将生成一个新文件夹（dock_output）。该文件夹将有一系列文件夹，其中包含用于对接的分隔集 -
每个将用于单个线程（称为提交部分）
按顺序，为了通过 Dock6 提交姿势生成，运行

./rockdock_submitter.sh

该脚本将提交 n 个批次（n =（您库中的分子数）/（批次的大小）），每个批次都发送到一个线程。

完成此阶段后，您有两个选择：1) 使用 Hyde 对生成的姿势的子集重新评分 2) 使用 Hyde 对所有生成的姿势重新评分。

选项 1）dock6 的子集
要生成dock6 输出分子的子集，您首先需要生成dock_output 文件夹中生成的所有分子的串联集。这可以通过：

猫“submission_folder”/dock_output/set_*/flex*mol2 >dock6_fullposes.mol2

在工具文件夹内，一个名为“dock6filter”的脚本可以生成已生成姿势的排序子集。要使用此脚本，请执行以下操作：

dock6filter -i dock6_fullposes.mol2 -o dock6_top_subset.mol2 -r（gscore 或 cluster）-n（子集中的分子数 - 通常为 1000）

 如果您使用 gscore，您将按照由dock6 计算出的最低琥珀色相互作用能对分子进行排序。如果使用集群，它将按姿势的集群大小进行排序。
 
选项 2) 使用 Hyde 对所有生成的姿势重新评分。

如果您想使用 Hyde（每个分子很耗时）对所有姿势进行重新评分和排序，您可以运行。

./rockdock_rescorer

此命令将为每个生成的部分提交一个 hyde scorer 作业。
毕竟，批次已完成，您可能希望对生成的 sdf 文件进行排序以评估前 n 个分子。和dock6filter类似，tools文件夹里面有个脚本叫做seesar_fil
三。
要使用它，首先使用 hyde 评分后为所有分子生成连接的库

猫“submission_folder”/dock_output/set_*/flex*sdf > seesar_rescore_fullposes.sdf

seesar_filter -i seesar_rescore_fullposes.sdf -o seesar_rescore_subset.sdf -n（子集中的分子数 - 通常为 1000）
