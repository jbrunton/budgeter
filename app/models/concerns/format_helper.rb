module FormatHelper
  include ActionView::Helpers::NumberHelper

  def currency(number)
    number_with_precision(number, precision: 2, delimiter: ',')
  end

  def serialize_date(date)
    date = date.prev_month # JavaScript dates are zero-indexed
    "Date(#{date.strftime('%Y,%-m,%-d')})"
  end

  def percentage(value)
    number_with_precision(value * 100.0, precision: 1) + '%'
  end
end