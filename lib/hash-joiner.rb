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
      promote_hash_data collection, key
    elsif collection.instance_of? ::Array
      promote_array_data collection, key
    end
  end

  # Recursively promotes data within a Hash. Used to implement promote_data.
  #
  # @param collection [Hash] collection in which to promote information
  # @param key [String] property to be promoted within +collection+
  # @return [Hash] +collection+ after promotion
  # @see promote_data
  def self.promote_hash_data(collection, key)
    if collection.member? key
      data_to_promote = collection[key]
      collection.delete key
      deep_merge collection, data_to_promote
    end
    collection.each_value {|i| promote_data i, key}
  end

  # Recursively promotes data within an Array. Used to implement promote_data.
  #
  # @param collection [Array] collection in which to promote information
  # @param key [String] property to be promoted within +collection+
  # @return [Array] +collection+ after promotion
  # @see promote_data
  def self.promote_array_data(collection, key)
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

  # Raised by +deep_merge+ if +lhs+ and +rhs+ are of different types.
  # @see deep_merge
  class MergeError < ::Exception
  end

  # The set of mergeable classes
  MERGEABLE_CLASSES = [::Hash, ::Array]

  # Asserts that +lhs+ and +rhs+ are of the same type and can be merged.
  #
  # @param lhs [Hash,Array] merged data sink (left-hand side)
  # @param rhs [Hash,Array] merged data source (right-hand side)
  # @raise [MergeError] if +lhs+ and +rhs+ are of the different types or are
  #   of a type that cannot be merged
  # @return [nil]
  # @see deep_merge
  def self.assert_objects_are_mergeable(lhs, rhs)
    if lhs.class != rhs.class
      raise MergeError.new("LHS (#{lhs.class}): #{lhs}\n" +
        "RHS (#{rhs.class}): #{rhs}")
    elsif !MERGEABLE_CLASSES.include? lhs.class
      raise MergeError.new "Class not mergeable: #{lhs.class}"
    end
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
    assert_objects_are_mergeable lhs, rhs

    if rhs.instance_of? ::Hash
      deep_merge_hashes lhs, rhs
    elsif rhs.instance_of? ::Array
      lhs.concat rhs
    end
    lhs
  end

  # Asserts that +rhs_value+ can be merged into +lhs_value+ for the property
  # identified by +key+.
  #
  # @param key [String] Hash property name
  # @param lhs_value [Object] the property value of the data sink Hash
  #   (left-hand side value)
  # @param rhs_value [Object] the property value of the data source Hash
  #   (right-hand side value)
  # @raise [MergeError] if +lhs_value+ exists and +rhs_value+ is of a
  #   different class
  # @return [nil]
  # @see deep_merge
  # @see deep_merge_hashes
  def self.assert_hash_properties_are_mergeable(key, lhs_value, rhs_value)
    lhs_class = lhs_value == false ? ::TrueClass : lhs_value.class
    rhs_class = rhs_value == false ? ::TrueClass : rhs_value.class

    unless lhs_value.nil? or lhs_class == rhs_class
      raise MergeError.new(
        "LHS[#{key}] value (#{lhs_class}): #{lhs_value}\n" +
        "RHS[#{key}] value (#{rhs_class}): #{rhs_value}")
    end
    nil
  end

  # Performs a deep merge of Hash structures. Used to implement +deep_merge+.
  #
  # @param lhs [Hash] merged data sink (left-hand side)
  # @param rhs [Hash] merged data source (right-hand side)
  # @return [Hash] +lhs+
  # @raise [MergeError] if any value of +rhs+ cannot be merged into +lhs+
  # @see deep_merge
  def self.deep_merge_hashes(lhs, rhs)
    rhs.each do |key,rhs_value|
      lhs_value = lhs[key]
      assert_hash_properties_are_mergeable key, lhs_value, rhs_value

      if MERGEABLE_CLASSES.include? lhs_value.class
        deep_merge lhs_value, rhs_value
      else
        lhs[key] = rhs_value
      end
    end
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
  # @param h [Hash] object to verify
  # @param key [String] name of the property to verify
  # @param error_prefix [String] prefix for error message
  # @raise [JoinError] if +h+ is not a +Hash+, or if +key_field+ is absent
  #   from any element of +lhs+ or +rhs+.
  # @return [nil]
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

  # Given a collection, initialize any missing properties to empty values.
  # @param collection [Hash<String>,Array<Hash<String>>] collection to update
  # @param array_properties [Array<String>] list of properties to initialize
  #   with an empty Array
  # @param hash_properties [Array<String>] list of properties to initialize
  #   with an empty Hash
  # @param string_properties [Array<String>] list of properties to initialize
  #   with an empty String
  # @return collection
  def self.assign_empty_defaults(collection, array_properties, hash_properties,
    string_properties)
    if collection.instance_of? ::Hash
      array_properties.each {|i| collection[i] ||= Array.new}
      hash_properties.each {|i| collection[i] ||= Hash.new}
      string_properties.each {|i| collection[i] ||= String.new}
    elsif collection.instance_of? ::Array
      collection.each do |i|
        assign_empty_defaults(i,
          array_properties, hash_properties, string_properties)
      end
    end
    collection
  end

  # Recursively prunes all empty properties from every element of a
  # collection.
  # @param collection [Hash<String>,Array<Hash<String>>] collection to update
  def self.prune_empty_properties(collection)
    prune_empty_properties_helper(collection, {})
  end

  # Helper of prune_empty_properties that passes a object memoization table to
  # recursive calls. The table prevents infinite recursion when objects
  # contain cross-references to one another.
  # @param collection [Hash<String>,Array<Hash<String>>] collection to update
  # @param collection [Hash<String>] memoization table
  # @return collection
  def self.prune_empty_properties_helper(collection, seen_before)
    return collection if seen_before[collection.object_id]
    seen_before[collection.object_id] = true
    if collection.instance_of? ::Hash
      collection.each_value {|i| prune_empty_properties_helper i, seen_before}
      collection.delete_if do |unused_key, value|
        (value.instance_of? ::Hash or value.instance_of? ::Array or
         value.instance_of? ::String) and value.empty?
      end
    elsif collection.instance_of? ::Array
      collection.each {|i| prune_empty_properties_helper i, seen_before}
      collection.delete_if {|i| i.empty?}
    end
    collection
  end
  private_class_method :prune_empty_properties_helper
end
