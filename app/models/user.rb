class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one_attached :avatar
  has_many :contents
  has_many :requests
  has_many :offers

  has_many :buying_orders, foreign_key: "buyer_id", class_name: "Order"
  has_many :selling_orders, foreign_key: "creator_id", class_name: "Order"

  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower


  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :confirmable

  validates :full_name, presence: true, length: {maximum: 50}
  validates :username, uniqueness: true, if: -> { username.present? }

  def self.from_omniauth(auth)
    user = User.where(email: auth.info.email).first

    if user
      if !user.provider
        user.update(uid: auth.uid, provider: auth.provider, image: auth.info.image)
      end
      return user
    else
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.full_name = auth.info.name   # assuming the user model has a name
        user.image = auth.info.image # assuming the user model has an image

        user.uid = auth.uid
        user.provider = auth.provider

      end
    end
  end

  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end
end
#   def generate_pin
#     self.pin = SecureRandom.hex(2)
#     self.phone_verified = false
#     save
#   end

#   def send_pin
#     @client = Twilio::REST::Client.new
#     @client.messages.create(
#       from: '+15034043616',
#       to: self.phone,
#       body: "Your Ceefuu pin is #{self.pin}"
#     )
#   end

#   def verify_pin(entered_pin)
#     update(phone_verified: true) if self.pin == entered_pin
#   end
# end