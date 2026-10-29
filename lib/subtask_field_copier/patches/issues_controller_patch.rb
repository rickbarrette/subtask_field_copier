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

      private

      # Redmine builds the new issue here for the new-issue page, its form refreshes (e.g. changing the
      # tracker) and create. After Redmine builds it, fill a subtask's untouched fields from its parent.
      # Fields present in the request are left alone, so this never overrides what the user entered;
      # on a form refresh it fills fields that just appeared (e.g. from the newly chosen tracker).
      def build_new_issue_from_params
        super
        return if performed?
        return unless @issue&.new_record? && @issue.parent_issue_id.present?

        # Only a parent the user is allowed to see, so its values can't leak into the form
        parent = Issue.visible.find_by(id: @issue.parent_issue_id)
        return unless parent

        submitted = params[:issue].respond_to?(:to_unsafe_h) ? params[:issue].to_unsafe_h : {}
        SubtaskFieldCopier.copy_from_parent(@issue, parent, User.current, submitted)
      end
    end
  end
end
