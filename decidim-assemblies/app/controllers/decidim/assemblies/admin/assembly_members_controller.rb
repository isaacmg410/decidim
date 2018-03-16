# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly members.
      #
      class AssemblyMembersController < Decidim::Assemblies::Admin::ApplicationController
        include Concerns::AssemblyAdmin

        def index
          authorize! :read, Decidim::AssemblyMember
          @assembly_members = collection
        end

        def new
          authorize! :create, Decidim::AssemblyMember
          @form = form(AssemblyMemberForm).instance
        end

        def create
          authorize! :create, Decidim::AssemblyMember
          @form = form(AssemblyMemberForm).from_params(params)

          CreateAssemblyMember.call(@form, current_user, current_assembly) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_members.create.success", scope: "decidim.admin")
              redirect_to assembly_members_path(current_assembly)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("assembly_members.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          @assembly_member = collection.find(params[:id])
          authorize! :update, @assembly_member
          @form = form(AssemblyMemberForm).from_model(@assembly_member)
        end

        def update
          @assembly_member = collection.find(params[:id])
          authorize! :update, @assembly_member
          @form = form(AssemblyMemberForm).from_params(params)

          UpdateAssemblyMember.call(@form, @assembly_member) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_members.update.success", scope: "decidim.admin")
              redirect_to assembly_members_path(current_assembly)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assembly_members.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          @assembly_member = collection.find(params[:id])
          authorize! :destroy, @assembly_member

          DestroyAssemblyMember.call(@assembly_member, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_members.destroy.success", scope: "decidim.admin")
              redirect_to assembly_members_path(current_assembly)
            end
          end
        end

        private

        def collection
          @collection ||= Decidim::AssemblyMember.where(assembly: current_assembly)
                          # .includes(:user)
                          # .where(assembly: current_assembly)
                          # .order("decidim_users.name")
        end
      end
    end
  end
end
