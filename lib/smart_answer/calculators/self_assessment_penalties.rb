require "ostruct"

module SmartAnswer::Calculators
  class SelfAssessmentPenalties < OpenStruct
    def filing_date
      parse_date(super)
    end

    def payment_date
      parse_date(super)
    end

    def paid_on_time?
      (filing_date <= filing_deadline) && (payment_date <= payment_deadline)
    end

    def late_filing_penalty
      if overdue_filing_days <= 0
        result = 0
      elsif overdue_filing_days <= 89
        result = 100
      elsif overdue_filing_days <= 179
        
        result = (overdue_filing_days - 89) * 10 + 100
      elsif overdue_filing_days <= 364
        if estimated_bill.value > 6002
          result = 1000 + (estimated_bill.value * 0.05)
        else
          result = 1000 + [300, estimated_bill.value * 0.05].max
        end
      else
        result = 1000 + [600, estimated_bill.value * 0.05].max
      end
      SmartAnswer::Money.new(result)
    end

    def interest
      if overdue_payment_days <= 0
        0
      else
        penalty_interest = penalty_interest(penalty1date) + penalty_interest(penalty2date) + penalty_interest(penalty3date)
        SmartAnswer::Money.new((calculate_interest(estimated_bill.value, overdue_payment_days) + penalty_interest).round(2))
      end
    end

    def total_owed
      SmartAnswer::Money.new((estimated_bill.value + interest.to_f + late_payment_penalty.to_f).floor)
    end

    def total_owed_plus_filing_penalty
      SmartAnswer::Money.new(total_owed.value + late_filing_penalty.value)
    end

    def late_payment_penalty
      if overdue_payment_days <= 30
        0
      elsif overdue_payment_days <= 182
        SmartAnswer::Money.new(late_payment_penalty_part.round(2))
      elsif overdue_payment_days <= 366
        SmartAnswer::Money.new((late_payment_penalty_part * 2).round(2))
      else
        SmartAnswer::Money.new((late_payment_penalty_part * 3).round(2))
      end
    end

    def penalty_interest(penalty_date)
      if payment_date > (penalty_date + 30)
        calculate_interest(late_payment_penalty_part, payment_date - (penalty_date + 30))
      else
        0
      end
    end

    private
    def overdue_filing_days
      (filing_date - filing_deadline).to_i
    end

    def overdue_payment_days
      (payment_date - payment_deadline).to_i
    end

    def late_payment_penalty_part
      0.05 * estimated_bill.value
    end

    def filing_deadline
      submission_method == "online" ? dates[:online_filing_deadline][tax_year.to_sym] : dates[:offline_filing_deadline][tax_year.to_sym]
    end

    def payment_deadline
      dates[:payment_deadline][tax_year.to_sym]
    end

    def penalty1date
      dates[:penalty1date][tax_year.to_sym]
    end

    def penalty2date
      dates[:penalty2date][tax_year.to_sym]
    end

    def penalty3date
      dates[:penalty3date][tax_year.to_sym]
    end

    def parse_date(value)
      Date.parse(value)
    end

    def calculate_interest(amount, number_of_days)
      (amount * (0.03 / 365) * number_of_days).round(10)
    end
  end
end