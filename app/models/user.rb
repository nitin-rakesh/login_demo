class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  attr_accessor :image
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable#, :confirmable

  has_many :pictures, as: :pictureable, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :access_tokens, dependent: :destroy
  before_create :ensure_authentication_token, :generate_key
  validates_presence_of :email, :message => "Please enter email"
  
  # accepts_nested_attributes_for :pictures, reject_if: :image_blank, :allow_destroy => true

  def self.from_facebook_omniauth(auth)
    email = auth.info.email.present? ? auth.info.email : "#{auth.uid}@facebook.com"
    user_exist = User.find_by_email(email)
    if user_exist.nil?
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = email
        user.first_name = auth.info.name.split(' ')[0]
        user.last_name = auth.info.name.split(' ')[1]
        user.user_name = auth.info.name.split(' ')[0].downcase
        user.password = Devise.friendly_token[0,20]
      end
    else
      user_exist.update(provider: auth.provider, access_token: auth.credentials.token, uid: auth.uid, first_name: auth.info.name, last_name: nil)
    end
    user_exist = User.find_by_email(email)
  end

  def self.full_name(user_id)
    first_name = User.find(user_id).first_name rescue nil
    last_name = User.find(user_id).last_name rescue nil
    return first_name + ' ' +last_name
  end

  def generate_key
    self.key = Digest::SHA1.hexdigest(BCrypt::Engine.generate_salt)
  end

  def ensure_authentication_token
    token = self.authentication_token = self.generate_authentication_token
  end

  def generate_authentication_token
    token = Devise.friendly_token
    access = AccessToken.find_or_create_by(token: token, user_id: self.id)
    access
  end
end
