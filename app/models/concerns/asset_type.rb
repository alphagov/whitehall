module AssetType
  extend ActiveSupport::Concern

  def delete
    update_column(:deleted, true)
  end

  def destroy
    callbacks_result = transaction do
      run_callbacks(:destroy) do
        delete
      end
    end
    callbacks_result ? self : false
  end
end
