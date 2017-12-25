module CurrencyHelper
  include ActionView::Helpers::NumberHelper

  def currency(number)
    number_with_precision(number, precision: 2, delimiter: ',')
  end
end