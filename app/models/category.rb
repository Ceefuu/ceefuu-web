class Category < ApplicationRecord
    has_many :contents
    has_many :requests
end
