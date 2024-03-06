defmodule TheAdventuringDay.Component.RandomTableParsing.DomainService.RandomTableParser do
  @moduledoc """
  TODO
  """

  alias TheAdventuringDay.Component.RandomTable.Domain.RandomTableCollection

  @doc """
  Creates a random table collection from the contents of a file. The file must be formatted into table blocks
  ```
  d2 A beggar's request
  1. A new pet to replace the one they lost.
  2. A million gold pieces!
  
  d2 Random loot
  1. A jar of dirt.
  2. An army of orcs, oops!
  ```
  A table is composed of two parts:
  
  - A header with a die size and description (will be converted to the table_name)
  - A number of results equal to the header's dX value. These may reference other tables in this file by using ##, e.g. #patron_or_target#
  """
  def parse(collection_name) do
    with {:ok, file_path} <- file_path("#{collection_name}.txt"),
         {:ok, table_collection} <- parse_collection(file_path) do
      RandomTableCollection.new(table_collection, collection_name)
    end
  end

  defp file_path(filename) do
    file_path =
      "."
      |> Path.expand()
      |> Path.join("data/unstructured_random_tables/#{filename}")

    if File.exists?(file_path) do
      {:ok, file_path}
    else
      {:error, :file_not_found}
    end
  end

  defp parse_collection(file_path) do
    table_contents =
      file_path
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Stream.chunk_while(
        [],
        fn
          "", acc -> {:cont, Enum.reverse(acc), []}
          line, acc -> {:cont, [line | acc]}
        end,
        fn
          [] -> {:cont, []}
          acc -> {:cont, Enum.reverse(acc), []}
        end
      )
      |> Enum.map(fn [header | entries] ->
        with {:ok, table_range, table_name} <- read_header(header),
             {:ok, entries} <- read_table_entries(entries) do
          %{
            table_name: table_name,
            table_range: table_range,
            entries: entries
          }
        end
      end)

    case validate_table(table_contents) do
      :ok ->
        {:ok, table_contents |> Map.new(fn %{table_name: table_name, entries: entries} -> {table_name, entries} end)}

      errors ->
        errors
    end
  end

  defp read_header(header_line) do
    header_match =
      ~r/d(\d+|%) (.+)/i
      |> Regex.scan(header_line)
      |> List.flatten()

    case header_match do
      [_all_match, "%", table_header] -> {:ok, 100, to_table_name(table_header)}
      [_all_match, range_match, table_header] -> {:ok, String.to_integer(range_match), to_table_name(table_header)}
      [] -> {:error, :no_header_match}
    end
  end

  defp to_table_name(table_header) do
    table_header
    |> String.trim()
    |> String.downcase()
    |> String.replace(" ", "_")
  end

  defp read_table_entries(entries) do
    parsed_entries =
      entries
      |> Enum.map(&to_single_result_entries/1)

    failed_entries =
      parsed_entries
      |> Enum.filter(fn {status, _} -> status == :error end)

    if Enum.empty?(failed_entries) do
      {:ok, parsed_entries |> Enum.map(fn {_, entry} -> entry end) |> Enum.concat()}
    else
      {:error, :could_not_parse_entries}
    end
  end

  defp to_single_result_entries(line) do
    entry_regexes = [
      # Match range results, i.e. 01-05 <result>
      ~r/(\d+)-(\d+) (.+)/i,
      # Match single result, i.e. 01 <result>
      ~r/\d+ (.+)/i
    ]

    matching_regex =
      entry_regexes
      |> Enum.find(fn regex -> String.match?(line, regex) end)

    if matching_regex != nil do
      matching_regex
      |> Regex.scan(line)
      |> List.flatten()
      |> to_entry_list()
    else
      {:error, :could_not_parse_entries}
    end
  end

  defp to_entry_list([match, range_begin, "00", entry]), do: to_entry_list([match, range_begin, "100", entry])

  defp to_entry_list([_, range_begin, range_end, entry]) do
    range_begin = String.to_integer(range_begin)
    range_end = String.to_integer(range_end)
    table_entry = to_table_entry(entry)

    {:ok, for(_ <- range_begin..range_end, do: table_entry)}
  end

  defp to_entry_list([_, entry]), do: {:ok, [to_table_entry(entry)]}

  defp to_entry_list([]), do: {:error, :could_not_parse_entry}

  defp to_table_entry(entry) do
    reference_regex = ~r/^#[^#]+#/i

    if String.match?(entry, reference_regex) do
      {:reference, String.trim(entry, "#")}
    else
      {:value, entry}
    end
  end

  # Double-check that, if a table is supposed to have 100 entries (d100), then it contains exactly 100 entries, and so on.
  defp validate_table(table_contents) do
    validation_errors =
      table_contents
      |> Enum.reduce([], fn %{table_range: table_range, entries: entries, table_name: table_name}, acc ->
        if table_range != length(entries) do
          [{:error, "#{table_name} should have #{table_range} entries, but was #{length(entries)}"} | acc]
        else
          acc
        end
      end)

    if length(validation_errors) == 0 do
      :ok
    else
      {:error, validation_errors}
    end
  end
end
