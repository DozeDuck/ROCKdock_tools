total_mol=`more $1 | grep Hydescorer | wc -l`
./seesar_score_ranker.sh $1 $total_mol

/usr/bin/obabel *$total_mol* -O seesar_rescore_subset.mol2
awk '/@<TRIPOS>MOLECULE/{getline a;print a}' seesar_rescore_subset.mol2 > ranked_name
# TOTAL_MOL=`more ranked_name | wc -l`

for i in `seq 1 $total_mol`
do 
	touch ranked_name_list
	name=`sed -n "$i p" ranked_name `
	if [ `grep -c "$name" ranked_name_list` -ne '0' ]
	then 
		echo " $name has been added to name list"
	else 
		echo $name >> ranked_name_list
	fi
done

rm ranked_name seesar_rescore_subset.mol2 seesar_rescore_subset_top_$total_mol*
