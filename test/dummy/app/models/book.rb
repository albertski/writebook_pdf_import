class Book < ApplicationRecord
  include Book::Accessable, Book::Sluggable
  has_many :leaves, dependent: :destroy
  has_one_attached :cover, dependent: :purge_later
  enum :theme, %w[ black blue green magenta orange violet white ].index_by(&:itself), suffix: true, default: :blue
  def press(leafable, leaf_params)
    leaves.create! leaf_params.merge(leafable: leafable)
  end
end
