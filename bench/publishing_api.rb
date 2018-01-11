# /usr/bin/env ruby

require ::File.expand_path('../../config/environment', __FILE__)
require 'benchmark'

require 'stackprof'

publications = Publication
  .published
  .order("id DESC")
  .limit(10)
  .to_a

StackProf.run(mode: :wall, out: "tmp/publishing_api_worker.dump") do
  puts Benchmark.measure do
    publications.each { |publication|
      Whitehall::PublishingApi.locales_for(publication).each { |locale|
        PublishingApiWorker.new.perform('Edition', publication.id, 'republish', locale.to_s)
        print "."
      }
    }
    puts
  end
end
