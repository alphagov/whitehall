class BaseItemSerializer < ActiveModel::Serializer
  attributes :title, :locale, :need_ids, :publishing_app, :redirects

  def title
    object.title
  end

  def locale
    I18n.locale.to_s
  end

  def need_ids
    object.need_ids
  end

  def publishing_app
    "whitehall"
  end

  def redirects
    []
  end
end
