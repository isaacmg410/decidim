# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new participatory
      # assembly in the system.
      class UpdateAssembly < Rectify::Command
        # Public: Initializes the command.
        #
        # assembly - the Assembly to update
        # form - A form object with the params.
        def initialize(assembly, form)
          @assembly = assembly
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          update_assembly

          if @assembly.valid?
            broadcast(:ok, @assembly)
          else
            form.errors.add(:hero_image, @assembly.errors[:hero_image]) if @assembly.errors.include? :hero_image
            form.errors.add(:banner_image, @assembly.errors[:banner_image]) if @assembly.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :assembly

        def update_assembly
          @assembly.assign_attributes(attributes)
          save_assembly if @assembly.valid?
        end

        def save_assembly
          transaction do
            @assembly.save!
            Decidim.traceability.perform_action!(:update, @assembly, form.current_user) do
              @assembly
            end
          end
        end

        def attributes
          {
            title: form.title,
            subtitle: form.subtitle,
            slug: form.slug,
            hashtag: form.hashtag,
            hero_image: form.hero_image,
            remove_hero_image: form.remove_hero_image,
            banner_image: form.banner_image,
            remove_banner_image: form.remove_banner_image,
            promoted: form.promoted,
            description: form.description,
            short_description: form.short_description,
            scopes_enabled: form.scopes_enabled,
            scope: form.scope,
            area: form.area,
            developer_group: form.developer_group,
            local_area: form.local_area,
            target: form.target,
            participatory_scope: form.participatory_scope,
            participatory_structure: form.participatory_structure,
            meta_scope: form.meta_scope,
            show_statistics: form.show_statistics,
            purpose_of_action: form.purpose_of_action,
            assembly_type: form.assembly_type,
            assembly_type_other: form.assembly_type_other,
            creation_date: form.creation_date,
            created_by: form.created_by,
            created_by_other: form.created_by_other,
            duration: form.duration,
            included_at: form.included_at,
            closing_date: form.closing_date,
            closing_date_reason: form.closing_date_reason,
            internal_organisation: form.internal_organisation,
            is_open: form.is_open,
            is_public: form.is_public,
            is_transparent: form.is_transparent,
            special_features: form.special_features,
            twitter_handler: form.twitter_handler,
            facebook_handler: form.facebook_handler,
            instagram_handler: form.instagram_handler,
            youtube_handler: form.youtube_handler,
            github_handler: form.github_handler
          }
        end
      end
    end
  end
end
