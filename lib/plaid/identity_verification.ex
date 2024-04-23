defmodule Plaid.IdentityVerification do
  @moduledoc """
  Functions for managing identity verification data.
  """
  alias Plaid.Client.Request
  alias Plaid.Client

  @derive Jason.Encoder
  defstruct [
    :id,
    :client_user_id,
    :created_at,
    :completed_at,
    :previous_attempt_id,
    :shareable_url,
    :template,
    :user,
    :status,
    :steps,
    :documentary_verification,
    :selfie_check,
    :kyc_check,
    :risk_check,
    :watchlist_screening_id,
    :redacted_at,
    :request_id
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          client_user_id: String.t(),
          created_at: String.t(),
          completed_at: String.t(),
          previous_attempt_id: String.t(),
          shareable_url: String.t(),
          template: Template.t(),
          user: User.t(),
          status: String.t(),
          steps: Steps.t(),
          documentary_verification: DocumentaryVerification.t(),
          selfie_check: SelfieCheck.t(),
          kyc_check: KYCCheck.t(),
          risk_check: RiskCheck.t(),
          watchlist_screening_id: String.t(),
          redacted_at: String.t(),
          request_id: String.t()
        }

  @type params :: %{required(atom) => term}
  @type config :: %{required(atom) => String.t() | keyword}
  @type error :: {:error, Plaid.Error.t() | any()} | no_return

  defmodule Template do
    @moduledoc """
    Represents a template within a verification process.
    """

    @derive Jason.Encoder
    defstruct [:id, :version]

    @type t :: %__MODULE__{
            id: String.t(),
            version: integer()
          }
  end

  defmodule User do
    @moduledoc """
    Represents user-related data in the verification process.
    """

    @derive Jason.Encoder
    defstruct [
      :phone_number,
      :date_of_birth,
      :ip_address,
      :email_address,
      :name,
      :address,
      :id_number
    ]

    @type t :: %__MODULE__{
            phone_number: String.t(),
            date_of_birth: String.t(),
            ip_address: String.t(),
            email_address: String.t(),
            name: Name.t(),
            address: Address.t(),
            id_number: IDNumber.t()
          }

    defmodule Name do
      @derive Jason.Encoder
      defstruct [:given_name, :family_name]

      @type t :: %__MODULE__{
              given_name: String.t(),
              family_name: String.t()
            }
    end

    defmodule Address do
      @derive Jason.Encoder
      defstruct [:street, :street2, :city, :region, :postal_code, :country]

      @type t :: %__MODULE__{
              street: String.t(),
              street2: String.t(),
              city: String.t(),
              region: String.t(),
              postal_code: String.t(),
              country: String.t()
            }
    end

    defmodule IDNumber do
      @derive Jason.Encoder
      defstruct [:value, :type]

      @type t :: %__MODULE__{
              value: String.t(),
              type: String.t()
            }
    end
  end

  defmodule Steps do
    @moduledoc """
    Represents the verification steps and their statuses.
    """

    @derive Jason.Encoder
    defstruct [
      :accept_tos,
      :verify_sms,
      :kyc_check,
      :documentary_verification,
      :selfie_check,
      :watchlist_screening,
      :risk_check
    ]

    @type t :: %__MODULE__{
            accept_tos: String.t(),
            verify_sms: String.t(),
            kyc_check: String.t(),
            documentary_verification: String.t(),
            selfie_check: String.t(),
            watchlist_screening: String.t(),
            risk_check: String.t()
          }
  end

  defmodule DocumentaryVerification do
    @moduledoc """
    Represents documentary verification details including status and documents.
    """

    @derive Jason.Encoder
    defstruct [
      :status,
      :documents
    ]

    @type t :: %__MODULE__{
            status: String.t(),
            documents: [Document.t()]
          }

    defmodule Document do
      @derive Jason.Encoder
      defstruct [
        :status,
        :attempt,
        :images,
        :extracted_data,
        :analysis,
        :redacted_at
      ]

      @type t :: %__MODULE__{
              status: String.t(),
              attempt: integer(),
              images: Images.t(),
              extracted_data: ExtractedData.t(),
              analysis: Analysis.t(),
              redacted_at: String.t()
            }
    end

    defmodule Images do
      @derive Jason.Encoder
      defstruct [
        :original_front,
        :original_back,
        :cropped_front,
        :cropped_back,
        :face
      ]

      @type t :: %__MODULE__{
              original_front: String.t(),
              original_back: String.t(),
              cropped_front: String.t(),
              cropped_back: String.t(),
              face: String.t()
            }
    end

    defmodule ExtractedData do
      @derive Jason.Encoder
      defstruct [
        :id_number,
        :category,
        :expiration_date,
        :issuing_country,
        :issuing_region,
        :date_of_birth,
        :address
      ]

      @type t :: %__MODULE__{
              id_number: String.t(),
              category: String.t(),
              expiration_date: String.t(),
              issuing_country: String.t(),
              issuing_region: String.t(),
              date_of_birth: String.t(),
              address: Address.t()
            }
    end

    defmodule Analysis do
      @derive Jason.Encoder
      defstruct [
        :authenticity,
        :image_quality,
        :extracted_data
      ]

      @type t :: %__MODULE__{
              authenticity: String.t(),
              image_quality: String.t(),
              extracted_data: ExtractedData.t()
            }
    end
  end

  defmodule SelfieCheck do
    @moduledoc """
    Represents selfie verification details including status and analysis.
    """

    @derive Jason.Encoder
    defstruct [
      :status,
      :selfies
    ]

    @type t :: %__MODULE__{
            status: String.t(),
            selfies: [Selfie.t()]
          }

    defmodule Selfie do
      @derive Jason.Encoder
      defstruct [
        :status,
        :attempt,
        :capture,
        :analysis
      ]

      @type t :: %__MODULE__{
              status: String.t(),
              attempt: integer(),
              capture: Capture.t(),
              analysis: Analysis.t()
            }
    end

    defmodule Capture do
      @derive Jason.Encoder
      defstruct [:image_url, :video_url]

      @type t :: %__MODULE__{
              image_url: String.t(),
              video_url: String.t()
            }
    end

    defmodule Analysis do
      @derive Jason.Encoder
      defstruct [:document_comparison]

      @type t :: %__MODULE__{
              document_comparison: String.t()
            }
    end
  end

  defmodule KYCCheck do
    @moduledoc """
    Represents the KYC (Know Your Customer) check details.
    """

    @derive Jason.Encoder
    defstruct [
      :status,
      :address,
      :name,
      :date_of_birth,
      :id_number,
      :phone_number
    ]

    @type t :: %__MODULE__{
            status: String.t(),
            address: KYCAddress.t(),
            name: KYCName.t(),
            date_of_birth: KYCDOB.t(),
            id_number: KYCIDNumber.t(),
            phone_number: KYCPhoneNumber.t()
          }

    defmodule KYCAddress do
      @derive Jason.Encoder
      defstruct [:summary, :po_box, :type]

      @type t :: %__MODULE__{
              summary: String.t(),
              po_box: String.t(),
              type: String.t()
            }
    end

    defmodule KYCName do
      @derive Jason.Encoder
      defstruct [:summary]

      @type t :: %__MODULE__{
              summary: String.t()
            }
    end

    defmodule KYCDOB do
      @derive Jason.Encoder
      defstruct [:summary]

      @type t :: %__MODULE__{
              summary: String.t()
            }
    end

    defmodule KYCIDNumber do
      @derive Jason.Encoder
      defstruct [:summary]

      @type t :: %__MODULE__{
              summary: String.t()
            }
    end

    defmodule KYCPhoneNumber do
      @derive Jason.Encoder
      defstruct [:summary, :area_code]

      @type t :: %__MODULE__{
              summary: String.t(),
              area_code: String.t()
            }
    end
  end

  defmodule RiskCheck do
    @moduledoc """
    Represents the risk assessment details.
    """

    @derive Jason.Encoder
    defstruct [
      :status,
      :behavior,
      :email,
      :phone,
      :devices,
      :identity_abuse_signals
    ]

    @type t :: %__MODULE__{
            status: String.t(),
            behavior: Behavior.t(),
            email: Email.t(),
            phone: Phone.t(),
            devices: [Device.t()],
            identity_abuse_signals: IdentityAbuseSignals.t()
          }

    defmodule Behavior do
      @derive Jason.Encoder
      defstruct [:user_interactions, :fraud_ring_detected, :bot_detected]

      @type t :: %__MODULE__{
              user_interactions: String.t(),
              fraud_ring_detected: String.t(),
              bot_detected: String.t()
            }
    end

    defmodule Email do
      @derive Jason.Encoder
      defstruct [
        :is_deliverable,
        :breach_count,
        :first_breached_at,
        :last_breached_at,
        :domain_registered_at,
        :domain_is_free_provider,
        :domain_is_custom,
        :domain_is_disposable,
        :top_level_domain_is_suspicious,
        :linked_services
      ]

      @type t :: %__MODULE__{
              is_deliverable: String.t(),
              breach_count: integer(),
              first_breached_at: String.t(),
              last_breached_at: String.t(),
              domain_registered_at: String.t(),
              domain_is_free_provider: String.t(),
              domain_is_custom: String.t(),
              domain_is_disposable: String.t(),
              top_level_domain_is_suspicious: String.t(),
              linked_services: [String.t()]
            }
    end

    defmodule Phone do
      @derive Jason.Encoder
      defstruct [:linked_services]

      @type t :: %__MODULE__{
              linked_services: [String.t()]
            }
    end

    defmodule Device do
      @derive Jason.Encoder
      defstruct [:ip_proxy_type, :ip_spam_list_count, :ip_timezone_offset]

      @type t :: %__MODULE__{
              ip_proxy_type: String.t(),
              ip_spam_list_count: integer(),
              ip_timezone_offset: String.t()
            }
    end

    defmodule IdentityAbuseSignals do
      @derive Jason.Encoder
      defstruct [:synthetic_identity, :stolen_identity]

      @type t :: %__MODULE__{
              synthetic_identity: SyntheticIdentity.t(),
              stolen_identity: StolenIdentity.t()
            }

      defmodule SyntheticIdentity do
        @derive Jason.Encoder
        defstruct [:score]

        @type t :: %__MODULE__{
                score: integer()
              }
      end

      defmodule StolenIdentity do
        @derive Jason.Encoder
        defstruct [:score]

        @type t :: %__MODULE__{
                score: integer()
              }
      end
    end
  end

  @spec get(params, config) :: {:ok, Plaid.IdentityVerification.t()} | error
  def get(params, config \\ %{}) do
    c = config[:client] || Plaid

    Request
    |> struct(method: :post, endpoint: "identity_verification/get", body: params)
    |> Request.add_metadata(config)
    |> c.send_request(Client.new(config))
    |> c.handle_response(&map_identity_verification(&1))
  end

  defp map_identity_verification(body) do
    Poison.Decode.transform(
      body,
      %{
        as: %Plaid.IdentityVerification{
          template: %Template{},
          user: %User{},
          steps: %Steps{},
          documentary_verification: %DocumentaryVerification{},
          selfie_check: %SelfieCheck{},
          kyc_check: %KYCCheck{},
          risk_check: %RiskCheck{}
        }
      }
    )
  end
end
