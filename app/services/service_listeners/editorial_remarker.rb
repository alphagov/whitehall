module ServiceListeners
  EditorialRemarker = Struct.new(:edition, :author, :body) do
    def save_remark!
      if author.present? && body.present?
        edition.editorial_remarks.create!(body:, author:)
      end
    end
  end
end
