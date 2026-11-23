class Investment < ApplicationRecord
  # Minimum investment: 500.00 MXN → 50_000 cents.
  MIN_AMOUNT = 50_000

  belongs_to :campaign
  belongs_to :investor

  # Persist amount as integer cents (idempotent: safe if applied more than once).
  normalizes :amount, with: ->(amount) { BigDecimal(amount.to_s).round.to_i }

  validates :amount, numericality: { greater_than_or_equal_to: MIN_AMOUNT, only_integer: true }
  validates :idempotency_key, presence: true, uniqueness: true
end
