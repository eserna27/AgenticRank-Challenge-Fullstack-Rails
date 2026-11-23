require "test_helper"

class InvestmentsControllerTest < ActionDispatch::IntegrationTest
  test "valid investment responds with a turbo stream" do
    campaign = campaigns(:torre)

    assert_difference "Investment.count", 1 do
      post campaign_investments_path(campaign),
           params: { investment: { amount: 600, idempotency_key: SecureRandom.uuid } },
           as: :turbo_stream
    end

    assert_equal Mime[:turbo_stream].to_s, @response.media_type
    assert_includes @response.body, "campaign_#{campaign.id}_progress"
    assert_includes @response.body, "recent_investments"
  end

  test "creating an investment increments the count" do
    campaign = campaigns(:torre)

    assert_difference "Investment.count", 1 do
      post campaign_investments_path(campaign),
           params: { investment: { amount: 750, idempotency_key: SecureRandom.uuid } }
    end
  end

  test "duplicate idempotency_key does not create a second investment" do
    campaign = campaigns(:torre)
    key = SecureRandom.uuid

    assert_difference "Investment.count", 1 do
      post campaign_investments_path(campaign),
           params: { investment: { amount: 600, idempotency_key: key } },
           as: :turbo_stream
    end

    assert_no_difference "Investment.count" do
      post campaign_investments_path(campaign),
           params: { investment: { amount: 600, idempotency_key: key } },
           as: :turbo_stream
    end

    assert_response :success
  end

  test "campaign is marked funded when an investment reaches the goal" do
    campaign = campaigns(:torre)
    # Raised is 4_000_000 cents; goal is 500_000_000 cents. 4_960_000 MXN closes the gap.
    remaining_mxn = (campaign.goal - campaign.raised) / 100

    post campaign_investments_path(campaign),
         params: { investment: { amount: remaining_mxn, idempotency_key: SecureRandom.uuid } }

    assert_equal "funded", campaign.reload.status
  end

  test "invalid investment re-renders the form with errors" do
    campaign = campaigns(:torre)

    assert_no_difference "Investment.count" do
      post campaign_investments_path(campaign),
           params: { investment: { amount: 100, idempotency_key: SecureRandom.uuid } },
           as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "invest_form"
  end
end
