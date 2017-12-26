class StatementsController < ApplicationController
  before_action :set_project

  def import

  end

  def upload
    upload = params[:statement]
    ext = File.extname(upload.original_filename)
    case
      when ext == '.csv'
        imported_transactions = CurrentAccountParser.new(@project).parse(upload.tempfile)
      when ext == '.pdf'
        imported_transactions = CreditCardParser.new(@project).parse(upload.tempfile)
      else
        raise "Unsupported file extension."
    end
    redirect_to account_transactions_path(imported_transactions.first.account), notice: "Imported #{imported_transactions.count} transactions."
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end