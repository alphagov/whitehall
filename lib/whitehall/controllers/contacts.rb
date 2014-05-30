class Whitehall::Controllers::Contacts
  def destroy_blank_phone_numbers(object_params)
    if object_params[:contacts_attributes]
      object_params[:contacts_attributes].each do |_index, contact|
        if contact && contact[:contact_numbers_attributes]
          contact[:contact_numbers_attributes].each do |_key, number|
            if number[:label].blank? && number[:number].blank?
              number[:_destroy] = "1"
            end
          end
        end
      end
    end
  end
end
