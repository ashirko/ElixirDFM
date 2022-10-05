defmodule DFM.Trace do
  @moduledoc """
  A sequence of *events* in process mining.

  Correspond to one instance of a certain *process*, for example:

  - an insurance claim which is processed in multiple steps at an insurance company
  - customer support ticket processing
  - conveyor belt manufacturing.

  Each event is represented as `DFM.Event` struct.
  """
  alias DFM.Event

  defstruct [:id, :events]

  @type t() :: %__MODULE__{
          id: any(),
          events: [Event.t()]
        }

  @doc """
  Creates a new DFM.Trace struct.
  """
  @spec new(any(), [Event.t()]) :: __MODULE__.t()
  def new(id, events \\ []) do
    %__MODULE__{
      id: id,
      events: events
    }
  end

  @doc """
  Adds an event to the Trace structure. Afterwards the list of events can be
  optionally sorted.
  """
  @spec add_event(__MODULE__.t(), Event.t(), Keyword.t()) :: __MODULE__.t()
  def add_event(trace, event, opts \\ []) do
    trace = %__MODULE__{trace | events: [event | trace.events]}

    if Keyword.get(opts, :sort, false) do
      sort_events(trace)
    else
      trace
    end
  end

  @doc """
  Sorts events in the Trace structure by the start field.
  """
  @spec sort_events(__MODULE__.t()) :: __MODULE__.t()
  def sort_events(trace) do
    sorted_events =
      Enum.sort(trace.events, fn event1, event2 ->
        Event.follower?(event1, event2)
      end)

    %__MODULE__{trace | events: sorted_events}
  end

  @doc """
  Returns true if the trace is within the specified time range. Returns false otherwise.
  """
  @spec in_time_range?(__MODULE__.t(), Keyword.t()) :: boolean()
  def in_time_range?(_trace, []), do: true

  def in_time_range?(trace, opts) do
    events = trace.events

    Event.started_after?(List.first(events), Keyword.get(opts, :from)) and
      Event.finished_before?(List.last(events), Keyword.get(opts, :to))
  end
end
