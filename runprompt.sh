#!/usr/bin/env bash
set -x
inputfile="$1"
inputwithoutext="${inputfile%.txt}"
device="$2"
model=${3:-"nvidia/minimaxai/minimax-m3"}
#model=${3:-"nvidia/z-ai/glm-5.2"}
rm -rf "artifacts/${device}/${inputwithoutext}" || true
logdir="logs/${device}"
mkdir -p $logdir
copyprompt="${logdir}/${inputwithoutext}.text"
logfile="${logdir}/${inputwithoutext}.log"
cleanlogfile="${logdir}/${inputwithoutext}_clean.log"
prompt=$(cat $inputfile | sd '<device>' $device)
opencode run -m "$model" "$prompt" 2>&1 | tee "$logfile"
ansifilter -i $logfile -o $cleanlogfile
echo "$prompt" >  $copyprompt



