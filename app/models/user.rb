class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :validatable, authentication_keys: [:login]

  attr_writer :login

  has_one :billing_customer
  has_one :subscription, dependent: :destroy

  has_many :passport_phrases

  validates :username, presence: :true, uniqueness: { case_sensitive: false }
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true
  # validates :password, length: { minimum: 6 }

  after_create :update_fingerprint
  after_create :create_stripe_customer


  def generate_temporary_authentication_token
    # self.authentication_token = Devise.friendly_token
    token = Devise.friendly_token
    tokens = (self.tokens || []).push(token)
    self.update(tokens: tokens)
    return token
  end

  def clear_temporary_authentication_token
    self.authentication_token = nil
    self.save
  end
  
  def self.make_unique(username)
    orig = username
    while User.find_by(username: username).present?
      rd = rand(1..100)
      username = orig + rd.to_s
    end
    return username
  end

  def admin?
    array = ["rockystorm@gmail.com", "nabeel@iqra.life", "sundusabushar16@gmail.com"]
    bool = false
    array.each do |a|
      if self.email.include? a
        return true
      else
      end
    end
    return bool
  end

  def self.is_admin? user
    if user.present?
      array = ["rockystorm@gmail.com", "nabeel@iqra.life", "sundusabushar16@gmail.com"]
      bool = false
      array.each do |a|
        if user.email.include? a
          return true
        else
        end
      end
      return bool
    else
      return false
    end
  end


  def login
    @login || self.username || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["username = :value OR lower(email) = lower(:value)", { :value => login }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def friend(user_id)
    # you
    friends = self.friends
    friends = friends.push(user_id)
    self.update(friends: friends.uniq)
    # them
    them = User.find(user_id)
    friends = them.friends
    friends = friends.push(self.id)
    them.update(friends: friends.uniq)
  end

  def defriend(user_id)
    # you
    friends = self.friends
    friends = friends - [user_id]
    self.update(friends: friends.uniq)
    # them
    them = User.find(user_id)
    friends = them.friends
    friends = friends - [self.id]
    them.update(friends: friends.uniq)
  end


  # 
  def chatrooms
    cr = ChatroomUser.where(user_id: self.id).pluck(:chatroom_id)
    return Chatroom.where(id: cr)
  end

  def conversations
    return Conversation.where("sender_id = ? OR receiver_id = ?", user.id, user.id)
  end

  def unread_conversations
    convos = self.conversations

    hash = {}

    convos.each do |c|
      hash[c.recipient(self).id] = c.unread_message_count(self)
    end


    return hash
    # return Conversation.where(sender_id: self.id) + Conversation.where(receiver_id: self.id)
  end

  def following?(id) 
    if self.following.include? id
      return true
    else
      return false
    end
  end

  # 
  def friends_list
    x = self.following
    y = self.followers
    x & y # => [2, 4]
    return User.find(x & y)
  end

  # 
  def make_uniq_username
    un = self.email.split("@")[0]

    i = 1
    while User.find_by_username(un).present? == true
      i = i + 1
      un = un + i.to_s
    end

    self.update(username: un)
  end

  # 
  def subscribed?
    # if self.email.include? "farhan"
    #   return true
    # end

    array = ["sundusabushar16@gmail.com", "rockystorm@gmail.com", "nabeel@iqra.life"]
    array.each do |a|
      if self.email == a
        return true
      else
      end
    end

    if self.subscription.present? && self.subscription.active == true
      return true
    elsif self.subscription.present? && self.subscription.active == false
      if self.subscription.current_period_ends_at != nil &&
        (self.subscription.current_period_ends_at > DateTime.now)
        return true
      else
        return false
      end
    else
      return false
    end
  end

  # 
  def last_log
    return Abstraction.where(last_edited_by: self.id).order("updated_at ASC").last
  end

  def update_fingerprint
    code = rand(36**8).to_s(36)
    while User.find_by_fingerprint(code).present? == true
      code = rand(36**8).to_s(36)
    end
    self.update(fingerprint: code)
    return code
  end

  def create_stripe_customer
    return
    customer = Stripe::Customer.create({
      description: "#{self.email}",
      email: "#{self.email}"
    })

    stripe_id = customer.id
    
    plan_id = BillingPlan.first.stripeid

    subscription = ::Subscription.new(
      plan_id: plan_id,
      stripe_id: stripe_id,
      current_period_ends_at: nil
    )

    self.update!(stripe_id: stripe_id, subscription: subscription)
    self.subscription.update(active: false)

  end

  # 
  def sfy
    return "#{self.username}'#{"s" if self.username[-1] != "s"}"
  end

  # def points
  #   return self.user_missions.count * 10
  # end

end

