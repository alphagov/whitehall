class UpdateAttachmentLegislativeListSyntax < ActiveRecord::Migration
  class Attachment < ApplicationRecord; end

  def self.fix_attachment(attachment)
    # This regex is the one used for matching legislative lists in the previous
    # version of govspeak. The intent is to add an `$EndLegislativeList` tag in
    # the same place that one would have been inferred in the previous version.
    regex = /^\$LegislativeList\s*$(.*?)(?:^\s*$|\Z)/m

    new_body = attachment.body.dup

    attachment.body.scan(regex) do |match|
      new_body.gsub!(match.first, "#{match.first}$EndLegislativeList\n")
    end

    attachment.body = new_body
    attachment.save
  end

  def self.up
    Attachment.where("body LIKE '%$LegislativeList%'").each do |attachment|
      puts "Changing attachment #{attachment.id}"
      fix_attachment(attachment)
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
