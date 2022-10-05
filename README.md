# Direct Follower Matrix

This is a small library for building a Direct Follower Matrix (DFM) from a CSV file. The   traces can be imported  
from the CSV file sequentially, or in parallel using Flow library.  

##Getting started
There is a single API function which can accept multiple options. Here are some examples:
```elixir
# Build DFM from the example file 'priv/IncidentExample.csv':
DFM.build_dfm!()

# Filter the results based on dates: 
{:ok, from} = NaiveDateTime.new(2016, 1, 4, 12, 30, 0)
{:ok, to} = NaiveDateTime.new(2016, 1, 5, 0, 0, 0)
DFM.build_dfm!("priv/IncidentExample.csv", from: from, to: to)

# Get counts of activity M followed by activity N:
matrix = DFM.build_dfm!("priv/IncidentExample.csv")
DFM.Matrix.get_count(matrix, "Incident classification", "Initial diagnosis")

# Build DFM performing the importing of the traces from the CSV file concurrently:
DFM.build_dfm!("priv/IncidentExample.csv", parallel: true)
```

## Benchmark
Importing of the traces from CSV file concurrently significantly decreases execution time for large CSV files.  
The following results were obtained on a 4-core machine:

```elixir
# Sequentially (sec)
iex(8)> {time, res} = :timer.tc(fn -> DFM.build_dfm!("priv/IncidentExample.csv", parallel: false, print: false) end); time/1000000
3.313403
# Concurrently (sec)
iex(9)> {time, res} = :timer.tc(fn -> DFM.build_dfm!("priv/IncidentExample.csv", parallel: true, print: false) end); time/1000000 
1.030325
```  
Here are the results for the different sizes of the CSV files:

| File size (MB) | Sequential execution time (sec) | Concurrent execution time (sec) |
|----------------|---------------------------------|---------------------------------|
| 0.003          | 0.012                           | 0.013                          |
| 0.9            | 3.3                             | 1.0                             | 
| 62             | 226.8                           | 67.7                            |

