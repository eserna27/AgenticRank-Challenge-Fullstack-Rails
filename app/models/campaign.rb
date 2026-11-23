class Campaign < ApplicationRecord
  PRODUCTS = %w[DEUDA COPROPIEDAD].freeze
  STATUSES = %w[open funded closed].freeze

  has_many :investments, dependent: :destroy

  # Persist goal as integer cents (idempotent: safe if applied more than once).
  normalizes :goal, with: ->(goal) { BigDecimal(goal.to_s).round.to_i }

  validates :name, presence: true
  validates :product, inclusion: { in: PRODUCTS }
  validates :goal, numericality: { greater_than: 0, only_integer: true }
  validates :annual_rate_bps, numericality: { greater_than_or_equal_to: 0 }
  validates :term_months, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }
  validates :closes_on, presence: true

  # Sum of investment amounts in integer cents.
  def raised
    investments.sum(:amount)
  end

  def progress_pct
    return 0 if goal.zero?

    [(raised * 100 / goal), 100].min
  end

  # Returns projected return in cents for an investment amount (cents),
  # using BigDecimal math (never floats).
  def projected_return(amount)
    BigDecimal(amount.to_s) *
      BigDecimal(annual_rate_bps) / 10_000 *
      BigDecimal(term_months) / 12
  end

  def funded?
    raised >= goal
  end

  def refresh_status!
    update!(status: "funded") if funded? && status == "open"
  end
end
