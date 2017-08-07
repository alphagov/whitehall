desc 'One off task to migrate numeric need ids to links in the Publishing API'
task migrate_need_ids: :environment do
  results = ActiveRecord::Base.connection.execute("
SELECT * FROM (
  SELECT documents.content_id,
         (SELECT need_ids
          FROM editions
          WHERE editions.document_id = documents.id
          AND need_ids IS NOT NULL
          ORDER BY editions.id DESC LIMIT 1) need_ids
  FROM documents) results
WHERE need_ids IS NOT NULL;")

  not_found_need_ids = {}

  results.each do |content_id, raw_need_ids|
    need_ids = raw_need_ids.lines.map { |line|
      line.gsub(/[^\d]/, '')
    }.reject(&:empty?)

    need_content_ids = need_ids.map do |need_id|
      begin
        Whitehall.need_api.content_id(need_id)
      rescue GdsApi::HTTPNotFound
        nil
      end
    end

    mapping = need_ids.zip(need_content_ids).map { |n, c| "  #{n} -> #{c}" }.join("\n")
    puts "#{content_id}:\n#{mapping}\n"

    not_found_count = need_content_ids.count(nil)
    not_found_need_ids[content_id] = not_found_count if not_found_count.nonzero?

    need_content_ids = need_content_ids.compact

    Services.publishing_api.patch_links(
      content_id,
      links: { meets_user_needs: need_content_ids }
    )
  end

  if not_found_need_ids.any?
    puts "\nDocuments where need content ids could not be found:"
    not_found_need_ids.each do |content_id, count|
      puts "  #{content_id}: #{count}"
    end
  else
    puts "\nNo need ids could not be found"
  end
end
