#Versi HTTP Client
When you need a statefull http client to provide a wide range of task, from integration automation testing to creating a generic API for your backend, **Versi HTTP Client** takes an YAML configuration or raw Hash and generates all the wiring and objects required for your needs.

**Early stages warning**:

Work in process and there are several cases where errors need to be handled, processing of optional parameters to action methods needs to be considered, and sanitizing input parameters against the required and optional parameters for action methods.

This is just a juck and dirty starting point.

## Configuration Example

    google_prod:
      base_url: 'https://www.google.com'
      actions:
        web_search:
          path: '/search'
          required_params:
            - q
          optional_params:
            - start
          required_params:
            - q
          optional_params: []
          request_method: get
          

## Creating the API


For each site, referenced by the top level Hash key, in this case there is one site named **google_prod**, an instance is created for you that is accessible by the site name.  Then given the actions for a site, for example, **web_search**, instance methods are created for you on the site Class.  

## Examle Usage

    cfg = YAML::load_file "/some/path/ex.yml"

### API object

    google_api  = VersiHTTPClient.new(cfg)

### Call action methods on the instance

    google_api.google_prod.web_search('q' => 'blah')

Or perform an image search, just add an additional key to the param hash passwed to we_search:

    google_api.google_prod.web_search('q' => 'blah', 'tbm' => 'isch')

The action method will return an instance of HTTP::Message which you can then
get further details, such as the request body, header information ,etc..  See the documentation for httpclient for full details.

### Itterating over search results for the google_api

Say you want to pull the text from the link heading, 5 pages of results deep.  Simply set a key in the params passed to web_search called start:

    start := (page_number * 10) - 10), for page_number > 1


Ex:

    require 'nokogiri'
    num_pages=5
    1.upto(num_pages) do |page_number|
      params = {'q' => 'blah'}
      if page_number > 1
        params['start'] = (10*page_number)-10
      end

      res = google_api.google_prod.web_search(params)
      doc = Nokogiri.parse(res.body)

      # display titles 
      1.upto(10) do |ct|
        puts doc.search("//*[@id=\"ires\"]/ol/li[#{ct}]/h3/a").children.map { |i| i.to_s}.join(" ") 
      end


