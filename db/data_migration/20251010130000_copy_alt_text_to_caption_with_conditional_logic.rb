# Data migration to copy alt text to caption fields with conditional logic
#
# Usage: bundle exec rake db:data:migrate VERSION=20251010130000
#
# BUSINESS LOGIC:
# 1. If alt text and caption are identical → keep as-is (avoid duplication)
# 2. If caption starts with credit terms (Credit/Copyright/Source/©/Crown Copyright)
#    AND alt text is descriptive (>10 chars) → combine: "alt text [caption]"
# 3. If caption looks like unrecognized credit (e.g. lowercase) → use alt text
# 4. Otherwise → use longer of the two (or alt text if caption empty)

# Main logic to determine new caption based on business rules
def determine_new_caption(alt_text, caption)
  alt_text = alt_text.to_s.strip
  caption = caption.to_s.strip

  # Rule 0: No alt text → keep existing caption
  return caption if alt_text.blank?

  # Rule 1: Identical content → avoid duplication
  return caption if alt_text == caption

  # Rule 2: Credit terms + descriptive alt text → combine
  if caption_starts_with_credit_terms?(caption) && alt_text.length > 10
    return "#{alt_text} [#{caption}]"
  end

  # Rule 3: Unrecognized credit pattern → prefer alt text
  if looks_like_unrecognized_credit?(caption)
    return alt_text
  end

  # Rule 4: Default → use longer text (or alt text if caption empty)
  if caption.blank? || alt_text.length > caption.length
    alt_text
  else
    caption
  end
end

# Detects recognized credit/copyright patterns (case-sensitive)
def caption_starts_with_credit_terms?(caption)
  return false if caption.blank?

  credit_terms = ["Credit", "Copyright", "Source", "©", "Crown Copyright"]
  credit_terms.any? { |term| caption.start_with?(term) }
end

# Detects unrecognized credit patterns that should prefer alt text
def looks_like_unrecognized_credit?(caption)
  return false if caption.blank?

  unrecognized_patterns = [/^credit:/i] # lowercase "credit:"

  unrecognized_patterns.any? { |pattern| caption.match?(pattern) } &&
    !caption_starts_with_credit_terms?(caption)
end

puts "Starting alt text to caption migration..."
puts "Processing images in batches of 1000..."

updated_count = 0
processed_count = 0

Image.find_in_batches(batch_size: 1000) do |batch|
  batch.each do |image|
    processed_count += 1
    new_caption = determine_new_caption(image.alt_text, image.caption)

    if new_caption != image.caption
      image.update_column(:caption, new_caption)
      updated_count += 1
    end
  end

  puts "Processed #{processed_count} images, updated #{updated_count} captions..."
end

puts
puts "Migration complete!"
puts "Total processed: #{processed_count} images"
puts "Total updated: #{updated_count} captions (#{((updated_count.to_f / processed_count) * 100).round(1)}%)"
puts
puts "Note: Document republishing should be handled separately"
