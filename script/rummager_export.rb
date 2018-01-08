#!/usr/bin/env ruby
# Export, to stdout, a dump of all data needed to rebuild search indexes.
# By default, exports the data for the "government" search index.  If the
# --detailed flag is supplied on the command line, exports the data for the
# "detailed" search index.
#
# Providing an EXPORT_DIRECTORY environment variable will
# output multiple files to the directory and perform the dump
# in a parallel manner, one sub-process per CPU/core.
$LOAD_PATH << File.expand_path("../", File.dirname(__FILE__))

require 'pathname'
require 'logger'
logger = Logger.new(STDERR)
logger.info "Booting rails..."
require 'config/environment'
logger.info "Booted"

classes_to_index = if ARGV.include?("--detailed")
                     [DetailedGuide]
                   else
                     RummagerPresenters.searchable_classes_for_government_index
                   end

id_groups = []
classes_to_index.each do |klass|
  id_groups += klass.searchable_instances.pluck(:id).each_slice(1_000).map do |id_group|
    [klass, id_group]
  end
end

def export_classes(classes_to_index, id_groups, &block)
  if export_directory = ENV["EXPORT_DIRECTORY"]
    export_directory = Pathname.new(export_directory).expand_path

    if export_directory.exist? && export_directory.children.any?
      puts "#{ENV["EXPORT_DIRECTORY"]} exists and is not empty, aborting"
      exit
    else
      puts "Starting export of #{id_groups.count} files to #{ENV["EXPORT_DIRECTORY"]}"
    end

    export_directory.mkpath

    Parallel.each_with_index(id_groups) do |(klass, id_group), index|
      file_path = export_directory + "#{klass.name.downcase}-#{index}.esdump"
      logger.info "Exporting #{klass.name.downcase}-#{index}.esdump"
      File.open(file_path.to_s, "w") do |output|
        yield(klass, output, id_group)
      end
    end
  else
    classes_to_index.each do |klass|
      yield(klass, STDOUT)
    end
  end
end

def output_es_line(obj, output)
  max_retry_count = 5
  begin
    search_index = obj.search_index
  rescue
    max_retry_count -= 1
    if max_retry_count <= 0
      raise
    else
      logger.warn("Export of #{obj.class.name}##{obj.id} failed, #{max_retry_count} retries left")
      sleep 5
      retry
    end
  end

  output.puts %Q[{"index": {"_type": "edition", "_id": "#{search_index['link']}"}}]
  output.puts search_index.to_json
end

export_classes(classes_to_index, id_groups) do |klass, output, id_group|
  association = klass.searchable_instances

  eager_loads = [:document, :organisations, :attachments, :world_locations]
  eager_loads.each do |sym|
    if klass.reflect_on_association(sym)
      association = association.includes(sym)
    end
  end

  if id_group
    association.where(id: id_group).each do |obj|
      output_es_line(obj, output)
    end
  else
    association.find_each do |obj|
      output_es_line(obj, output)
    end
  end
end
