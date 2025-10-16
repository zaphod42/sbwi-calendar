# frozen_string_literal: true

require 'test_helper'

require 'aura_events'
require 'local_gateway'
require 'uri'
require 'json'
require 'date'

def request_for_page(page_number)
  { "actions": [
    { "id": "7;a",
      "descriptor": "aura://ApexActionController/ACTION$execute",
      "callingDescriptor": "UNKNOWN",
      "params": { "namespace": "",
                  "classname": "CourseController",
                  "method": "getCourses",
                  "params": { "filters": {},
                              "pageNumber": page_number,
                              "pageSize": 10,
                              "sortBy": "startDate_asc" },
                  "cacheable": true,
                  "isContinuation": false } }
  ] }
end

TEST_FWUID = "testid"

AURA_CONTEXT = {
  "mode": "PROD",
  "fwuid": TEST_FWUID,
  "app": "c:CoursesListOutApp",
  "loaded": { "APPLICATION@markup://c:CoursesListOutApp": "1033_Ua7oGhPEnH24bNU8gbIIMQ" },
  "dn": [],
  "globals": {},
  "uad": true
}

TEST_PAGEURI = "/learn-woodworking"

A_COURSE = {
  "description": "This is our standard Woodshop Safety course open to women & non-binary students. Learn how to safely and properly use the most common power tools and make your own tool caddy! Using woodworking machines without proper training can be dangerous. This course will teach you to use tools safely so you can focus on enjoying your time in the shop.",
  "endDate": "2025-10-11T21:00:00.000Z",
  "id": "0P0Hu000000TbyxKAC",
  "imageUrl": "https://sambeaufordwoodworkingins.file.force.com/sfc/dist/version/download/?oid=00DHu00000PyvkR&ids=068Hu00000iSgkL&d=%2Fa%2FHu000000N9SM%2F7hRpaG56YpH0phdYa7TfjOqcBGteEAUtq0__8kZMk74&asPdf=false",
  "isFreeForMembers": false,
  "isFull": false,
  "isOneDay": true,
  "name": "Woodshop Safety for Women",
  "startDate": "2025-10-11T13:00:00.000Z",
  "startDay": "11",
  "startMonth": "OCT",
  "tags": "Weekend, Carolyn Racine",
  "tuition": 225
}

def response_with_courses(courses)
  {
    "actions": [
      {
        "id": "7;a",
        "state": "SUCCESS",
        "returnValue": {
          "returnValue": {
            "courses": courses,
            "totalCount": 1
          },
          "cacheable": true
        },
        "error": [],
        "storable": true
      }
    ]
  }
end

class TestAuraEventsTest < Minitest::Test
  def test_constructs_event_with_data_from_response
    gateway = LocalGateway.new({
                                 "POST::#{URI.encode_www_form(payload_to_request_page(1)) }" => response_with_courses([A_COURSE]).to_json,
                                 "POST::#{URI.encode_www_form(payload_to_request_page(2)) }" => response_with_courses([]).to_json
    })
    aura = AuraEvents.new(gateway, fwuid: TEST_FWUID, pageURI: TEST_PAGEURI, courseBaseUri: "https://ce.sbwi.edu/s/courseoffering/")

    first_event = aura.events.to_a.first
    assert_equal URI.parse("https://ce.sbwi.edu/s/courseoffering/#{A_COURSE[:id]}"), first_event.url
    assert_equal A_COURSE[:name], first_event.title
    assert_equal A_COURSE[:description], first_event.description
    assert_equal DateTime.iso8601(A_COURSE[:startDate]), first_event.start_datetime
    assert_equal DateTime.iso8601(A_COURSE[:endDate]), first_event.end_datetime
  end

  def test_fetches_events_across_pages
    gateway = LocalGateway.new({
                                 "POST::#{URI.encode_www_form(payload_to_request_page(1)) }" => response_with_courses([A_COURSE]).to_json,
                                 "POST::#{URI.encode_www_form(payload_to_request_page(2)) }" => response_with_courses([A_COURSE]).to_json,
                                 "POST::#{URI.encode_www_form(payload_to_request_page(3)) }" => response_with_courses([]).to_json
    })
    aura = AuraEvents.new(gateway, fwuid: TEST_FWUID, pageURI: TEST_PAGEURI, courseBaseUri: "https://ce.sbwi.edu/s/courseoffering/")

    assert_equal 2, aura.events.to_a.length
  end

  private

  def payload_to_request_page(page_number)
    { "message" => request_for_page(page_number).to_json, "aura.context" => AURA_CONTEXT.to_json, "aura.pageURI" => TEST_PAGEURI, "aura.token" => "null" }
  end
end
