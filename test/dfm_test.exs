defmodule DfmTest do
  use ExUnit.Case
  doctest DFM

  alias DFM.{Matrix}

  @test_file_path Path.join(:code.priv_dir(:dfm), "IncidentExampleTest.csv")

  test "DFM is built" do
    assert is_struct(DFM.build_dfm!(@test_file_path, print: false), Matrix)
  end

  test "DFM is built correctly" do
    matrix = DFM.build_dfm!(@test_file_path, print: false)
    test_matrix = test_matrix()
    assert Map.equal?(matrix.direct_followers, test_matrix.direct_followers)
    assert MapSet.equal?(matrix.activities, test_matrix.activities)
  end

  test "Get count of activity M followed by activity N" do
    matrix = DFM.build_dfm!(@test_file_path, print: false)
    assert Matrix.get_count(matrix, "Incident classification", "Initial diagnosis") == 6

  end

  test "Get missing values" do
    matrix = DFM.build_dfm!(@test_file_path, print: false)
    assert Matrix.get_count(matrix, "Incident closure", "Incident logging") == 0

    assert Matrix.get_count(matrix, "Incident closure", "Not existing activity") ==
             {:error, :no_such_activity}
  end

  test "Add null values" do
    matrix = DFM.build_dfm!(@test_file_path, add_null_values: true, print: false)
    assert Enum.count(matrix.direct_followers) == :math.pow(MapSet.size(matrix.activities), 2)
    assert Matrix.get_count(matrix, "Incident closure", "Incident logging") == 0
  end

  test "Time filter" do
    {:ok, from} = NaiveDateTime.new(2016, 1, 4, 12, 30, 0)
    {:ok, to} = NaiveDateTime.new(2016, 1, 5, 0, 0, 0)

    matrix = DFM.build_dfm!(@test_file_path, from: from, to: to, print: false)

    test_matrix = test_matrix_time_filter()

    assert Map.equal?(matrix.direct_followers, test_matrix.direct_followers)
    assert MapSet.equal?(matrix.activities, test_matrix.activities)
  end

  test "DFM is built in parallel" do
    assert is_struct(DFM.build_dfm!(@test_file_path, parallel: true, print: false), Matrix)
  end

  test "DFM is built in parallel correctly" do
    matrix = DFM.build_dfm!(@test_file_path, parallel: true, print: false)
    matrix_parallel = DFM.build_dfm!(@test_file_path, parallel: false, print: false)
    assert Map.equal?(matrix.direct_followers, matrix_parallel.direct_followers)
    assert MapSet.equal?(matrix.activities, matrix_parallel.activities)
  end

  #  Matrix which is supposed to be generated based on priv/IncidentExampleTest.csv
  defp test_matrix() do
    %Matrix{
      activities:
        MapSet.new([
          "Functional escalation",
          "Incident classification",
          "Incident closure",
          "Incident logging",
          "Initial diagnosis",
          "Investigation and diagnosis",
          "Resolution and recovery"
        ]),
      direct_followers: %{
        {"Functional escalation", "Investigation and diagnosis"} => 3,
        {"Incident classification", "Initial diagnosis"} => 6,
        {"Incident logging", "Incident classification"} => 6,
        {"Initial diagnosis", "Functional escalation"} => 3,
        {"Initial diagnosis", "Resolution and recovery"} => 4,
        {"Investigation and diagnosis", "Initial diagnosis"} => 1,
        {"Investigation and diagnosis", "Resolution and recovery"} => 2,
        {"Resolution and recovery", "Incident closure"} => 6
      }
    }
  end

  # Matrix which is supposed to be generated based on priv/IncidentExampleTest.csv
  # with a time filter defined in Time Filter test case.
  defp test_matrix_time_filter do
    %DFM.Matrix{
      activities:
        MapSet.new([
          "Incident classification",
          "Incident closure",
          "Incident logging",
          "Initial diagnosis",
          "Resolution and recovery"
        ]),
      direct_followers: %{
        {"Incident classification", "Initial diagnosis"} => 2,
        {"Incident logging", "Incident classification"} => 2,
        {"Initial diagnosis", "Resolution and recovery"} => 2,
        {"Resolution and recovery", "Incident closure"} => 2
      }
    }
  end
end
