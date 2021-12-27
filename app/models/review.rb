class Review < ApplicationRecord
  belongs_to :order
  belongs_to :content, required: false
  belongs_to :buyer, class_name: "User"
  belongs_to :creator, class_name: "User"
end
