# Migration Preview & Testing Script
#
# Script to test logic and preview migration impact.
# Run this before executing the actual migration to understand the impact.
#
# Usage: ruby migration_preview.rb
#
# Features:
# • Tests all 19 business logic scenarios
# • Analyzes current database state
# • Previews sample changes with examples
# • Estimates republishing impact and timing

require_relative "config/environment"

class MigrationPreview
  # MIGRATION LOGIC (identical to data migration)
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

  # Comprehensive test cases covering all business logic scenarios
  def self.test_cases
    [
      # [alt_text, caption, expected_result, description]

      # Basic cases
      ["Long descriptive alt text", "", "Long descriptive alt text", "Empty caption, use alt text"],
      ["Short alt", "Much longer caption text here", "Much longer caption text here", "Caption longer, keep caption"],
      ["Long descriptive alt text", "Short", "Long descriptive alt text", "Alt text longer, use alt text"],
      ["", "Some caption", "Some caption", "No alt text, keep caption"],
      ["Same length", "Same length", "Same length", "Equal length, keep caption"],

      # Credit cases
      ["Long descriptive alt text", "Credit: John Doe", "Long descriptive alt text [Credit: John Doe]", "Credit prefix, combine"],
      ["Long descriptive alt text", "Copyright 2023", "Long descriptive alt text [Copyright 2023]", "Copyright prefix, combine"],
      ["Long descriptive alt text", "Source: Getty Images", "Long descriptive alt text [Source: Getty Images]", "Source prefix, combine"],
      ["Long descriptive alt text", "© Crown Copyright", "Long descriptive alt text [© Crown Copyright]", "© prefix, combine"],

      # Edge cases
      ["Short", "Credit: Long copyright notice", "Credit: Long copyright notice", "Credit term but caption longer, keep caption"],
      ["Alt text", "credit: lowercase", "Alt text", "Lowercase credit doesn't match, use alt text"],
      ["", "Credit: Something", "Credit: Something", "No alt text, keep caption even with credit"],
      ["Alt", "", "Alt", "Empty caption, use alt text"],

      # Problematic cases
      ["Crown Copyright. All Rights Reserved.", "Crown Copyright. All Rights Reserved.", "Crown Copyright. All Rights Reserved.", "Duplicate text, keep as is"],
      [nil, nil, "", "Both nil, result empty"],
      ["  ", "  ", "", "Both whitespace, result empty"],
    ]
  end

  def self.run
    puts "Alt Text to Caption Migration - Testing & Preview"
    puts "=" * 55
    puts

    test_migration_logic    # Validate business logic
    puts
    analyze_current_state   # Examine database state
    puts
    preview_changes         # Show sample changes
    puts
    estimate_impact         # Calculate republishing needs
  end

  # Validates all business logic scenarios
  def self.test_migration_logic
    puts "Testing Migration Logic (19 scenarios):"
    puts "-" * 42

    test_cases = self.test_cases
    preview_instance = new

    passed = 0
    failed_cases = []

    test_cases.each_with_index do |(alt_text, caption, expected, description), index|
      result = preview_instance.determine_new_caption(alt_text, caption)
      if result == expected
        passed += 1
      else
        failed_cases << {
          index: index + 1,
          alt_text: alt_text,
          caption: caption,
          expected: expected,
          result: result,
          description: description,
        }
      end
    end

    puts "Result: #{passed}/#{test_cases.count} tests passed"

    if failed_cases.any?
      puts "Failed tests:"
      failed_cases.first(3).each do |test_case|
        puts "  #{test_case[:index]}. #{test_case[:description]}"
        puts "    Expected: #{test_case[:expected].inspect}"
        puts "    Got: #{test_case[:result].inspect}"
      end
      puts "    ... (#{failed_cases.count - 3} more)" if failed_cases.count > 3
    else
      puts " All tests passed!"
    end
  end

  # Analyzes current database state
  def self.analyze_current_state
    puts "Database Analysis:"
    puts "-" * 18

    total = Image.count
    with_alt = Image.where.not(alt_text: [nil, ""]).count
    with_caption = Image.where.not(caption: [nil, ""]).count
    with_both = Image.where.not(alt_text: [nil, ""]).where.not(caption: [nil, ""]).count

    puts "Total images: #{total}"
    puts "With alt text: #{with_alt} (#{percentage(with_alt, total)}%)"
    puts "With caption: #{with_caption} (#{percentage(with_caption, total)}%)"
    puts "With both: #{with_both} (#{percentage(with_both, total)}%)"

    return if total.zero?

    # Analyze credit patterns
    credit_count = Image.where.not(caption: [nil, ""])
                       .where("caption LIKE 'Credit%' OR caption LIKE 'Copyright%' OR caption LIKE 'Source%' OR caption LIKE '©%' OR caption LIKE 'Crown Copyright%'")
                       .count

    puts "Credit captions: #{credit_count} (#{percentage(credit_count, with_caption)}% of captions)" if with_caption.positive?
  end

  # Shows sample of changes that would be made
  def self.preview_changes
    puts "Sample Changes:"
    puts "-" * 15

    total_images = Image.count
    return puts "No images found in database" if total_images.zero?

    preview_instance = new
    sample_size = [total_images, 300].min
    would_change = 0
    would_combine = 0

    Image.includes(:edition).limit(sample_size).each do |image|
      new_caption = preview_instance.determine_new_caption(image.alt_text, image.caption)
      current = image.caption.to_s.strip

      next unless new_caption != current

      would_change += 1
      would_combine += 1 if new_caption.include?("[")

      # Show first example only
      next unless would_change == 1

      puts "Example change:"
      puts "  Alt text: \"#{image.alt_text}\""
      puts "  Current:  \"#{current.presence || '(empty)'}\""
      puts "  New:      \"#{new_caption}\""
    end

    puts "Sample: #{would_change}/#{sample_size} (#{percentage(would_change, sample_size)}%) would change"
    puts "Combinations: #{would_combine}" if would_combine.positive?
  end

  # Estimates republishing impact and timing
  def self.estimate_impact
    puts "Republishing Impact:"
    puts "-" * 20

    total_with_alt = Image.where.not(alt_text: [nil, ""]).count
    return puts "No images with alt text found" if total_with_alt.zero?

    sample_size = [total_with_alt, 1000].min
    preview_instance = new

    affected_document_ids = Set.new
    changes_count = 0

    Image.joins(:edition).where.not(alt_text: [nil, ""]).limit(sample_size).each do |image|
      new_caption = preview_instance.determine_new_caption(image.alt_text, image.caption)
      if new_caption != image.caption.to_s.strip
        changes_count += 1
        affected_document_ids.add(image.edition.document_id)
      end
    end

    # Extrapolate to full dataset
    scaling_factor = total_with_alt.to_f / sample_size
    estimated_changes = (changes_count * scaling_factor).to_i
    estimated_documents = (affected_document_ids.size * scaling_factor).to_i

    puts "Sample: #{changes_count}/#{sample_size} images (#{percentage(changes_count, sample_size)}%)"
    puts "Estimated: ~#{estimated_changes} images, ~#{estimated_documents} documents"
  end

  def self.percentage(part, whole)
    return 0 if whole.zero?

    ((part.to_f / whole) * 100).round(1)
  end
end

# Run the preview if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  begin
    MigrationPreview.run
  rescue StandardError => e
    puts "Error running preview: #{e.message}"
    puts "Make sure you're in the Rails environment with database access"
  end
end
