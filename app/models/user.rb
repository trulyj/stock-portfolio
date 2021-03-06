class User < ApplicationRecord
  has_many :stocks, dependent: :destroy
  has_many :transactions, dependent: :destroy
  after_initialize :init

  def init
    self.balance  ||= 5000.00
  end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #attr_accessible :email, :password, :password_confimation
end
