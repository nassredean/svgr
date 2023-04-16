#!/usr/bin/env fish

set input_directory $argv[1]
set output_directory $argv[2]
set num_groups $argv[3]
set files_per_group $argv[4]

# Get all SVG files from the input directory
set svg_files (find $input_directory -type f -name "*.svg")

# Randomly sort the SVG files and store them in a new list
set random_indices (jot -r (count $svg_files) 1 (count $svg_files))
set sorted_files
for index in $random_indices
    set sorted_files $sorted_files $svg_files[$index]
end

set group_counter 1
while test $group_counter -le $num_groups
    set start_index (math "1 + ( $group_counter - 1 ) * $files_per_group")
    set end_index (math "$start_index + $files_per_group - 1")
    set batch_files (string split " " -- (printf "%s " $sorted_files[$start_index..$end_index]))
    set joined_files (string join "," $batch_files)
    set trimmed_files (string trim -r -c "," $joined_files)
    echo $trimmed_files

    set root_names
    for file in $batch_files
        set file_basename (basename $file .svg)
        set root_names $root_names $file_basename
    end
    set output_file_name (string join "__" $root_names)
    set output_file (string join "" $output_directory $output_file_name ".svg")

    eval "./bin/svgr arrange:grid $trimmed_files 3 1 -s 3 -t 8 | ./bin/svgr document:resize 228.6 304.8 | ./bin/svgr document:recolor \"#000000\" > $output_file"

    set group_counter (math "$group_counter + 1")
end
