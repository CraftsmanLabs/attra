require "helpers/util"

module Sample
  # Branches: the tests only take the "negative even" and "positive" arms.
  def self.classify(n)
    if n < 0 && n.even?
      "negative even"
    elsif n < 0
      "negative odd"
    elsif n == 0
      "zero"
    else
      "positive"
    end
  end

  # Partial line: only the "small" side of the ternary runs.
  def self.size(n) = n > 100 ? "big" : "small"

  # One statement spread over several lines.
  def self.total(a,
                 b,
                 c)
    Helpers.add(a,
                Helpers.add(b, c))
  end

  # Never called.
  def self.never_called(n)
    n * 2
  end

  # Excluded by the user. The tests never call it.
  # :nocov:
  def self.excluded(n)
    n * 3
  end
  # :nocov:

  def self.kind(s)
    case s
    when "a" then 1
    when "b" then 2
    else 0
    end
  end
end
