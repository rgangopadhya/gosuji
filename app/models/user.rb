class User < ActiveRecord::Base
  has_many :games_as_black_player, :class_name => 'Game', :foreign_key => :black_player_id
  has_many :games_as_white_player, :class_name => 'Game', :foreign_key => :white_player_id
  has_many :games_as_creator, :class_name => 'Game', :foreign_key => :creator_id

  before_save { self.email = email.downcase }
  before_validation :clean_data

  VALID_USERNAME_REGEX = /\A[[[:ascii:]]&&[^:;]]+\Z/
  wrong_format_msg = 'can contain any ASCII character other than ":" and ";"'
  validates :username, presence: true, uniqueness: true,
    length: { minimum: 2, maximum: 20},
    format: { with: VALID_USERNAME_REGEX, message: wrong_format_msg }

  # only validate email if not blank
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false },
    unless: Proc.new { |u| u.email.blank? }

  validates :password, length: { minimum: 6 }
  # has_secure_password gives us validation for password and confirmation
  # also creates password_digest and the method 'authenticate' for user instances
  has_secure_password

  def all_games
    (games_as_black_player + games_as_white_player).sort { |a, b| b.created_at <=> a.created_at }
  end

  def active_games
    all_games.select { |game| game.active? }
  end

  def finished_games
    all_games.select { |game| game.finished? }
  end

  def started_games
    all_games.select { |game| game.not_open? }
  end

  private

  def clean_data
    # trim whitespace from beginning and end of string attributes
    changes.each do |name, change|
      if send(name).respond_to?(:strip)
        send("#{name}=", change.last.strip)
      end
    end

    # normalize white space in username
    # todo: inform user that this has happened
    send("username=", send("username").split.join(' '))
  end


end
