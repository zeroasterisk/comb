defmodule Comb.TablePermutations do
  require Comb.Naive

  @table_size 5

  # This is a macro helper
  to_vars = 
    fn enum ->
      for i <- enum, do: "a#{i}" |> String.to_atom |> Macro.var(__MODULE__)
    end

  for count <- 1..@table_size do
    for {perm, i} <- Enum.with_index(Comb.Naive.permutations(1..count)) do
      def do_permutations_table(unquote(count), unquote(i + 1), 
                            [unquote_splicing(to_vars.(1..count))], tail) do
        [unquote_splicing(to_vars.(perm)) | tail]
      end
    end
  end

  defp any_duplicates?(list) do
    list
    |> Enum.sort
    |> Enum.chunk(2, 1)
    |> Enum.any?(&(match?([x, x], &1)))
  end

  def permutations(enum) do
    list = Enum.reverse enum
    count = Enum.count(list)
    result = do_permutations(list, count, [])
    if list |> any_duplicates? do
      result = result |> Stream.uniq
    end
    result
  end

  defp do_permutations([], _, _), do: [[]]

  defp do_permutations(list, count, tail) when count <= @table_size do
    1..Comb.Math.factorial(count)
    |> Stream.map(fn i -> do_permutations_table(count, i, list, tail) end)
  end


  # For permutations larger than table size, approach like naive algorithm
  defp do_permutations(list, count, tail) do
    list
    |> Stream.flat_map(fn el ->
        do_permutations(list -- [el], count - 1, [el|tail])
      end)
  end

  def permutation_index(enum) do
    list = Enum.to_list enum
    analysis = Comb.ListAnalyzer.analyze list
    if Comb.ListAnalyzer.all_unique? do
      do_permutation_index_unique(list, analysis.count)
    else
      list
      |> Enum.sort
      |> permutations
      |> Enum.find_index(&(&1 == list))
    end
  end

  def do_permutation_index_unique(list, count) do
    _natural_number_order = # convert 'acb' -> [1, 3, 2]
      list
      |> Enum.with_index
      |> Enum.sort
      |> Enum.with_index
      |> Enum.map(fn {{_, i0}, i1} -> {i0, i1} end)
      |> Enum.sort
      |> Enum.map(&(elem(&1, 1)))
    _fact = Comb.Math.factorial(count - 1)
  end
end


