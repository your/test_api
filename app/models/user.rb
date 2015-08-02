class User < ActiveRecord::Base
  
  include SecureToken
  #before_create :generate_authentication_token
  
  has_secure_password
  has_secure_token
  
  has_many :habit_systems
  has_many :habits
        
  #def generate_authentication_token
  #  loop do
  #    self.authentication_token = SecureRandom.base64(64)
  #    break unless User.find_by(authentication_token: authentication_token)
  #  end
  #end
  
  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end
  
end
