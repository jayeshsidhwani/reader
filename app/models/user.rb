class User < ActiveRecord::Base

  # Constants
  PER_PAGE = 25

  #GEMS USED
  extend FriendlyId
  friendly_id :username, use: :slugged
  
  devise :database_authenticatable, :token_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :confirmable
  include SentientUser
  
  #ACCESSORS
  attr_accessible :email, :password, :remember_me, :reset_password_token, :reset_password_sent_at, :unconfirmed_email, :authentication_token, :authentication_id_at_signup, :name, :unconfirmed_email, :confirmation_token, :confirmed_at, :confirmation_sent_at, :plan_genre, :sign_in_count, :last_sign_in_at, :is_paying_customer, :username, :slug, :description
  
  attr_accessible :incoming_channel
  attr_accessor :incoming_channel
  
  #ASSOCIATIONS
  has_many :my_feeds             , :dependent => :destroy
  has_many :my_entries
  has_one  :authentication       , :dependent => :destroy
  has_many :tags                 , :dependent => :destroy
  
  #NESTED 
  #VALIDATIONS
  validates :password , :length => { :within => 8..40, on: :create }, :presence => { on: :create }, 
                        :format => { :with => Safai::Regex::PASSWORD, :message => "too weak", on: :create }
  validates :email    , :uniqueness => { case_sensitive: false }, :length => { :minimum => 3 }, 
                        :format => { :with => Safai::Regex::EMAIL, :message => "invalid format"}, :presence => true
  validates :name     , :presence => true, :if => :non_device_forms, :length => { :minimum => 3 }, :if => :non_device_forms
  validates :username , :uniqueness => { case_sensitive: false }, presence: true, :length => { :minimum => 3 }
  
  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES  
  #OTHER METHODS
  
  def reauthenticate_google?
    self.authentication.reauthenticate_google?
  end
  
  def token
    self.authentication.token
  end
  
  def to_s
    name.blank? ? self.email : self.name
  end
    
  def is_admin?
    (email == "rp@pykih.com" or email == "ritvij.j@gmail.com" or email == "modimihir@gmail.com") ? true : false
  end
  
  def entries_count(g, akid)
     if g == "h"
       return MyEntry.read.by_user(self).count.to_s
     elsif g == "r"
       return MyEntry.to_read.by_user(self).count.to_s
     elsif g == "s"
       return MyEntry.star.by_user(self).count.to_s
     elsif g == "a"
       return MyEntry.where("my_entries.my_feed_id = ?", akid).count.to_s
     else
       return MyEntry.by_user(self).count.to_s
     end
   end

  #JOBS
  #PRIVATE
  private
  
  def before_create_set
    self.authentication_token = SecureRandom.hex
    true
  end
  
  def non_device_forms
    incoming_channel.eql? "change_password"
  end
    
end
