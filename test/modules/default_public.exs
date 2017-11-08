defmodule UnsafeTest.DefaultPublic do
  use Unsafe.Generator

  @unsafe_options [ handler: { UnsafeTest.DefaultPublic, :public_handler } ]
  @unsafe_binding [ test: 1 ]

  def test(true),
    do: { :ok, true }
  def test(false),
    do: { :error, false }

  def public_handler({ :ok, true }),
    do: true
  def public_handler({ :error, false }),
    do: raise RuntimeError
end
