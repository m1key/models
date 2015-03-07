module Models

  class Country

    attr_reader :code

    def initialize(code)
      @code = code
    end

    def to_s
      "Country #{code}"
    end

    def ==(another_country)
      self.code == another_country.code
    end

  end

end
