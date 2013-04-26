class SearchClientTest < MiniTest::Unit::TestCase

  def api_response_body
    {
      "_response_info" => {
        "status" => "ok"
      },
      "results" => [
        {
          "web_url" => "https://www.gov.uk/a"
        },
        {
          "web_url" => "https://www.gov.uk/b"
        },
      ]
    }
  end

  def stub_api(search_term)
    stub_request(:get, "https://www.gov.uk/api/?q=carmen").
            with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
            to_return(status: 200, body: api_response_body.to_json)
  end

  should "fetch results" do
    stub_api("carmen")
    expected = ["https://www.gov.uk/a", "https://www.gov.uk/b"]
    assert_equal expected, SearchClient.new.search("carmen")
  end

  should_eventually "support Rummager response format"

  should_eventually "report unexpected responses (eg html error pages)"
end
