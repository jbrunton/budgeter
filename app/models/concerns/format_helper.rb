module FormatHelper
  include ActionView::Helpers::NumberHelper

  def currency(number)
    number_with_precision(number, precision: 2, delimiter: ',')
  end

  def serialize_date(date)
    "Date(#{date.strftime('%Y,%-m,%-d')})"
  end
end