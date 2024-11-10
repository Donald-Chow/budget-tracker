class Receipt < ApplicationRecord
  has_many :items, dependent: :destroy

  validates :store, presence: true

  accepts_nested_attributes_for :items, allow_destroy: true
end
