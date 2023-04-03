# count_files_by_type.rb

def count_files_by_type(directory, file_extension)
  Dir.glob(File.join(directory, "*.#{file_extension}")).count
end

if ARGV.length != 2
  puts "Usage: ruby count_files_by_type.rb <source_directory> <file_extension>"
  exit(1)
end

source_directory = ARGV[0]
file_extension = ARGV[1]
file_count = count_files_by_type(source_directory, file_extension)

puts "Number of #{file_extension.upcase} files in #{source_directory}: #{file_count}"
