class Transaction < ApplicationRecord
    belongs_to :buyer, class_name: "User", optional: true
    belongs_to :creator, class_name: "User", optional: true
    belongs_to :content, optional: true
    belongs_to :request, optional: true

    enum status: [:approved, :pending, :rejected]
    enum transaction_type: [:trans, :withdraw]
    enum source_type: [:system, :stripe]
end
