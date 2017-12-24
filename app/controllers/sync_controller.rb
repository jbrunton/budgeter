require 'fileutils'
require 'yaml'

class SyncController < ApplicationController
  include ApplicationHelper

  CURRENCY_ATTRIBUTES = ['value', 'balance']

  before_action :set_project, only: [:preview, :sync]

  def preview
    @statements = @project.scan_statements
  end

  def sync
    @project.transactions.delete_all
    @statements = @project.scan
    @statements.each do |statement|
      statement.scan.each do |transaction|
        transaction.save
      end
    end

    Dir.glob(File.join(@project.directory, 'transactions/*.yaml')).each do |filename|
      FileUtils.rm(filename)
    end

    @project.transactions.group_by{ |t| t.date.strftime('%Y-%m-%b') }.each do |key, transactions|
      content = {
        'transactions' => transactions.map { |t| marshal_for_file(t) }.to_h
      }
      File.write(File.join(@project.directory, 'transactions', "#{key}.yaml"), content.to_yaml)
    end

    redirect_to project_transactions_path(@project)
  end

private
  def set_project
    @project = Project.find(params[:id])
  end

  def marshal_for_file(transaction)
    transaction.data_attributes.map do |attr_name, attr_val|
      if CURRENCY_ATTRIBUTES.include?(attr_name)
        [attr_name, currency(attr_val)]
      else
        [attr_name, attr_val]
      end
    end.to_h
  end
end