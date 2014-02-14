# Pillboxr

Pillboxr is a Ruby wrapper for the National Library of Medicine Pillbox API Service located at [http://pillbox.nlm.nih.gov](http://pillbox.nlm.nih.gov).

The pillbox API provides information from the FDA about various prescription medications.

Previous versions of this library required ActiveResource.  This is no longer the case.

*Note:* This library is designed for use with Ruby 1.9.3 and above, and will not work with earlier versions of Ruby.

***

## Usage

Getting started is fairly easy:

	$ gem install pillboxr

Next obtain an API key. See below for directions on obtaining an API key.  There are several ways to tell Pillboxr about your API key.  All of the following are valid:

```ruby
Pillboxr.api_key = "Your API key as a string." # simple string
Pillboxr.api_key = Pathname.new("/path/to/yaml/or/text/file/containing/only/api/key/as/string") # absolute or relative path
Pillboxr.api_key = File.new("/path/to/yaml/or/text/file/containing/only/api/key/as/string", "r") # file descriptor object
Pillboxr.api_key = Object.new.tap { |obj| obj.define_singleton_method(:key) { "Your API key string" } } # object that responds to 'key' method
```

If you do not specify a key Pillboxr will try to find an api_key.yml in the current working directory and load the key from that file.

Finally:

```ruby
require 'pillboxr' # You may have to require rubygems first

result = Pillboxr.with({:color => :blue, :image => true}) # Get result object with one page of blue pills with images.

result.pages.current.pills # An array with the retrieved pill objects.
```

###### or

```ruby
require 'pillboxr'

result = Pillboxr.color(:blue).image(true).get # Get result of object with one page of blue pills with images associated.

result.pages.current.pills # an array with the retrieved pill objects.
```

***

**Important:** *When chaining query methods you must add the `get` method on the end of the query chain, similar to working with `ActiveRelation` in Rails (where the `all` method indicates completion of the query), so the request can be lazily evaluated.*

***

Both query methods also have block forms that allow fetching of additional result pages. For example:

```ruby
require 'pillboxr'

result = Pillboxr.with({:color => :blue}) do |r|
  r.pages.each do |page|
    page.get # won't retrieve a page that is already retrieved.
  end
end

all_blue_pills = []
result.pages.each { |page| all_blue_pills << page.pills }

all_blue_pills.flatten! # all_blue_pills is now an array of all 2059 blue pills.
```

###### or

```ruby
require 'pillboxr'

result = Pillboxr.color(:blue).get do |r|
  r.pages.each do |page|
    page.get # won't retrieve a page that is already retrieved.
  end
end

all_blue_pills = []
result.pages.each { |page| all_blue_pills << page.pills }

all_blue_pills.flatten! # all_blue_pills is now an array of all 2059 blue pills.
```
You can also pass an additional options hash to the `get` method to explicitly specify the page of results you want.

```ruby
require 'pillboxr'

result = Pillboxr.color(:blue).get(page: 3) # pages are zero indexed.

result.pages.current.pills # an array of the fourth page of blue pill results.
```

You can run the tests by typing `rake` in the library directory.  You may have to install some development gems prior to running the tests by running `bundle install` in the library directory.

You can activate a console session with the pillboxr library already loaded by typing `rake console` in the library directory.

***

The hash passed to the `with` method may include any of the following parameters:

```ruby
:color        => Symbol or Array with multiple colors (see http://pillbox.nlm.nih.gov/API-documentation.html)
:score        => Boolean
:ingredient   => Symbol or Array with multiple ingredients (returned results include all ingredients)
:inactive     => Symbol
:dea          => Symbol or any of 'I, II, III, IV, V'
:author       => String
:shape        => Symbol (Shape or Hex)
:imprint      => Symbol
:product_code => String (Product Code: see http://pillbox.nlm.nih.gov/API-documentation.html - must include the dash)
:image        => Boolean
:size         => Integer for size in millimeters (currently this encompasses a range of +/- 2 mm)
:lower_limit  => Integer for which returned record to start at
```

Please see specific files or the document directory for specific usage examples. Further API documentation available on the  [project homepage](http://pillbox.nlm.nih.gov/NLM_Pillbox_API_documentation_v2_2011.09.27.pdf) (PDF link)

## KNOWN BUGS

* Test coverage is not complete.

* Please note that some XML in the Pillbox API is unescaped.

* Please report additional bugs via [github issues](https://github.com/kgautreaux/pillboxr/issues).

API provided through the generous support by the FDA in both money and resources. Work conducted by NLM at NIH.

Please contact david.hale at nlm.nih.gov for an api key. There is no bandwidth limit currently.

Data is owned by companies, mandatorily licenced for X purposes.
