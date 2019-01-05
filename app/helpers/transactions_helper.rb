module TransactionsHelper
  def month_options_for(project)
    transactions = project.transactions.order('date')
    first_date = transactions.first.date.beginning_of_month
    last_date = transactions.last.date
    DateRange.new(first_date,last_date, true).to_a
      .map{ |date| [date.strftime('%b %Y'), date.strftime('%Y-%m-%d')] }
  end

  def tr_sort_options
    [['Date', 'date'], ['Amount', 'amount']]
  end
end
