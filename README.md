# CICIDS2017 Wednesday Flow Analysis

## 1. Generate BPS (Bits Per Second)
```sh
zcat wednesday_flow.tsv.gz | awk '{print strftime("%Y-%m-%d_%H:%M:%S", $1+(12*3600)) "\t" ($11+$12)*8}' | sort | awk '$1==prv{bps+=$2;next}{print prv "\t" bps; prv=$1; bps=$2}' > wed_bps.tsv
```

## 2. Visualize Traffic in BPS
```sh
cat wed_bps.tsv | feedgnuplot --domain --timefmt "%Y-%m-%d_%H:%M:%S" --with 'boxes lt -1 lw 2' --ymax 30000000000 --legend 0 "bps" --title "CICIDS2017 Wednesday"
```

## 3. Count Duration of DoS Attack (Bandwidth > 5Gbps)
```sh
cat wed_bps.tsv | awk '$2>4*(2^30){print $0}' | wc -l
```

## 4. Generate TCP CPS (Connections Per Second) and CPM (Connections Per Minute)
```sh
zcat wednesday_flow.tsv.gz | awk '$6=="tcp"{print strftime("%Y-%m-%d_%H:%M:%S", $1+(12*3600))}' | sort | uniq -c | awk '{print $2 "\t" $1}' > wed_cps.tsv

zcat wednesday_flow.tsv.gz | grep http | awk '$7=="http"{print strftime("%H:%M", $1+(12*3600))}' | sort | awk 'split($1,ts,":"){print ts[1] ":" ts[2]}' | sort | uniq -c | awk '{print $2 "\t" $1}' | awk '$1==prv{c+=$2;cnt++;next}{print prv "\t" (c+1)/(cnt+1); prv=$1; s=$2; cnt=1}' > wed_cpm.tsv
```

## 5. Visualize Flow in CPS and CPM
```sh
cat wed_cps.tsv | feedgnuplot --domain --timefmt "%Y-%m-%d_%H:%M:%S" --lines --points --legend 0 "cps" --title "CICIDS2017 Wednesday"

cat wed_cpm.tsv | feedgnuplot --domain --timefmt "%H:%M" --lines --points --legend 0 "cpm" --title "CICIDS2017 Wednesday"
```

## 6. Count Duration of DoS Attack (Sessions > 1000/s)
```sh
cat wed_cps.tsv | awk '$2>999{print $0}' | wc -l
```

## 7. Generate HTTP Connection Average Duration Per Minute
```sh
zcat wednesday_flow.tsv.gz | grep http | awk '$7=="http"{print strftime("%H:%M", $1+(12*3600)) "\t" $8}' | sort | awk 'split($1,ts,":"){print ts[1] ":" ts[2] ":00" "\t" $2}' | sort | awk '$1==prv{d+=$2;cnt++;next}{print prv "\t" (d+1)/(cnt+1); prv=$1; d=$2; cnt=1}' > wed_dur.tsv
```

## 8. Visualize HTTP Connection Duration (Average Per Minute)
```sh
cat wed_dur.tsv | feedgnuplot --domain --timefmt "%H:%M:%S" --lines --points --legend 0 "avg duration" --title "CICIDS2017 HTTP Duration"
```
![image](https://github.com/user-attachments/assets/d20f2563-3ab6-4102-9d1b-39ec8f050f15) 
![1](https://github.com/user-attachments/assets/e3c56f9e-299c-4b90-b487-c485f230bec2)
![3](https://github.com/user-attachments/assets/66703c23-678e-4107-a033-69857999d7da)
![4](https://github.com/user-attachments/assets/011031a4-57e9-4c0d-9913-245d4bfb1323)


## Summary
This analysis extracts network traffic data from CICIDS2017's Wednesday dataset, measures bandwidth usage, detects DoS attacks based on traffic spikes, and visualizes TCP connections and HTTP session durations.
