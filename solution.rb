require 'bigdecimal'
require 'csv'
require 'nokogiri'

REQUIRED_PRODUCT = 'DM1182'
REQUIRED_CURRENCY = 'USD'

# Sum all transfer prices for required product by currencies
_, *all_transfers = CSV.open('trans.csv').read
required_transfers = all_transfers.map do |_, name, price|
  price if name == REQUIRED_PRODUCT
end.compact
grouped_transfers = required_transfers.map(&:split).group_by {|_, currency| currency}
prices = grouped_transfers.each_pair do |currency, prices|
  grouped_transfers[currency] = prices.map do |price, _|
    BigDecimal.new price
  end.reduce(&:+)
end

# Read transfer rates
rates_xml = File.read 'rates.xml'
parsed_rates = Nokogiri::XML.parse rates_xml
all_rates = parsed_rates.css('rate').inject({}) do |memo, rate|
  attrs = ['from', 'to', 'conversion'].inject({}) do |attrs, node|
    attrs.merge node => rate.css(node).text
  end
  memo[attrs['from']] ||= {}
  memo[attrs['from']][attrs['to']] = BigDecimal.new(attrs['conversion'])
  memo
end

# Calculate transfer chains from all currencies into required currency
# We have to store chains to round values on each transfer
rates = {REQUIRED_CURRENCY => [1]}
while rates.count != all_rates.count
  one_step_transfer = all_rates.map do |currency, rate|
    currency if (rates.keys & rate.keys).any?
  end.compact
  one_step_transfer.each do |currency|
    transfer_currency = (rates.keys & all_rates[currency].keys).first
    rates[currency] = rates[transfer_currency] | [all_rates[currency][transfer_currency]]
  end
end

# Calculate resulting sum with rounding to two decimal places after each transfer
File.open('output.txt', 'w') do |file|
  file << prices.map do |currency, price|
    rates[currency].inject(price) do |result, rate|
      (result * rate).round 2
    end
  end.reduce(&:+).to_f
end


