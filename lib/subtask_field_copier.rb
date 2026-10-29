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

  # Issue attributes other plugins ask to have copied to subtasks (e.g. :customer, :vehicle, :estimate)
  mattr_accessor :registered_fields
  self.registered_fields = []

  def self.setup
   unless IssuesController.ancestors.include?(SubtaskFieldCopier::Patches::IssuesControllerPatch)
      IssuesController.prepend SubtaskFieldCopier::Patches::IssuesControllerPatch
    end
  end

  # Fills a new subtask's untouched fields from its parent.
  #
  # A field is copied only when:
  # - the user can see it on the parent and edit it on the subtask (per-role field visibility), and
  # - the parent has a value, and
  # - the subtask's field wasn't submitted with the request (so values the user typed or a link
  #   passed in are never overwritten), and
  # - the subtask's field is still untouched: empty, or still at that field's default value.
  #
  # submitted: the issue params of the request (a Hash, possibly empty).
  def self.copy_from_parent(issue, parent, user, submitted = {})
    submitted = (submitted || {}).to_h.stringify_keys
    submitted_cf_ids = (submitted['custom_field_values'] || {}).to_h.keys.map(&:to_s)

    parent_values = parent.visible_custom_field_values(user).index_by(&:custom_field_id)
    copied = {}

    issue.editable_custom_field_values(user).each do |child_value|
      field = child_value.custom_field
      next if submitted_cf_ids.include?(field.id.to_s)

      parent_value = parent_values[field.id]&.value
      next if blank_value?(parent_value)
      next unless untouched?(child_value)

      copied[field.id.to_s] = parent_value
    end
    issue.custom_field_values = copied if copied.any?

    registered_fields.each do |field|
      field = field.to_s
      setter = "#{field}="
      next unless issue.respond_to?(setter) && parent.respond_to?(field)
      next if submitted.key?(field) || submitted.key?("#{field}_id")

      value = parent.public_send(field)
      next if blank_value?(value)
      next unless blank_value?(issue.public_send(field))

      issue.public_send(setter, value)
    end
  end

  def self.untouched?(custom_value)
    current = custom_value.value
    default = custom_value.custom_field.default_value
    blank_value?(current) || Array(current).map(&:to_s).sort == Array(default).map(&:to_s).sort
  end

  def self.blank_value?(value)
    value.respond_to?(:empty?) ? Array(value).reject { |v| v.to_s.strip.empty? }.empty? : value.nil?
  end
end
