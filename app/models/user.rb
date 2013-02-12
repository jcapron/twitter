class User < ActiveRecord::Base  
  
  has_many :tweets, :dependent => :destroy
  
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.username = auth.extra.raw_info.username
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end
  
  # Create the following relationship
  has_and_belongs_to_many :followings,
          :association_foreign_key => 'following_id',
          :class_name => 'User',
          :join_table => 'users_followings'

  # Create the follower relationship
  has_and_belongs_to_many :followers,
          :foreign_key => 'following_id',
          :association_foreign_key => 'user_id',
          :class_name => 'User',
          :join_table => 'users_followings'
          
  def all_tweets
    Tweet.find(:all, :conditions => ["user_id in (?)", followings.map(&:id).push(self.id)], :order => "created_at desc")
  end
  
end