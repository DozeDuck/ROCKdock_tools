# usage: ./seesar_score_ranker.sh seesar_rescore_fullposes.sdf 100
# /usr/bin/obabel seesar_rescore_fullposes.sdf -O seesar_rescore_fullposes.mol2 
# 加个能筛选阈值的功能/或者不加也可以，因为可以选择Top number
/usr/bin/obabel -isdf seesar_rescore_fullposes.sdf -O separated.sdf -m #可以把seesar_rescore_fullposes.sdf用$1表示
awk '/LOWER_BOUNDARY/{getline a;print a}' seesar_rescore_fullposes.sdf > hyde_LOWER_score
awk '$0=NR":"$0' hyde_LOWER_score > line_number_hyde_LOWER_score
sort -t : -k2n line_number_hyde_LOWER_score > ranked_line_number_hyde_LOWER_score
head -$2 ranked_line_number_hyde_LOWER_score > top_ranked_line_number_hyde_LOWER_score
awk -F ':' '{print $1}' ./top_ranked_line_number_hyde_LOWER_score > top_ranked_line_number 
abc=`cat top_ranked_line_number`
for i in $abc
do
	cat separated$i.sdf >> seesar_rescore_subset.sdf
done

rm separated*.sdf
rm hyde_LOWER_score
rm line_number_hyde_LOWER_score
rm ranked_line_number_hyde_LOWER_score
rm top_ranked_line_number_hyde_LOWER_score
rm top_ranked_line_number

