require 'atomic_reference'

# define additional methods and exception
class Atomic
  class ConcurrentUpdateError < ThreadError
  end
  
  # Pass the current value to the given block, replacing it
  # with the block's result. May retry if the value changes
  # during the block's execution.
  def update
    true until compare_and_set(old_value = get, new_value = yield(old_value))
    new_value
  end

  def try_update
    old_value = get
    new_value = yield old_value
    unless compare_and_set(old_value, new_value)
      if $VERBOSE
        raise ConcurrentUpdateError, "Update failed"
      else
        raise ConcurrentUpdateError, "Update failed", CONC_UP_ERR_BACKTRACE
      end
    end
    new_value
  end
end