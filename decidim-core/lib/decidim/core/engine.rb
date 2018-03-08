# frozen_string_literal: true

require "rails"
require "active_support/all"

require "pg"
require "redis"

require "devise"
require "devise-i18n"
require "devise_invitable"
require "jquery-rails"
require "sassc-rails"
require "foundation-rails"
require "foundation_rails_helper"
require "autoprefixer-rails"
require "active_link_to"
require "rectify"
require "carrierwave"
require "high_voltage"
require "rails-i18n"
require "date_validator"
require "sprockets/es6"
require "cancancan"
require "truncato"
require "file_validators"
require "omniauth"
require "omniauth-facebook"
require "omniauth-twitter"
require "omniauth-google-oauth2"
require "invisible_captcha"
require "premailer/rails"
require "geocoder"
require "paper_trail"
require "doorkeeper"
require "doorkeeper-i18n"

require "decidim/api"

module Decidim
  module Core
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim
      engine_name "decidim"

      initializer "decidim.action_controller" do |_app|
        ActiveSupport.on_load :action_controller do
          helper Decidim::LayoutHelper if respond_to?(:helper)
        end
      end

      initializer "decidim.middleware" do |app|
        app.config.middleware.use Decidim::CurrentOrganization
      end

      initializer "decidim.assets" do |app|
        app.config.assets.paths << File.expand_path("../../../app/assets/stylesheets", __dir__)
        app.config.assets.precompile += %w(decidim_core_manifest.js)

        Decidim.component_manifests.each do |component|
          app.config.assets.precompile += [component.icon]
        end

        app.config.assets.debug = true if Rails.env.test?
      end

      initializer "decidim.high_voltage" do |_app|
        HighVoltage.configure do |config|
          config.routes = false
        end
      end

      initializer "decidim.default_form_builder" do |_app|
        ActionView::Base.default_form_builder = Decidim::FormBuilder
      end

      initializer "decidim.exceptions_app" do |app|
        app.config.exceptions_app = Decidim::Core::Engine.routes
      end

      initializer "decidim.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities << "Decidim::Abilities::EveryoneAbility"
          config.abilities << "Decidim::Abilities::AdminAbility"
          config.abilities << "Decidim::Abilities::UserManagerAbility"
          config.abilities << "Decidim::Abilities::ParticipatoryProcessAdminAbility"
          config.abilities << "Decidim::Abilities::ParticipatoryProcessCollaboratorAbility"
          config.abilities << "Decidim::Abilities::ParticipatoryProcessModeratorAbility"
        end
      end

      initializer "decidim.locales" do |app|
        app.config.i18n.fallbacks = true
      end

      initializer "decidim.query_extensions" do
        Decidim::Api::QueryType.define do
          Decidim::QueryExtensions.define(self)
        end
      end

      initializer "decidim.i18n_exceptions" do
        ActionView::Base.raise_on_missing_translations = true unless Rails.env.production?
      end

      initializer "decidim.geocoding" do
        if Decidim.geocoder.present?
          Geocoder.configure(
            # geocoding service (see below for supported options):
            lookup: :here,
            # IP address geocoding service (see below for supported options):
            # :ip_lookup => :maxmind,
            # to use an API key:
            api_key: [Decidim.geocoder&.fetch(:here_app_id), Decidim.geocoder&.fetch(:here_app_code)]
            # geocoding service request timeout, in seconds (default 3):
            # :timeout => 5,
            # set default units to kilometers:
            # :units => :km,
            # caching (see below for details):
            # :cache => Redis.new,
            # :cache_prefix => "..."
          )
        end
      end

      initializer "decidim.stats" do
        Decidim.stats.register :users_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, start_at, end_at|
          StatsUsersCount.for(organization, start_at, end_at)
        end

        Decidim.stats.register :processes_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, start_at, end_at|
          processes = ParticipatoryProcesses::OrganizationPrioritizedParticipatoryProcesses.new(organization)
          processes = processes.where("created_at >= ?", start_at) if start_at.present?
          processes = processes.where("created_at <= ?", end_at) if end_at.present?
          processes.count
        end
      end

      initializer "decidim.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.home", scope: "decidim"),
                    decidim.root_path,
                    position: 1,
                    active: :exclusive

          menu.item I18n.t("menu.more_information", scope: "decidim"),
                    decidim.pages_path,
                    position: 3,
                    active: :inclusive
        end
      end

      initializer "decidim.user_menu" do
        Decidim.menu :user_menu do |menu|
          menu.item t("account", scope: "layouts.decidim.user_profile"),
                    decidim.account_path,
                    position: 1.0,
                    active: :exact

          menu.item t("notifications_settings", scope: "layouts.decidim.user_profile"),
                    decidim.notifications_settings_path,
                    position: 1.1

          if available_verification_workflows.any?
            menu.item t("authorizations", scope: "layouts.decidim.user_profile"),
                      decidim_verifications.authorizations_path,
                      position: 1.2
          end

          if user_groups.any?
            menu.item t("user_groups", scope: "layouts.decidim.user_profile"),
                      decidim.own_user_groups_path,
                      position: 1.3
          end

          menu.item t("delete_my_account", scope: "layouts.decidim.user_profile"),
                    decidim.delete_account_path,
                    position: 999,
                    active: :exact
        end
      end

      initializer "decidim.notifications" do
        Decidim::EventsManager.subscribe(/^decidim\.events\./) do |event_name, data|
          EmailNotificationGeneratorJob.perform_later(
            event_name,
            data[:event_class],
            data[:resource],
            data[:recipient_ids],
            data[:extra]
          )
          NotificationGeneratorJob.perform_later(
            event_name,
            data[:event_class],
            data[:resource],
            data[:recipient_ids],
            data[:extra]
          )
        end
      end

      initializer "decidim.content_processors" do |_app|
        Decidim.configure do |config|
          config.content_processors += [:user]
        end
      end

      initializer "paper_trail" do
        PaperTrail.config.track_associations = false
      end

      initializer "doorkeeper" do
        Doorkeeper.configure do
          # Change the ORM that doorkeeper will use (needs plugins)
          orm :active_record

          # This block will be called to check whether the resource owner is authenticated or not.
          resource_owner_authenticator do
            current_user || redirect_to(new_user_session_path)
          end

          # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
          # admin_authenticator do
          #   # Put your admin authentication logic here.
          #   # Example implementation:
          #   Admin.find_by_id(session[:admin_id]) || redirect_to(new_admin_session_url)
          # end

          # Authorization Code expiration time (default 10 minutes).
          # authorization_code_expires_in 10.minutes

          # Access token expiration time (default 2 hours).
          # If you want to disable expiration, set this to nil.
          # access_token_expires_in 2.hours

          # Assign a custom TTL for implicit grants.
          # custom_access_token_expires_in do |oauth_client|
          #   oauth_client.application.additional_settings.implicit_oauth_expiration
          # end

          # Use a custom class for generating the access token.
          # https://github.com/doorkeeper-gem/doorkeeper#custom-access-token-generator
          # access_token_generator '::Doorkeeper::JWT'

          # The controller Doorkeeper::ApplicationController inherits from.
          # Defaults to ActionController::Base.
          # https://github.com/doorkeeper-gem/doorkeeper#custom-base-controller
          base_controller "Decidim::ApplicationController"

          # Reuse access token for the same resource owner within an application (disabled by default)
          # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
          # reuse_access_token

          # Issue access tokens with refresh token (disabled by default)
          # use_refresh_token

          # Provide support for an owner to be assigned to each registered application (disabled by default)
          # Optional parameter confirmation: true (default false) if you want to enforce ownership of
          # a registered application
          # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
          enable_application_owner confirmation: false

          # Define access token scopes for your provider
          # For more information go to
          # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
          default_scopes :public
          optional_scopes []

          # Change the way client credentials are retrieved from the request object.
          # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
          # falls back to the `:client_id` and `:client_secret` params from the `params` object.
          # Check out https://github.com/doorkeeper-gem/doorkeeper/wiki/Changing-how-clients-are-authenticated
          # for more information on customization
          # client_credentials :from_basic, :from_params

          # Change the way access token is authenticated from the request object.
          # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
          # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
          # Check out https://github.com/doorkeeper-gem/doorkeeper/wiki/Changing-how-clients-are-authenticated
          # for more information on customization
          # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

          # Change the native redirect uri for client apps
          # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
          # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
          # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
          #
          native_redirect_uri "urn:ietf:wg:oauth:2.0:oob"

          # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
          # by default in non-development environments). OAuth2 delegates security in
          # communication to the HTTPS protocol so it is wise to keep this enabled.
          #
          # Callable objects such as proc, lambda, block or any object that responds to
          # #call can be used in order to allow conditional checks (to allow non-SSL
          # redirects to localhost for example).
          #
          # force_ssl_in_redirect_uri !Rails.env.development?
          #
          force_ssl_in_redirect_uri false

          # Specify what redirect URI's you want to block during creation. Any redirect
          # URI is whitelisted by default.
          #
          # You can use this option in order to forbid URI's with 'javascript' scheme
          # for example.
          #
          # forbid_redirect_uri { |uri| uri.scheme.to_s.downcase == 'javascript' }

          # Specify what grant flows are enabled in array of Strings. The valid
          # strings and the flows they enable are:
          #
          # "authorization_code" => Authorization Code Grant Flow
          # "implicit"           => Implicit Grant Flow
          # "password"           => Resource Owner Password Credentials Grant Flow
          # "client_credentials" => Client Credentials Grant Flow
          #
          # If not specified, Doorkeeper enables authorization_code and
          # client_credentials.
          #
          # implicit and password grant flows have risks that you should understand
          # before enabling:
          #   http://tools.ietf.org/html/rfc6819#section-4.4.2
          #   http://tools.ietf.org/html/rfc6819#section-4.4.3
          #
          # grant_flows %w[authorization_code client_credentials]

          # Hook into the strategies' request & response life-cycle in case your
          # application needs advanced customization or logging:
          #
          # before_successful_strategy_response do |request|
          #   puts "BEFORE HOOK FIRED! #{request}"
          # end
          #
          # after_successful_strategy_response do |request, response|
          #   puts "AFTER HOOK FIRED! #{request}, #{response}"
          # end

          # Under some circumstances you might want to have applications auto-approved,
          # so that the user skips the authorization step.
          # For example if dealing with a trusted application.
          # skip_authorization do |resource_owner, client|
          #   client.superapp? or resource_owner.admin?
          # end

          # WWW-Authenticate Realm (default "Doorkeeper").
          realm "Decidim"
        end
      end
    end
  end
end
