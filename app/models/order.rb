class Order < ApplicationRecord
    belongs_to :content, required: false
    belongs_to :request, required: false

    belongs_to :buyer, class_name: "User"
    belongs_to :creator, class_name: "User"

    has_many :reviews

    enum status: [:inprogress, :completed]
end
