#!/usr/bin/env ruby
# encoding: utf-8
require 'damerau-levenshtein'
require File.dirname(__FILE__) + '/find-editions-where-inline-attachments-have-been-significantly-reorderd/editions_data'
require 'pp'

class DistanceComputer < Struct.new(:record)
  EDITIONID = 0
  DOCID = 1
  ATTACHMENTS = 2

  def docid
    record[0]
  end

  def editions
    record[1]
  end

  def attachment_tags(record)
    record[ATTACHMENTS].map do |tag|
      tag.gsub(/\[InlineAttachment:|!@|\]/, '')
    end
  end

  def all_attachment_tags
    @all_attachment_tags ||= editions.map do |e|
      attachment_tags(e)
    end.flatten.uniq
  end

  def chars_for_tags
    @chars_for_tags ||= begin
      pairs = all_attachment_tags.map.with_index do |tag, i|
        [tag, ("A".ord + i).chr(Encoding::UTF_8)]
      end
      Hash[pairs]
    end
  end

  def attachment_tags_as_chars(attachment_tags)
    attachment_tags.map do |tag|
      chars_for_tags[tag]
    end.join
  end

  def compute_distances
    editions[1..-1].zip(editions).map do |edition_rec, previous_edition_rec|
      DamerauLevenshtein.distance(
        attachment_tags_as_chars(attachment_tags(edition_rec)),
        attachment_tags_as_chars(attachment_tags(previous_edition_rec)),
        1
      )
    end
  end
end

big_changes = []
EDITIONS_DATA.each do |ed|
  dc = DistanceComputer.new(ed)
  distances = dc.compute_distances

  distances.each.with_index do |distance, index|
    edition = ed[1][index + 1]
    prev_edition = ed[1][index]
    edition_id, document_id, attachments = edition
    next unless edition_id > 211494
    if distance >3
      big_changes << document_id
      puts "https://whitehall-admin.preview.alphagov.co.uk/government/admin/editions/#{edition_id}"
      puts "-- #{dc.attachment_tags_as_chars(dc.attachment_tags(prev_edition))}"
      puts "-- #{dc.attachment_tags_as_chars(dc.attachment_tags(edition))}"
      # puts "#{document_id}: Edition: #{edition_id} distance: #{distance}"
    end
  end
end

puts "#{big_changes.uniq.size} big changes"