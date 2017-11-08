defmodule UnsafeTest.MissingHandle do
  use Unsafe

  @unsafe [ { :test, 1 } ]

  def test(true),
    do: { :ok, true }
  def test(false),
    do: { :error, false }
end
