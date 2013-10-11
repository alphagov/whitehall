def has_any_null_ordering?(ordering)
  ordering.any?(&:nil?)
end

def has_all_null_ordering?(ordering)
  ordering.compact.empty?
end

def has_duplicate_ordering?(ordering)
  total_order_count = ordering.count
  unique_order_count = ordering.uniq.count

  unique_order_count < total_order_count
end

attachable_info = ActiveRecord::Base.connection.select("
  SELECT attachable_id, attachable_type FROM attachments
  WHERE attachable_id IS NOT NULL
  AND attachable_type IS NOT NULL
  GROUP BY attachable_id, attachable_type
")

attachable_ids_by_type = Hash.new { |hash, key| hash[key] = [] }
attachable_info.each do |identifiers|
  attachable_ids_by_type[identifiers['attachable_type']] << identifiers['attachable_id']
end

attachable_ids_by_type.each do |attachable_type, attachable_ids|
  attachable_class = attachable_type.constantize

  attachable_ids.each_slice(1000) do |ids|
    attachable_class.includes(:attachments).where(id: ids).each do |attachable|
      current_ordering = attachable.attachments.map(&:ordering)

      if has_all_null_ordering?(current_ordering)
        print '.'
      elsif has_any_null_ordering?(current_ordering)
        print 'P'
      elsif has_duplicate_ordering?(current_ordering)
        print 'D'
      else
        print '-'
        STDOUT.flush
        next
      end

      STDOUT.flush

      attachable.attachments.sort_by(&:created_at).each_with_index do |attachment, index|
        attachment.update_column(:ordering, index)
      end
    end
  end
end

puts ' done.'
