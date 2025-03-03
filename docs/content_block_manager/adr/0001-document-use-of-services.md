# 1. Document use of services

Date: 2024-01-10

## Status

Accepted

## Context

A long-established pattern in Rails has been to have Ruby classes that sit separate from
the usual Model, View, Controller approach, carrying out things like business logic, API
calls etc and putting these in a `app/services` directory. We have used this approach
for various things in this project, but recently we've noticed that we were a little 
inconsistent with our approach to services.

Some services carry out business logic (e.g `CreateEditionService`), while others make
API calls, returning Ruby `Data` classes. 

## Decision

We have decided to continue our use of services for business logic, but if a service
returns an object, we should have a class-level method on that class to return the 
object. For example:

### Before

We have a data class called `IceCream`, which looks like this:

```ruby
class IceCream < Data(:id, :flavour)
end
```

And a service method called `GetIceCream`:

```ruby
class GetIceCream
  def get_ice_cream_for_van(van_id)
    api_response = call_some_api_here(van_id)
    
    IceCream.new(api_response["id"], api_response["flavour"])
  end
end
```

## After

We move all the logic to the `IceCream` class:

```ruby
class IceCream < Data(:id, :flavour)
  class << self
    def for_van(van_id)
      api_response = call_some_api_here(van_id)

      IceCream.new(api_response["id"], api_response["flavour"])
    end
  end
end
```

This will then allow us to call `IceCream.for_van(van_id)`, which maps better with
how database model classes operate in ActiveRecord.

We propose keeping Service classes around, but only in the following circumstances:

- They do not return a model object
- They carry out business logic which cannot easily be expressed in a model
- They have a single `call` method, which operates on an instance of the class (eg. `MyService.new(args).call`)

## Consequences

This reduces the risk of the `app/services` dir being a repository for all sorts of different
types of code and forces us to think about organising our code in a more object-oriented way.
