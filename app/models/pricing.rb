class Pricing < ApplicationRecord
  belongs_to :content
  enum pricing_type: [:message, :video, :live]
end
