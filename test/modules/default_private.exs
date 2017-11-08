defmodule UnsafeTest.DefaultPrivate do
  use Unsafe.Generator

  @unsafe_options [ handler: :private_handler ]
  @unsafe_binding [ test: 1 ]

  def test(true),
    do: { :ok, true }
  def test(false),
    do: { :error, false }

  defp private_handler({ :ok, true }),
    do: true
  defp private_handler({ :error, false }),
    do: raise RuntimeError
end
