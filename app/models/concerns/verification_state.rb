module VerificationState
  def verification_state
    verified_transactions = transactions.select{ |t| !t.category.blank? || t.verified }
    verified_spend = verified_transactions.map{ |t| t.value.abs }.reduce(0, :+)
    total_spend = transactions.map{ |t| t.value.abs }.reduce(0, :+)
    unverified_spend = total_spend - verified_spend
    {
      percent_verified_transactions: verified_transactions.size.to_f * 100.0 / transactions.size,
      verified_spend: verified_spend.to_f,
      unverified_spend: unverified_spend.to_f,
      percent_verified_spend: (verified_spend * 100.0 / total_spend).to_f,
      percent_unverified_spend: (unverified_spend * 100.0 / total_spend).to_f,
    }
  end
end