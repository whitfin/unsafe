defmodule UnsafeTest.DefaultInvalid do
  use Unsafe.Generator,
    handler: "invalid"

  @unsafe [ { :test, 1 } ]

  def test(true),
    do: { :ok, true }
  def test(false),
    do: { :error, false }
end
