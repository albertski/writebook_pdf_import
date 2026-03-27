module Book::Accessable
  extend ActiveSupport::Concern
  class_methods do
    def accessable_or_published(user: nil)
      all
    end
  end
  def editable?(user: nil)
    true
  end
end
