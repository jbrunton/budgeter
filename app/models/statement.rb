class Statement
  attr_reader :project
  attr_reader :start_date

  include VerificationState

  def initialize(project, start_date)
    @project = project
    @start_date = start_date
  end

  def name
    start_date.strftime('%b %Y')
  end

  def transactions
    @project.transactions
      .within_month(@start_date)
  end

  def path
    Rails.application.routes.url_helpers.project_statement_path(@project, @start_date.strftime('%Y-%m-%d'))
  end

  def self.for(project)
    transactions = project.transactions.by_date
    first_date = transactions.first.date.beginning_of_month
    last_date = transactions.last.date

    dates = DateRange.new(first_date, last_date, true).to_a

    dates.map do |date|
      Statement.new(project, date)
    end
  end
end
