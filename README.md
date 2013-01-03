GOV.UK search health check
==========================

This is a fairly basic, fairly hacky tool to test the quality of our search
results.

How it works
------------

The `weighted-search-terms.csv` file contains some of the top search terms from
Directgov and Business Link along with their corresponding traffic numbers. They
then have conditions on the result, with a URL and how far down in the results
it is allowed to appear. The intention is that this provides some measure of
the percentage of users who will find what they are looking for, but take it
with a fairly large pinch of salt.

How to run it
-------------

Against a development box:

    ./test-search.rb weighted-search-terms.csv

Against production:

    SEARCH_BASE=https://www.gov.uk/api/ ./test-search.rb --api-format --slow weighted-search-terms.csv

