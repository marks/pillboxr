# Pillboxr

Pillboxr is a Ruby wrapper for the National Library of Medicine Pillbox API Service located at [http://pillbox.nlm.nih.gov](http://pillbox.nlm.nih.gov).

The pillbox API provides information from the FDA about various prescription medications.

The current version of this library has two forms.  The first (preferred) version does not depend on any gems except for `httparty`.  The second version depends upon `active_resource`.  This version of Pillboxr inherits from ActiveResource to perform it's XML wrapping so ActiveResource 3.2.6 is a requirement for using the wrapper. This version will be deprecated in the future. Please see the doc directory for documentation on using the library.

*Note:* This library is designed for use with Ruby 1.9 and will not work with earlier versions of Ruby.

***

## Usage

Getting started is fairly easy:

	$ gem install pillboxr

```ruby
require 'pillboxr' # You may have to require rubygems first

Pillboxr.api_key = 'YOUR API KEY HERE' # See below for directions on obtaining an API key

Pillboxr.with(:image => true)
```

###### or

```ruby
Pillboxr.image(true) # Find all pills in the database with images associated
```

You can run the tests by typing rake in the library directory.  You may have to install some development gems prior to running the tests.

***

The hash passed to the with method may include any of the following parameters:

```ruby
:color       => Symbol or Array with multiple colors (see http://pillbox.nlm.nih.gov/API-documentation.html)
:score       => Boolean
:ingredient  => Symbol or Array with multiple ingredients (returned results include all ingredients)
:inactive    => Symbol
:dea         => Symbol or any of 'I, II, III, IV, V'
:author      => String
:shape       => Symbol (Shape or Hex)
:imprint     => Symbol
:prodcode    => Symbol (Product Code: see http://pillbox.nlm.nih.gov/API-documentation.html)
:image       => Boolean
:size        => Integer for size in millimeters (currently this encompasses a range of +/- 2 mm)
:lower_limit => Integer for which returned record to start at (currently non-functional)
```

Please see specific files or the document directory for specific usage examples. Further API documentation available on the  [project homepage](http://pillbox.nlm.nih.gov/NLM_Pillbox_API_documentation_v2_2011.09.27.pdf) (PDF link)

## KNOWN BUGS

* Please note that some XML in the Pillbox API is unescaped.

API provided through the generous support by the FDA in both money and resources. Work conducted by NLM at NIH.

Please contact david.hale at nlm.nih.gov for an api key. There is no bandwidth limit currently.

Data is owned by companies, mandatorily licenced for X purposes.