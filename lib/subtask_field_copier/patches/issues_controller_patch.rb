#The MIT License (MIT)
#
#Copyright (c) 2026 rick barrette
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
module SubtaskFieldCopier
  module Patches
    module IssuesControllerPatch
      def build_new_issue_from_params
        # 1. Run the original Redmine method to initialize @issue
        super

        # 2. Only intervene for new subtasks explicitly created via the UI (GET request).
        # This prevents overwriting user-submitted data if form validation fails on a POST request.
        if request.get? && @issue.new_record? && @issue.parent_issue_id.present?
          parent_issue = Issue.find_by_id(@issue.parent_issue_id)

          if parent_issue
            # --- COPY CUSTOM FIELDS ---
            # Extract all custom field values from the parent and assign them to the new issue
            cf_values = {}
            parent_issue.custom_field_values.each do |cfv|
              cf_values[cfv.custom_field_id] = cfv.value
            end
            @issue.custom_field_values = cf_values

            # --- COPY CUSTOMER, VEHICLE & ESTIMATE---
            if @issue.respond_to?(:customer=) && parent_issue.respond_to?(:customer)
              @issue.customer = parent_issue.customer 
            end
            
            if @issue.respond_to?(:vehicle=) && parent_issue.respond_to?(:vehicle)
              @issue.vehicle = parent_issue.vehicle 
            end

            if @issue.respond_to?(:estimate=) && parent_issue.respond_to?(:estimate)
              @issue.estimate = parent_issue.estimate 
            end
          end
        end
      end
    end
  end
end