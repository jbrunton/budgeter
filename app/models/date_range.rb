class DateRange
  def initialize(start_date, end_date, step_by_month = false)
    @start_date = start_date
    @end_date = end_date
    @step_by_month = step_by_month
  end

  def to_a
    dates = []
    next_date = dates.last || @start_date
    while next_date < @end_date
      dates << next_date
      if @step_by_month
        next_date = next_date.next_month
      else
        next_date = next_date + 1.day
      end
    end
    dates
  end
end
