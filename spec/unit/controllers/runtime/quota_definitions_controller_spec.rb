require "spec_helper"

module VCAP::CloudController
  describe VCAP::CloudController::QuotaDefinitionsController do
    include_examples "reading a valid object", path: "/v2/quota_definitions", model: QuotaDefinition, basic_attributes: %w(name non_basic_services_allowed total_routes total_services memory_limit trial_db_allowed)
  end

  describe "permissions" do
    let(:quota_attributes) do
      {
        name: quota_name,
        non_basic_services_allowed: false,
        total_services: 1,
        total_routes: 10,
        memory_limit: 1024
      }
    end
    let(:existing_quota) { VCAP::CloudController::QuotaDefinition.make }

    context "when the user is a cf admin" do
      let(:headers) { admin_headers }
      let(:quota_name) { "quota 1" }

      it "does allow creation of a quota def" do
        post "/v2/quota_definitions", Yajl::Encoder.encode(quota_attributes), json_headers(headers)
        last_response.status.should == 201
      end

      it "does allow read of a quota def" do
        get "/v2/quota_definitions/#{existing_quota.guid}", {}, headers
        last_response.status.should == 200
      end

      it "does allow update of a quota def" do
        put "/v2/quota_definitions/#{existing_quota.guid}", Yajl::Encoder.encode({:total_services => 2}), json_headers(headers)
        last_response.status.should == 201
      end

      it "does allow deletion of a quota def" do
        delete "/v2/quota_definitions/#{existing_quota.guid}", {}, headers
        last_response.status.should == 204
      end
    end

    context "when the user is not a cf admin" do
      let(:headers) { headers_for(VCAP::CloudController::User.make(:admin => false)) }
      let(:quota_name) { "quota 2" }

      it "does not allow creation of a quota def" do
        post "/v2/quota_definitions", Yajl::Encoder.encode(quota_attributes), json_headers(headers)
        last_response.status.should == 403
      end

      it "does allow read of a quota def" do
        get "/v2/quota_definitions/#{existing_quota.guid}", {}, headers
        last_response.status.should == 200
      end

      it "does not allow update of a quota def" do
        put "/v2/quota_definitions/#{existing_quota.guid}", Yajl::Encoder.encode(quota_attributes), json_headers(headers)
        last_response.status.should == 403
      end

      it "does not allow deletion of a quota def" do
        delete "/v2/quota_definitions/#{existing_quota.guid}", {}, headers
        last_response.status.should == 403
      end
    end
  end
end
