require "test_helper"

class InvestmentTest < ActiveSupport::TestCase
  test "valid investment saves" do
    investment = Investment.new(
      campaign: campaigns(:torre),
      investor: investors(:ana),
      amount: 50_000,
      idempotency_key: SecureRandom.uuid
    )

    assert investment.save
  end

  test "rejects amount below the minimum" do
    investment = Investment.new(
      campaign: campaigns(:torre),
      investor: investors(:ana),
      amount: 10_000,
      idempotency_key: SecureRandom.uuid
    )

    assert_not investment.valid?
  end

  test "idempotency_key must be unique" do
    key = SecureRandom.uuid
    Investment.create!(
      campaign: campaigns(:torre),
      investor: investors(:ana),
      amount: 50_000,
      idempotency_key: key
    )

    duplicate = Investment.new(
      campaign: campaigns(:torre),
      investor: investors(:luis),
      amount: 60_000,
      idempotency_key: key
    )

    assert_not duplicate.valid?
  end
end
