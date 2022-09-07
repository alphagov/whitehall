module ErrorItemsHelper
  def errors_for_input_field(object, attribute)
    return nil if object.errors.blank?

    object.errors.errors.filter_map { |error|
      if error.attribute == attribute
        error.full_message || error.type
      end
    }.join("\n")
  end

  def errors_for(object, attribute)
    return nil if object.errors.blank?

    object.errors.errors.filter_map do |error|
      if error.attribute == attribute
        {
          text: error.full_message || error.type,
        }
      end
    end
  end
end
