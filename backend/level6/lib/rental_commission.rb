class RentalCommission

  attr_reader :insurance_fee, :assistance_fee, :drivy_fee

  def initialize(insurance_fee, assistance_fee, drivy_fee)
    @insurance_fee = insurance_fee
    @assistance_fee = assistance_fee
    @drivy_fee = drivy_fee
  end

  def to_json
    return {"insurance_fee" => @insurance_fee.to_i, "assistance_fee" => @assistance_fee.to_i, "drivy_fee" => @drivy_fee.to_i}
  end

  def total_fee
    return @insurance_fee + @assistance_fee.to_i + @drivy_fee.to_i
  end

end