
crumb :projects do
  link 'Projects', projects_path
end

crumb :project do |project|
  link project.name, project_path(project)
  parent :projects
end

crumb :project_accounts do |project|
  link 'Accounts', project_accounts_path(project)
  parent :project, project
end

crumb :account do |account|
  link account.name, account_path(account)
  parent :project_accounts, account.project
end

crumb :account_transactions do |account|
  link 'Transactions', account_transactions_path(account)
  parent :account, account
end

crumb :backup_project do |project|
  link 'Backup', backup_project_path(project)
  parent :project, project
end

crumb :import_statement do |account|
  link 'Import Statement', import_statement_account_path(account)
  parent :account, account
end

crumb :train_project do |project|
  link 'Train', train_project_path(project)
  parent :project, project
end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).