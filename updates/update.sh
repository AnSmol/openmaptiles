#!/bin/bash
set -euxo pipefail


echo "==$(date) -START- get todays osm extracts, merge them, generate changefile, cleanup old extracts=="

updates_root=/var/opt/openmaptiles/updates
todays_folder="$updates_root/extracts_$(date '+%Y_%m_%d__%H_%M_%S')/"
mkdir -p $todays_folder

regions=('russia-latest.osm.pbf' 'europe/belarus-latest.osm.pbf' 'asia/kazakhstan-latest.osm.pbf')

for region in ${regions[@]}
do
	wget https://download.geofabrik.de/$region -nv -O $todays_folder/region_${region##*/}
done

/usr/bin/osmium merge --verbose --output-header="options.osmosis_replication_timestamp=$(date '+%Y-%m-%dT%H:%M:%SZ')" $todays_folder/region_*.pbf -o $todays_folder/merged_regions.osm.pbf


#In order to make diff file we have to get the previous update folder. Line number two in ls's descending output
previous_extracts_folder=$(ls -rd $updates_root/extracts_*  | awk 'NR==2')
#https://unix.stackexchange.com/questions/122845/using-a-b-for-variable-assignment-in-scripts
#In case if this is a first run, previous folder is empty, set it the same value as $todays_folder has
previous_extracts_folder="${previous_extracts_folder:-$todays_folder}"


/usr/bin/osmium derive-changes --verbose $previous_extracts_folder/merged_regions.osm.pbf $todays_folder/merged_regions.osm.pbf -o $todays_folder/changes.osc

#Removing previous extracts folders. Keep only last
#Get all folders(-d) in descending(-r) alphabetical order. Then let AWK show all records except first three ones. Pass this records to rm command
ls -rd $updates_root/extracts_*  | awk '(NR > 3)' | xargs -i /bin/rm -v -rf '{}'

echo "==$(date) -STOP- get todays osm extracts, merge them, generate changefile, cleanup old extracts=="

