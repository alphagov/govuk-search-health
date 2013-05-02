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

First, you'll need to download the search terms:

    bundle exec rake download_checks


Then you have a choice of how to run the tests.

  1. Against a development box:

         bundle exec rake check_search

  2. Through the [frontend](https://github.com/alphagov/frontend):

         SEARCH_BASE=http://www.dev.gov.uk FORMAT=html bundle exec rake check_search

  3. Against the production API:

         SLOW=true SEARCH_BASE=https://www.gov.uk/api/ bundle exec rake check_search

  4. Against the production frontend:

         SEARCH_BASE=https://www.gov.uk FORMAT=html bundle exec rake check_search
