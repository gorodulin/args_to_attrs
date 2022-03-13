# Args to Attrs - Easy way to set attibutes from method arguments

> Keywords: #ruby #arguments #method #arguments #gem #pet #binding #args_to_attrs #p20211121a

## Install

Add to your `Gemfile`:

```ruby
gem "args_to_attrs"
```

Then run:

```ruby
bundle install
```

## How to use

```ruby
require "args_to_attrs"

class 

  def initialize(address, subj, text, cc:, **extra)
    binding.args_to_attrs!
  end

  attr_accessor :address, :subj, :text, :cc

end
```