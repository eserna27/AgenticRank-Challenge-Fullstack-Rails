module MoneyHelper
  # Formats an integer-cents amount as "$1,234.00 MXN".
  def format_money(cents)
    pesos = BigDecimal(cents.to_s) / 100
    number_to_currency(pesos, unit: "$", precision: 2, format: "%u%n MXN")
  end
end
