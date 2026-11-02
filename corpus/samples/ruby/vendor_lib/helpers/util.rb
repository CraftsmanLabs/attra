# A second source root.
module Helpers
  def self.add(a, b)
    a + b
  end

  def self.unused(n)
    add(n, 1)
  end
end
