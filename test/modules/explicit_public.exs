defmodule UnsafeTest.ExplicitPublic do
  use Unsafe.Generator

  @unsafe [ { :test, 1, { UnsafeTest.ExplicitPublic, :public_handler } } ]

  def test(true),
    do: { :ok, true }
  def test(false),
    do: { :error, false }

  def public_handler({ :ok, true }),
    do: true
  def public_handler({ :error, false }),
    do: raise RuntimeError
end
