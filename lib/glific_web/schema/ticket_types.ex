defmodule GlificWeb.Schema.TicketTypes do
  @moduledoc """
  GraphQL Representation of Ticket DataType
  """

  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]
  alias Glific.Repo
  alias GlificWeb.Resolvers
  alias GlificWeb.Schema.Middleware.Authorize

  object :ticket_result do
    field(:ticket, :ticket)
    field(:errors, list_of(:input_error))
  end

  object :ticket do
    field(:id, :id)
    field(:body, :string)
    field(:topic, :string)
    field(:status, :string)
    field(:remarks, :string)

    field :contact, :contact do
      resolve(dataloader(Repo, use_parent: true))
    end

    field :user, :user do
      resolve(dataloader(Repo, use_parent: true))
    end

    field(:inserted_at, :datetime)
    field(:updated_at, :datetime)
  end

  input_object :ticket_input do
    field(:body, :string)
    field(:topic, :string)
    field(:status, :string)
    field(:remarks, :string)
    field(:contact_id, :id)
    field(:user_id, :id)
  end

  @desc "Filtering options for tickets"
  input_object :ticket_filter do
    @desc "Match the status"
    field(:status, :string)

    @desc "Match the contact id"
    field(:contact_id, :id)

    @desc "Match the user id"
    field(:user_id, :id)
  end

  object :ticket_queries do
    @desc "get the details of one ticket"
    field :ticket, :ticket_result do
      arg(:id, non_null(:id))
      middleware(Authorize, :staff)
      resolve(&Resolvers.Tickets.ticket/3)
    end

    @desc "Get a list of all tickets"
    field :tickets, list_of(:ticket) do
      arg(:filter, :ticket_filter)
      arg(:opts, :opts)
      middleware(Authorize, :staff)
      resolve(&Resolvers.Tickets.tickets/3)
    end

    @desc "Get a count of all tickets filtered by various criteria"
    field :count_tickets, :integer do
      arg(:filter, :ticket_filter)
      middleware(Authorize, :staff)
      resolve(&Resolvers.Tickets.count_tickets/3)
    end
  end

  object :ticket_mutations do
    field :create_ticket, :ticket_result do
      arg(:input, non_null(:ticket_input))
      middleware(Authorize, :manager)
      resolve(&Resolvers.Tickets.create_ticket/3)
    end

    field :update_ticket, :ticket_result do
      arg(:id, non_null(:id))
      arg(:input, :ticket_input)
      middleware(Authorize, :manager)
      resolve(&Resolvers.Tickets.update_ticket/3)
    end

    field :delete_ticket, :ticket_result do
      arg(:id, non_null(:id))
      middleware(Authorize, :manager)
      resolve(&Resolvers.Tickets.delete_ticket/3)
    end
  end
end