defmodule UnsafeTest.DefaultInvalid do
  use Unsafe.Generator

  @unsafe_options [ handler: "invalid" ]
  @unsafe_binding [ { :test, 1 } ]

  def test(true),
    do: { :ok, true }
  def test(false),
    do: { :error, false }
end
