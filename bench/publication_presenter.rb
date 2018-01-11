# /usr/bin/env ruby

require ::File.expand_path('../../config/environment', __FILE__)
require 'benchmark'

require 'stackprof'

publications = Publication
  .published
  .order("id DESC")
  .limit(100)
  .to_a

StackProf.run(mode: :wall, out: "tmp/publication_presenter_content.dump") do
  puts Benchmark.measure do
    publications.each do |publication|
      PublishingApi::PublicationPresenter.new(publication).content
      print "."
    end
    puts
  end
end

StackProf.run(mode: :wall, out: "tmp/publication_presenter_links.dump") do
  puts Benchmark.measure do
    publications.each do |publication|
      PublishingApi::PublicationPresenter.new(publication).links
      print "."
    end
    puts
  end
end
