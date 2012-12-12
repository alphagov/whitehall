windows_1252 = (128..255).map {|byte_number| byte_number.chr.force_encoding("Windows-1252") }.map do |c|
  original = c.encode("utf-8") rescue nil
  double_encoded = c.encode("utf-8").force_encoding("Windows-1252").encode("utf-8") rescue nil
  [original, double_encoded]
end

Edition.find_each do |edition|
  begin
    next unless edition.is_latest_edition?

    new_body = edition.body.dup
    new_title = edition.title.dup
    new_summary = edition.summary.dup if edition.summary.present?

    windows_1252.each do |pair|
      unless pair.include?(nil)
        new_body.gsub!(/#{pair[1]}/, pair[0])
        new_title.gsub!(/#{pair[1]}/, pair[0])
        new_summary.gsub!(/#{pair[1]}/, pair[0]) if edition.summary.present?

      end
    end

    new_body.gsub!(/Â\s/, ' ')
    new_title.gsub!(/Â\s/, ' ')
    new_summary.gsub!(/Â\s/, ' ') if edition.summary.present?

    if (new_body != edition.body)
      edition.update_column(:body, new_body)
      p [:edition, :updated_body, edition.id]
    end

    if (new_title != edition.title)
      edition.update_column(:title, new_title)
      p [:edition, :updated_title, edition.id]
    end

    if (new_summary != edition.summary && edition.summary.present?)
      edition.update_column(:summary, new_summary)
      p [:edition, :updated_summary, edition.id]
    end

  rescue Exception => e
    p [:edition_update_failed, edition.id, e.inspect]
  end
end
