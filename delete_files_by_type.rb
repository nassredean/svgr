# delete_files_by_type.rb

require 'fileutils'

def get_files_by_type(directory, file_extension)
  Dir.glob(File.join(directory, "*.#{file_extension}")).sort_by { |f| File.basename(f).to_i }
end

def delete_file(file)
  File.delete(file)
end

if ARGV.length != 2
  puts "Usage: ruby delete_files_by_type.rb <source_directory> <file_extension>"
  exit(1)
end

source_directory = ARGV[0]
file_extension = ARGV[1]

files = get_files_by_type(source_directory, file_extension)

files.each do |file|
  puts "File: #{file}"
  print "Do you want to delete this file? [y/N]: "
  answer = STDIN.gets.chomp.downcase

  if answer == 'y'
    delete_file(file)
    puts "Deleted #{file}"
  end
end

