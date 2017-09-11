# This migration will no longer work as it references Need API,
# which has been retired. Needs have been exported from Need API
# to Publishing API and can be accessed as content items.

# desc 'One off task to migrate numeric need ids to links in the Publishing API'
# task migrate_need_ids: :environment do
#   def cleanup_ids(raw_need_ids)
#     raw_need_ids.lines.map { |line| line.gsub(/[^\d]/, '') }.reject(&:empty?)
#   end
#
#   def fetch_content_ids(need_ids)
#     need_ids.map do |need_id|
#       begin
#         Whitehall.need_api.content_id(need_id)
#       rescue GdsApi::HTTPNotFound
#         nil
#       end
#     end
#   end
#
#   def print_mapping(content_id, need_ids, content_ids)
#     mapping = need_ids.zip(content_ids).map { |n, c| "  #{n} -> #{c}" }.join("\n")
#     puts "#{content_id}:\n#{mapping}\n"
#   end
#
#   def print_missing_need_ids(missing_need_ids)
#     if missing_need_ids.any?
#       puts "\nDocuments where need content ids could not be found:"
#       missing_need_ids.each do |content_id, count|
#         puts "  #{content_id}: #{count}"
#       end
#     else
#       puts "\nNo need ids could not be found"
#     end
#   end
#
#   results = ActiveRecord::Base.connection.execute("
#   SELECT * FROM (
#     SELECT documents.content_id,
#            (SELECT need_ids
#             FROM editions
#             WHERE editions.document_id = documents.id
#             AND need_ids IS NOT NULL
#             ORDER BY editions.id DESC LIMIT 1) need_ids
#     FROM documents) results
#   WHERE need_ids IS NOT NULL;")
#
#   missing_need_ids = {}
#
#   results.each do |content_id, raw_need_ids|
#     need_ids = cleanup_ids(raw_need_ids)
#     content_ids = fetch_content_ids(need_ids)
#     print_mapping(content_id, need_ids, content_ids)
#
#     missing_content_ids_count = content_ids.count(nil)
#     missing_need_ids[content_id] = missing_content_ids_count if missing_content_ids_count.nonzero?
#
#     content_ids = content_ids.compact
#
#     Services.publishing_api.patch_links(
#       content_id,
#       links: { meets_user_needs: content_ids }
#     )
#   end
#
#   print_missing_need_ids(missing_need_ids)
# end
