require 'hashie'

module Spodunk
  class Row
    attr_reader :mash, :original, :timestamp

    delegate :values, :keys, :to => :mash
    delegate :values, :to => :original, prefix: true
    # expects vals and headers to be 1 to 1


    def initialize(vals, headers)
      slugged_headers = headers.map{|h| h.slugify}
      @mash = Hashie::Mash.new(Hash[slugged_headers.zip(vals)])
      @original = @mash.dup.freeze
      @timestamp = Time.now 
    end


    def changes(opts={})
      offset = opts[:col_offset]
      diff.inject({}) do |h, (k,v)|
        x = offset ? mash_index(k) + offset : k
        h[x] = v.last
 
        h
      end
    end

    # by default, spreadsheets are assumed to be numbered with columns
    # starting from 1
    def itemized_changes
      changes(col_offset: 1)
    end

    # finds difference between @originals and @mash
    def diff
      dirty_diff(@original, @mash)
    end

    def clean?
      diff.empty?
    end

    def dirty?
      !clean?
    end


    def [](key)
      @mash[mash_key(key)]
    end

    def []=(key, val)
      @mash[mash_key(key)] = val
    end

    def method_missing(foo, *args, &blk)
      foop = foo.to_s.match(/\w+(?==)?/).to_s
      if @mash.keys.include?(foop)
        @mash.send(foo, *args)
      else
        super
      end
    end

    def respond_to?(foo, inc_private=false)
      foop = foo.to_s.match(/\w+(?=$|=)/).to_s
      if @mash.keys.include?(foop)
        true
      else
        super
      end
    end


    def attributes
      @mash.stringify_keys
    end

    def assign_attributes(hsh)
      new_atts = hsh.inject({}) do |h, (k, v)|
        if has_attribute?(k)
          # ignore attributes that aren't part of the model
          h[mash_key(k)] = v
        end

        h
      end

      @mash.merge!( new_atts )
    end


    def has_attribute?(k)
      attributes.keys.include?(mash_key(k))
    end

    private

    # Since Rails diff is being deprecated
    # this is a simple hack that DOES NOT do nested hashes
    # and expects m1 and m2 to have EXACTLY the same stringified keys
    #
    # returns a hash with an array of differences
    # {
    #   a: ['before', 'after'],
    #   b: [nil, 'now']
    # }

    def dirty_diff(h1, h2)
      h1.stringify_keys.inject({}) do |h, (k, v1)|
        v2 = h2[k]
        h[k] = [v1, v2] if v1 != v2
        
        h  
      end
    end

    # a method that converts integer vals or Strings to proper 
    # slugified keys
    def mash_key(idx)
      if idx.is_a?(Fixnum)
        return keys[idx]
      else
        return idx.to_s.slugify
      end
    end

    def mash_index(key)
      if key.is_a?(Fixnum)
        return key
      else
        return keys.index(key.to_s)
      end
    end

  end
end