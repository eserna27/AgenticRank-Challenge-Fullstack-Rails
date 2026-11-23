class InvestmentsController < ApplicationController
  before_action :set_campaign, only: [:create]
  before_action :verify_investment, only: [:create]

  def create
    @investment = @campaign.investments.build(
      idempotency_key: investment_params[:idempotency_key],
      investor: Current.investor,
      amount: mxn_to_cents(investment_params[:amount])
    )

    if @investment.save
      @campaign.refresh_status!
      prepare_success_assigns
      respond_to_success
    else
      @recent_investments = @campaign.investments.order(created_at: :desc).limit(10)
      respond_to do |format|
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { render "campaigns/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def investment_params
    params.require(:investment).permit(:amount, :idempotency_key)
  end

  # Form collects whole MXN pesos; persistence uses integer cents.
  def mxn_to_cents(value)
    return nil if value.blank?

    (BigDecimal(value.to_s) * 100).round
  end

  def prepare_success_assigns
    @recent_investments = @campaign.investments.order(created_at: :desc).limit(10)
    @new_investment = Investment.new
  end

  def respond_to_success
    respond_to do |format|
      # Render explicitly so a before_action can halt the chain. A bare
      # `format.turbo_stream` only schedules the implicit render that runs
      # after the action.
      format.turbo_stream { render :create }
      format.html { redirect_to @campaign }
    end
  end

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def verify_investment
    @investment = @campaign.investments.find_by(idempotency_key: investment_params[:idempotency_key])
    return if @investment.blank?

    prepare_success_assigns
    respond_to_success
  end
end
