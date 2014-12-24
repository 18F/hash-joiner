# @author: Mike Bland (michael.bland@gsa.gov)
module HashJoiner
  # Recursively strips information from +collection+ matching +key+.
  #
  # @param collection [Hash,Array<Hash>] collection from which to strip
  #   information
  # @param key [String] property to be stripped from +collection+
  # @return [Hash,Array<Hash>] +collection+ if +collection+ is a +Hash+ or
  #   +Array<Hash>+
  # @return [nil] if +collection+ is not a +Hash+ or +Array<Hash>+
  def self.remove_data(collection, key)
    if collection.instance_of? ::Hash
      collection.delete key
      collection.each_value {|i| remove_data i, key}
    elsif collection.instance_of? ::Array
      collection.each {|i| remove_data i, key}
      collection.delete_if {|i| i.empty?}
    end
  end

  # Recursively promotes data within the +collection+ matching +key+ to the
  # same level as +key+ itself. After promotion, each +key+ reference will
  # be deleted.
  #
  # @param collection [Hash,Array<Hash>] collection in which to promote
  #   information
  # @param key [String] property to be promoted within +collection+
  # @return [Hash,Array<Hash>] +collection+ if +collection+ is a +Hash+ or
  #   +Array<Hash>+
  # @return [nil] if +collection+ is not a +Hash+ or +Array<Hash>+
  def self.promote_data(collection, key)
    if collection.instance_of? ::Hash
      if collection.member? key
        data_to_promote = collection[key]
        collection.delete key
        deep_merge collection, data_to_promote
      end
      collection.each_value {|i| promote_data i, key}

    elsif collection.instance_of? ::Array
      collection.each do |i|
        # If the Array entry is a hash that contains only the target key,
        # then that key should map to an Array to be promoted.
        if i.instance_of? ::Hash and i.keys == [key]
          data_to_promote = i[key]
          i.delete key
          deep_merge collection, data_to_promote
        else
          promote_data i, key
        end
      end

      collection.delete_if {|i| i.empty?}
    end
  end

  # Raised by +deep_merge+ if +lhs+ and +rhs+ are of different types.
  # @see deep_merge
  class MergeError < ::Exception
  end

  # Performs a deep merge of +Hash+ and +Array+ structures. If the collections
  # are +Hash+es, +Hash+ or +Array+ members of +rhs+ will be deep-merged with
  # any existing members in +lhs+. If the collections are +Array+s, the values
  # from +rhs+ will be appended to +lhs+.
  #
  # @param lhs [Hash,Array] merged data sink (left-hand side)
  # @param rhs [Hash,Array] merged data source (right-hand side)
  # @return [Hash,Array] +lhs+
  # @raise [MergeError] if +lhs+ and +rhs+ are of different classes, or if
  #   they are of classes other than Hash or Array.
  def self.deep_merge(lhs, rhs)
    mergeable_classes = [::Hash, ::Array]

    if lhs.class != rhs.class
      raise MergeError.new("LHS (#{lhs.class}): #{lhs}\n" +
        "RHS (#{rhs.class}): #{rhs}")
    elsif !mergeable_classes.include? lhs.class
      raise MergeError.new "Class not mergeable: #{lhs.class}"
    end

    if rhs.instance_of? ::Hash
      rhs.each do |key,rhs_value|
        lhs_value = lhs[key]
        lhs_class = lhs_value.class
        rhs_class = rhs_value.class

        unless lhs_value.nil? or lhs_class == rhs_class
          booleans = [::TrueClass, ::FalseClass]
          unless booleans.include? lhs_class and booleans.include? rhs_class
            raise MergeError.new(
              "LHS[#{key}] value (#{lhs_value.class}): #{lhs_value}\n" +
              "RHS[#{key}] value (#{rhs_value.class}): #{rhs_value}")
          end
        end

        if mergeable_classes.include? lhs_class
          deep_merge lhs_value, rhs_value
        else
          lhs[key] = rhs_value
        end
      end

    elsif rhs.instance_of? ::Array
      lhs.concat rhs
    end
    lhs
  end

  # Raised by +join_data+ if an error is encountered.
  # @see join_data
  class JoinError < ::Exception
  end

  # Joins objects in +lhs+[category] with data from +rhs+[category]. If the
  # +category+ objects are of type +Array<Hash>+, +key_field+ will be used as
  # the primary key to join the objects in the two collections; otherwise
  # +key_field+ is ignored.
  #
  # @param category [String] determines member of +lhs+ to join with +rhs+
  # @param key_field [String] primary key for objects in each +Array<Hash>+
  #   collection specified by +category+
  # @param lhs [Hash,Array<Hash>] joined data sink of type Hash (left-hand
  #   side)
  # @param rhs [Hash,Array<Hash>] joined data source of type Hash (right-hand
  #   side)
  # @return [Hash,Array<Hash>] +lhs+
  # @raise [JoinError] if an error is encountered
  # @see deep_merge
  # @see join_array_data
  def self.join_data(category, key_field, lhs, rhs)
    rhs_data = rhs[category]
    return lhs unless rhs_data

    lhs_data = lhs[category]
    if !(lhs_data and [::Hash, ::Array].include? lhs_data.class)
      lhs[category] = rhs_data
    elsif lhs_data.instance_of? ::Hash
      self.deep_merge lhs_data, rhs_data
    else
      self.join_array_data key_field, lhs_data, rhs_data
    end
    lhs
  end

  # Asserts that +h+ is a hash containing +key+. Used to ensure that a +Hash+
  # can be joined with another +Hash+ object.
  #
  # @raise [JoinError] if +h+ is not a +Hash+, or if +key_field+ is absent
  #   from any element of +lhs+ or +rhs+.
  # @return [NilClass] +nil+
  # @see join_data
  # @see join_array_data
  def self.assert_is_hash_with_key(h, key, error_prefix)
    if !h.instance_of? ::Hash
      raise JoinError.new("#{error_prefix} is not a Hash: #{h}")
    elsif !h.member? key
      raise JoinError.new("#{error_prefix} missing \"#{key}\": #{h}")
    end
  end

  # Joins data in +lhs+ with data from +rhs+ based on +key_field+. Both +lhs+
  # and +rhs+ should be of type +Array<Hash>+. Performs a +deep_merge+ on
  # matching objects; assigns values from +rhs+ to +lhs+ if no corresponding
  # value yet exists in +lhs+.
  #
  # @param key_field [String] primary key for joined objects
  # @param lhs [Array<Hash>] joined data sink (left-hand side)
  # @param rhs [Array<Hash>] joined data source (right-hand side)
  # @return [Array<Hash>] +lhs+
  # @raise [JoinError] if either +lhs+ or +rhs+ is not an +Array<Hash>+, or if
  #   +key_field+ is absent from any element of +lhs+ or +rhs+
  # @see deep_merge
  # @see join_data
  # @see assert_is_hash_with_key
  def self.join_array_data(key_field, lhs, rhs)
    unless lhs.instance_of? ::Array and rhs.instance_of? ::Array
      raise JoinError.new("Both lhs (#{lhs.class}) and " +
        "rhs (#{rhs.class}) must be an Array of Hash")
    end

    lhs_index = {}
    lhs.each do |i|
      self.assert_is_hash_with_key(i, key_field, "LHS element")
      lhs_index[i[key_field]] = i
    end

    # TODO(mbland): Make exception-safe by splitting into two loops: one for
    # the assert; one to modify lhs after all the assertions have succeeded.
    rhs.each do |i|
      self.assert_is_hash_with_key(i, key_field, "RHS element")
      key = i[key_field]
      if lhs_index.member? key
        deep_merge lhs_index[key], i
      else
        lhs << i
      end
    end
    lhs
  end
end
