module Models

  class Price

    attr_accessor :amount
    attr_accessor :currency

    def initialize(amount, currency)
      @amount = amount
      @currency = currency
    end

    def to_s
      "Price #{amount} #{currency}"
    end

    def ==(another_price)
      self.amount == another_price.amount && self.currency == another_price.currency
    end

  end

end