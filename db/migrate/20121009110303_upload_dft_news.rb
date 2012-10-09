require 'csv'

class UploadDftNews < ActiveRecord::Migration
  def up
    creator = User.find_by_name!("Automatic Data Importer")
    data.each do |row|
      organisation = Organisation.find_by_name(row['Organisation'])
      if organisation.nil?
        $stderr.puts "Unable to find organisation '#{row['Organisation']}' for '#{row['Title']}', skipping"
        next
      end
      policy_slugs = [row['Policy 1'], row['Policy 2']]
      policies = policy_slugs.map do |slug|
        next if slug.blank?
        doc = Document.find_by_slug(slug)
        if doc
          doc.published_edition
        else
          $stderr.puts "Unable to find policy '#{slug}' for '#{row['Title']}'"
          nil
        end
      end.compact

      role_slugs = [row['Minister 1'], row['Minister 2']].reject(&:blank?)
      roles = role_slugs.map do |slug|
        next if slug.blank?
        role = MinisterialRole.find_by_slug(slug)
        if role
          role
        else
          $stderr.puts "Unable to find role with slug '#{slug}' for '#{row['Title']}'"
          nil
        end
      end.compact

      begin
        first_published_at = if row['First published'].present?
          month, day, year = row['First published'].split "/"
          Time.zone.parse("#{year}-#{month}-#{day}")
        end
        n = NewsArticle.new(
          type: "NewsArticle",
          creator: creator,
          title: row['Title'],
          summary: row['Summary'],
          body: row['Body'],
          first_published_at: first_published_at
          )
        n.related_policies = policies
        n.organisations = [organisation]
        n.ministerial_roles = roles
        n.save!
        puts "Saved #{n.id}: '#{n.title}'"
      rescue => e
        $stderr.puts "Unable to save '#{row['Title']}' because #{e}"
      end
    end
  end

  def down
  end

  def data
    CSV.read(
      File.dirname(__FILE__) + '/20121009110303_upload_dft_news.csv',
      headers: true)
  end

  def dump_row(row)
    puts "old_url: [#{row['old_url']}]"
    puts "Title: [#{row['Title']}]"
    puts "Summary: [#{row['Summary']}]"
    puts "Body: [#{row['Body'][0..10]}]"
    puts "First published: [#{row['First published']}]"
    puts "Policy 1: [#{row['Policy 1']}]"
    puts "Policy 2: [#{row['Policy 2']}]"
    puts "Organisation: [#{row['Organisation']}]"
  end
end
