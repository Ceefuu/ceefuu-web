class Content < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user
  belongs_to :category
  
  has_many :pricings
  has_many :orders
  has_many :reviews
  has_many :transactions
  has_many_attached :photos
  has_rich_text :description

  accepts_nested_attributes_for :pricings

  scope :active_contents, -> { where(is_active: false) }

  validates :title, presence: { message: 'cannot be blank' }

  def average_rating
    reviews.count == 0 ? 0 : reviews.average(:stars).round(1)
  end

end
