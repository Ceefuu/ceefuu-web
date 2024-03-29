class Category < ApplicationRecord
    extend FriendlyId
    friendly_id :name, use: :slugged

    has_many :contents
    has_many :requests
end
