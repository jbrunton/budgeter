class VerificationState
  def initialize(transactions)
    @transactions = transactions
  end

  def compute_state
    if @transactions.any?
      verified_transactions = @transactions.select{ |t| t.categorized? }
      verified_spend = verified_transactions.map{ |t| t.value.abs }.reduce(0, :+)
      total_spend = @transactions.map{ |t| t.value.abs }.reduce(0, :+)
      unverified_spend = total_spend - verified_spend
      {
        percent_verified_transactions: verified_transactions.size.to_f * 100.0 / @transactions.size,
        verified_spend: verified_spend.to_f,
        unverified_spend: unverified_spend.to_f,
        percent_verified_spend: (verified_spend * 100.0 / total_spend).to_f,
        percent_unverified_spend: (unverified_spend * 100.0 / total_spend).to_f,
      }
    else
      {
        percent_verified_transactions: 0,
        verified_spend: 0,
        unverified_spend: 0,
        percent_verified_spend: 0,
        percent_unverified_spend: 0,
      }
    end
  end
end