class StatementsController < ApplicationController
  before_action :set_project

  def import

  end

  def upload
    upload = params[:statement]
    ext = File.extname(upload.original_filename)
    case
      when ext == '.csv'
        result = CurrentAccountParser.new(@project).parse(upload.tempfile)
      when ext == '.pdf'
        result = CreditCardParser.new(@project).parse(upload.tempfile)
      else
        raise "Unsupported file extension."
    end
    notice = "Imported #{result[:imported_transactions].count} transactions"
    notice << " (#{result[:duplicate_transactions].count} duplicates)" if result[:duplicate_transactions].any?
    redirect_to account_transactions_path(result[:account]), notice: notice
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end