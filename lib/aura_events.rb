# frozen_string_literal: true

require_relative 'calendar'

require 'uri'
require 'date'
require 'json'

MAX_PAGE = 100

class AuraEvents
  def initialize(gateway,
                 fwuid: 'THl4S21tS3lfX1VPdk83d1ZYQXI4UUo4d1c2djVyVVc3NTc1a1lKNHV4S3cxMy4zMzU1NDQzMi4yNTE2NTgyNA',
                 pageURI: '/learn-woodworking',
                 courseBaseUri: "https://ce.sbwi.edu/s/courseoffering/")
    @gateway = gateway
    @fwuid = fwuid
    @pageURI = pageURI
    @courseBaseUri = courseBaseUri
  end

  def events
    current_page = 1
    Enumerator.new do |yielder|
      while current_page <= MAX_PAGE
        response = @gateway.post('', { 'message' => self.message(current_page).to_json, 'aura.context' => context.to_json, 'aura.pageURI' => @pageURI, 'aura.token' => 'null' })
        parsed_response = JSON.parse(response)
        courses = parsed_response['actions'].first['returnValue']['returnValue']['courses']
        break if courses.empty?
        construct_events(courses).each(&yielder)
        current_page += 1
      end
    end
  end

  private

  def message(page_number)
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

  def context
    {
      "mode": "PROD",
      "fwuid": @fwuid,
      "app": "c:CoursesListOutApp",
      "loaded": { "APPLICATION@markup://c:CoursesListOutApp": "1033_Ua7oGhPEnH24bNU8gbIIMQ" },
      "dn": [],
      "globals": {},
      "uad": true
    }
  end

  def construct_events(courses)
    courses.map do |course|
      Calendar::Event.new(url: URI.join(@courseBaseUri, course['id']),
                title: course['name'],
                description: course['description'],
                start_datetime: DateTime.parse(course['startDate']),
                end_datetime: DateTime.parse(course['endDate']))
    end
  end
end
