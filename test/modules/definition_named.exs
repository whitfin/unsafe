defmodule UnsafeTest.DefinitionNamed do
  use Unsafe.Generator

  @unsafe { :test, [ :bool ], :private_handler }
  @unsafe { :test, [ :bool, :opts ], :private_handler }

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
