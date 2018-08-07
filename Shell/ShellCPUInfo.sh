#!/bin/bash

echo "RAM"

ps xmo rss=,pmem=,comm= | while read rss pmem comm; ((n++<5)); do
 size="$[rss/1024]";
 short=$[4-${#size}];
 size="(${size}M)";
 i=0;
 while ((i++ < short)); do size=" $size"; done;

 pmem="${pmem%%.*}"
 if (($pmem >= 20)); then color=$'\e[31m';
 elif (($pmem >= 10)); then color=$'\e[33m';
 else color=$'\e[32m ';
 fi;

 echo "$color$pmem% $size $(basename "$comm")"$'\e[0m'"";
done

echo "CPU"

ps xro %cpu=,comm= | while read cpu comm; ((i++<5)); do

 int=$cpu
 int="${int%%.*}"
 if (($int >= 50)); then color=$'\e[31m';
 elif (($int >= 25)); then color=$'\e[33m';
 else color=$'\e[32m';
 fi;

 echo "$color$cpu% $(basename "$comm")"$'\e[0m'"";
done
