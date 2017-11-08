defmodule UnsafeTest.MultiDefine do
  use Unsafe

  @unsafe { :test, 1, :private_handler }
  @unsafe { :test, 2, :private_handler }

  def test(bool, opts \\ [])
  def test(true, _opts),
    do: { :ok, true }
  def test(false, _opts),
    do: { :error, false }

  defp private_handler({ :ok, true }),
    do: true
  defp private_handler({ :error, false }),
    do: raise RuntimeError
end
