class Content < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user
  belongs_to :category
  
  has_many :pricings, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many_attached :photos
  has_rich_text :description

  accepts_nested_attributes_for :pricings

  validates :title, presence: { message: 'cannot be blank' }

  def average_rating
    reviews.count == 0 ? 0 : reviews.average(:stars).round(1)
  end

end
