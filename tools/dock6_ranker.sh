more $1 | grep "##########                                Name" > name
# awk '$0=NR":"$0' name > line_number_name

more $1 | grep "##########                        Cluster_Size" > cluster

more $1 | grep "##########                          Grid_Score" > grid
awk '$0=NR":"$0' grid > line_number_grid
sort -t : -k3n line_number_grid > ranked_line_number_grid
head -$2 ranked_line_number_grid > top_ranked_line_number_grid
awk -F ':' '{print $1}' ./top_ranked_line_number_grid > top_ranked_line_number

more $1 | grep "##########                     Grid_vdw_energy" > vdw
# awk '$0=NR":"$0' vdw > line_number_vdw

more $1 | grep "##########                      Grid_es_energy" > es
# awk '$0=NR":"$0' es > line_number_es

more $1 | grep "##########           Internal_energy_repulsive" > repulsive
# awk '$0=NR":"$0' repulsive > line_number_repulsive

/usr/bin/obabel -imol2 $1 -O separated.mol2 -m

abc=`cat top_ranked_line_number`
for i in $abc
do
	echo "  " >> dock6_top_$2.mol2	
	awk "NR==$i" name >> dock6_top_$2.mol2
	awk "NR==$i" cluster >> dock6_top_$2.mol2
	awk "NR==$i" grid >> dock6_top_$2.mol2
	awk "NR==$i" vdw >> dock6_top_$2.mol2
	awk "NR==$i" es >> dock6_top_$2.mol2
	awk "NR==$i" repulsive >> dock6_top_$2.mol2
	echo "  " >> dock6_top_$2.mol2
	cat separated$i.mol2 >> dock6_top_$2.mol2
done

rm name cluster grid vdw es repulsive line_number_grid ranked_line_number_grid top_ranked_line_number_grid top_ranked_line_number
for q in 1 2 3 4 5 6 7 8 9
do
	rm separated$q*
done
