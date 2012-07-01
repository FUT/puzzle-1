[#1] International trade (http://puzzlenode.com/puzzles/1-international-trade)

Problem

You have been given two files. The first is an XML file containing the conversion rates for exchanging one currency with
another. The second is a CSV file containing sales data by transaction for an international business. Your goal is to
parse all the transactions and return the grand total of all sales for a given item.

What is the grand total of sales for item DM1182 across all stores in USD currency?

Notes
<ul>
    <li>After each conversion, the result should be rounded to 2 decimal places using bankers rounding.</li>
    <li>Some conversion rates are missing; you will need to derive them using the information provided.</li>
    <li>Since we are working with financial transactions, we need to avoid floating point arithmetic errors.</li>
</ul>