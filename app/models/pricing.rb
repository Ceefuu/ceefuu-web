class Pricing < ApplicationRecord
  belongs_to :content
  enum pricing_type: [:basic, :standard, :premium]
end
