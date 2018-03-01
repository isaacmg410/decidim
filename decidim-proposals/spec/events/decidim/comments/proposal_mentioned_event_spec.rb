# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::ProposalMentionedEvent do
  include_context "simple event"

  let(:event_name) { "decidim.events.comments.proposal_mentioned" }
  let(:organization) { create :organization }
  let(:author) { create :user, organization: organization }

  let(:source_proposal) { create :proposal, feature: create(:proposal_feature, organization: organization) }
  let(:mentioned_proposal) { create :proposal, feature: create(:proposal_feature, organization: organization) }
  let(:resource) { source_proposal }
  let(:extra) do
    {
      mentioned_proposal_id: mentioned_proposal.id
    }
  end

  it_behaves_like "a simple event"

  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("Your proposal \"#{mentioned_proposal.title}\" has been mentioned")
    end
  end

  context "with content" do
    let(:content) do
      "Your proposal \"#{mentioned_proposal.title}\" has been mentioned in the comments of" \
        " proposal \"<a href=\"#{resource_locator(source_proposal).path}\">#{source_proposal.title}</a>\""
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro).to eq(content)
      end
    end

    describe "notification_title" do
      it "is generated correctly" do
        expect(subject.notification_title).to include(content)
      end
    end
  end
end
