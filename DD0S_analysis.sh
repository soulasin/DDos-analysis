#!/bin/bash

# 1. Generate BPS (Bits Per Second)
zcat wednesday_flow.tsv.gz | awk '{print strftime("%Y-%m-%d_%H:%M:%S", $1+(12*3600)) "\t" ($11+$12)*8}' | sort | awk '$1==prv{bps+=$2;next}{print prv "\t" bps; prv=$1; bps=$2}' > wed_bps.tsv

# 2. Visualize Traffic in BPS
cat wed_bps.tsv | feedgnuplot --domain --timefmt "%Y-%m-%d_%H:%M:%S" --with 'boxes lt -1 lw 2' --ymax 30000000000 --legend 0 "bps" --title "CICIDS2017 Wednesday"

# 3. Count Duration of DoS Attack (Bandwidth > 5Gbps)
cat wed_bps.tsv | awk '$2>4*(2^30){print $0}' | wc -l

# 4. Generate TCP CPS (Connections Per Second) and CPM (Connections Per Minute)
zcat wednesday_flow.tsv.gz | awk '$6=="tcp"{print strftime("%Y-%m-%d_%H:%M:%S", $1+(12*3600))}' | sort | uniq -c | awk '{print $2 "\t" $1}' > wed_cps.tsv

zcat wednesday_flow.tsv.gz | grep http | awk '$7=="http"{print strftime("%H:%M", $1+(12*3600))}' | sort | awk 'split($1,ts,":"){print ts[1] ":" ts[2]}' | sort | uniq -c | awk '{print $2 "\t" $1}' | awk '$1==prv{c+=$2;cnt++;next}{print prv "\t" (c+1)/(cnt+1); prv=$1; s=$2; cnt=1}' > wed_cpm.tsv

# 5. Visualize Flow in CPS and CPM
cat wed_cps.tsv | feedgnuplot --domain --timefmt "%Y-%m-%d_%H:%M:%S" --lines --points --legend 0 "cps" --title "CICIDS2017 Wednesday"

cat wed_cpm.tsv | feedgnuplot --domain --timefmt "%H:%M" --lines --points --legend 0 "cpm" --title "CICIDS2017 Wednesday"

# 6. Count Duration of DoS Attack (Sessions > 1000/s)
cat wed_cps.tsv | awk '$2>999{print $0}' | wc -l

# 7. Generate HTTP Connection Average Duration Per Minute
zcat wednesday_flow.tsv.gz | grep http | awk '$7=="http"{print strftime("%H:%M", $1+(12*3600)) "\t" $8}' | sort | awk 'split($1,ts,":"){print ts[1] ":" ts[2] ":00" "\t" $2}' | sort | awk '$1==prv{d+=$2;cnt++;next}{print prv "\t" (d+1)/(cnt+1); prv=$1; d=$2; cnt=1}' > wed_dur.tsv

# 8. Visualize HTTP Connection Duration (Average Per Minute)
cat wed_dur.tsv | feedgnuplot --domain --timefmt "%H:%M:%S" --lines --points --legend 0 "avg duration" --title "CICIDS2017 HTTP Duration"

echo "Analysis completed."
