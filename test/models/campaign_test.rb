require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  test "raised sums its investments" do
    campaign = campaigns(:torre)

    assert_equal 4_000_000, campaign.raised
  end

  test "progress_pct is capped at 100" do
    campaign = campaigns(:roma)

    assert_equal 100, campaign.progress_pct
  end

  test "projected_return uses integer cents without floats" do
    campaign = campaigns(:torre)
    # 500 MXN = 50_000 cents, 14% annual, 18 months → 50_000 * 0.14 * 1.5 = 10_500 cents
    result = campaign.projected_return(Investment::MIN_AMOUNT)

    assert_kind_of BigDecimal, result
    assert_equal BigDecimal("10500"), result
  end
end
