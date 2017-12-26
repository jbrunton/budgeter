# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

project = Project.create(name: 'JBRUNTON', directory: '/Users/John/budgets')
account = project.accounts.create(name: 'JBRUNTON', account_type: 'current')

account.transactions.create(
  date: 5.days.ago,
  date_index: 0,
  description: 'ATM',
  value: -10,
  balance: 490
)


account.transactions.create(
  date: 5.days.ago,
  date_index: 1,
  description: 'Walgreens',
  value: -20.00,
  balance: 470
)
