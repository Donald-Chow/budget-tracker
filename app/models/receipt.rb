class Receipt < ApplicationRecord
  has_many :items, dependent: :destroy
  has_one_attached :photo

  validates :store, presence: true
  validates :date, presence: true

  accepts_nested_attributes_for :items, allow_destroy: true

  default_scope { where(date: Date.current.beginning_of_month..Date.current.end_of_month) }
end
