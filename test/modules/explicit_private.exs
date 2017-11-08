defmodule UnsafeTest.ExplicitPrivate do
  use Unsafe

  @unsafe [ { :test, 1, :private_handler } ]

  def test(true),
    do: { :ok, true }
  def test(false),
    do: { :error, false }

  defp private_handler({ :ok, true }),
    do: true
  defp private_handler({ :error, false }),
    do: raise RuntimeError
end
