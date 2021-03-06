# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ActiveRecord::Base
  validates :email, :password_digest, :session_token, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: 6, allow_nil: true }

  after_initialize :ensure_session_token

  has_many(
    :owned_decks,
    class_name: 'Deck',
    foreign_key: :owner_id,
    primary_key: :id
  )
  has_many :deck_shares
  has_many :decks, through: :deck_shares
  has_many :cards, through: :decks
  has_many :responses

  attr_accessor :password


  def password=(password)
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def ensure_session_token
    self.session_token ||= SecureRandom::urlsafe_base64(16)
  end

  def reset_session_token!
    self.session_token = SecureRandom::urlsafe_base64(16)
    self.save!
    self.session_token
  end

  def self.find_by_credentials(params)
    user = User.find_by_email(params[:email])
    if user && user.is_password?(params[:password])
      return user
    else
      return nil
    end
  end

  def review_cards
    return cards.select { |card| card.needs_review?(self.id) }
  end

  def latest_response
    return responses.order('created_at DESC').first if responses.length != 0
  end

end
