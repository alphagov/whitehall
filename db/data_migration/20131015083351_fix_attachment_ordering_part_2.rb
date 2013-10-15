def has_any_null_ordering?(ordering)
  ordering.any?(&:nil?)
end

def has_duplicate_ordering?(ordering)
  total_order_count = ordering.count
  unique_order_count = ordering.uniq.count

  unique_order_count < total_order_count
end

attachable_info = ActiveRecord::Base.connection.select("
  SELECT attachable_id, attachable_type FROM old_attachments
  WHERE attachable_id IS NOT NULL
  AND attachable_type IS NOT NULL
  GROUP BY attachable_id, attachable_type
")

attachable_ids_by_type = Hash.new { |hash, key| hash[key] = [] }
attachable_info.each do |identifiers|
  attachable_ids_by_type[identifiers['attachable_type']] << identifiers['attachable_id']
end

class OldAttachment < Attachment
  set_table_name :old_attachments
end

attachable_ids_by_type.each do |attachable_type, attachable_ids|
  attachable_class = attachable_type.constantize

  attachable_ids.each_slice(1000) do |ids|
    attachable_class.includes(:attachments).where(id: ids).each do |attachable|
      nil_attachments, old_attachments = OldAttachment.where(id: attachable.attachment_ids).partition(&:nil?)

      current_ordering = old_attachments.map(&:ordering)

      next unless has_any_null_ordering?(current_ordering) || has_duplicate_ordering?(current_ordering)

      puts "#{attachable_class}##{attachable.id}"

      resorted_attachments = attachable.attachments.sort_by { |a| [a.created_at, a.id] }

      resorted_attachments.each_with_index do |attachment, index|
        old_attachment = old_attachments.detect { |o| o.id == attachment.id }
        puts "-- #{attachment.id} #{old_attachment.try(:ordering)}->#{attachment.ordering}->#{index}"
        attachment.update_column(:ordering, index)
      end
    end
  end
end

puts 'done.'
