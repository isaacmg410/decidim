# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Permissions do
  subject { described_class.allows?(user, action, context) }

  let(:user) { proposal.author }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: proposal_component,
      current_settings: current_settings,
      proposal: proposal,
      component_settings: component_settings
    }
  end
  let(:proposal_component) { create :proposal_component }
  let(:proposal) { create :proposal, component: proposal_component }
  let(:component_settings) do
    double(vote_limit: 2)
  end
  let(:current_settings) do
    double(settings.merge(extra_settings))
  end
  let(:settings) do
    {
      creation_enabled?: false,
    }
  end
  let(:extra_settings) { {} }

  before do
    allow(Decidim::ParticipatoryProcesses::Permissions)
      .to receive(:allows?)
      .and_return(space_allows)
  end

  context "when space does not allow the user to perform the action" do
    let(:space_allows) { false }
    let(:action) do
      { scope: "public", action: "foo", subject: "proposal" }
    end

    it { is_expected.to eq false }
  end

  context "when scope is not public" do
    let(:action) do
      { scope: "foo", action: "vote", subject: "proposal" }
    end

    it { is_expected.to eq false }
  end

  context "when subject is not a proposal" do
    let(:action) do
      { scope: "public", action: "vote", subject: "foo" }
    end

    it { is_expected.to eq false }
  end

  context "when creating a proposal" do
    let(:action) do
      { scope: "public", action: "create", subject: "proposal" }
    end

    context "when creation is disabled" do
      let(:extra_settings) { { creation_enabled?: false } }

      it { is_expected.to eq false }
    end

    context "when user is authorized" do
      let(:extra_settings) { { creation_enabled?: true } }

      it { is_expected.to eq true }
    end
  end

  context "when editing a proposal" do
    let(:action) do
      { scope: "public", action: "edit", subject: "proposal" }
    end

    before do
      allow(proposal).to receive(:editable_by?).with(user).and_return(editable)
    end

    context "when proposal is editable" do
      let(:editable) { true }

      it { is_expected.to eq true }
    end

    context "when proposal is not editable" do
      let(:editable) { false }

      it { is_expected.to eq false }
    end
  end

  context "when withdrawing a proposal" do
    let(:action) do
      { scope: "public", action: "withdraw", subject: "proposal" }
    end

    context "when proposal author is the user trying to withdraw" do
      it { is_expected.to eq true }
    end

    context "trying by another user" do
      let(:user) { build :user }

      it { is_expected.to eq false }
    end
  end

  describe "endorsing" do
    let(:action) do
      { scope: "public", action: "endorse", subject: "proposal" }
    end

    context "when endorsements are disabled" do
      let(:extra_settings) do
        {
          endorsements_enabled?: false,
          endorsements_blocked?: false
        }
      end

      it { is_expected.to eq false }
    end

    context "when endorsements are blocked" do
      let(:extra_settings) do
        {
          endorsements_enabled?: true,
          endorsements_blocked?: true
        }
      end

      it { is_expected.to eq false }
    end

    context "when user is authorized" do
      let(:extra_settings) do
        {
          endorsements_enabled?: true,
          endorsements_blocked?: false
        }
      end

      it { is_expected.to eq true }
    end
  end

  describe "endorsing" do
    let(:action) do
      { scope: "public", action: "unendorse", subject: "proposal" }
    end

    context "when endorsements are disabled" do
      let(:extra_settings) do
        {
          endorsements_enabled?: false
        }
      end

      it { is_expected.to eq false }
    end

    context "when user is authorized" do
      let(:extra_settings) do
        {
          endorsements_enabled?: true
        }
      end

      it { is_expected.to eq true }
    end
  end

  describe "voting" do
    let(:action) do
      { scope: "public", action: "vote", subject: "proposal" }
    end

    context "when voting is disabled" do
      let(:extra_settings) do
        {
          votes_enabled?: false,
          votes_blocked?: true
        }
      end

      it { is_expected.to eq false }
    end

    context "votes are blocked" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: true
        }
      end

      it { is_expected.to eq false }
    end

    context "user has no more remaining votes" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: false
        }
      end

      before do
        proposals = create_list :proposal, 2, component: proposal_component
        create :proposal_vote, author: user, proposal: proposals[0]
        create :proposal_vote, author: user, proposal: proposals[1]
      end

      it { is_expected.to eq false }
    end

    context "user is authorized" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: false
        }
      end

      it { is_expected.to eq true }
    end
  end
end
