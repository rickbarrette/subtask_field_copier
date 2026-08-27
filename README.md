# Redmine Subtask Field Copier

A lightweight plugin for **Redmine** that automatically copies fields from a parent issue into a newly created subtask, saving time and reducing manual data entry.

## Features

* Automatically copies all Custom Field values from the parent issue to the new subtask.
* **Seamless Integrations:** Out-of-the-box support for the `redmine_qbo` and `redmine_qbo_vehicles` plugins (automatically copies Customer, Estimate and Vehicle fields).

---

## Compatibility

| Plugin Version | Redmine Version |
| :--- | :--- |
| **2026.8.0+** | Redmine 5.x |

---

## Installation

### 1. Clone the Plugin

Install the plugin into your Redmine `plugins` directory.

```bash
cd /path/to/redmine/plugins  
git clone https://github.com/rickbarrette/subtask_field_copier.git  
cd subtask_field_copier  

# Optional but recommended: Checkout a specific tagged release for stability
git checkout <tag>
```

### 2. Restart Redmine

Because this plugin patches the core controller, no database migrations are required. Simply restart your Redmine application server (e.g., Puma, Passenger, or Unicorn) so the plugin and hooks are loaded.

---

## Usage

Once installed and the server is restarted, there is no configuration needed. Simply navigate to an existing issue, click the **Add Subtask** link, and the new subtask form will automatically be pre-populated with the parent issue's data.

---

### Developer API: Registering Custom Fields

If you have built your own Redmine plugins that add custom columns to the issues database table, you can register those fields to be automatically copied when a subtask is created.
In your custom plugin's init.rb, append your field names (as symbols) to the SubtaskFieldCopier.registered_fields array.
It is best practice to wrap this in a Rails.configuration.to_prepare block and check if the module is defined, ensuring your plugin won't crash if the Subtask Field Copier is uninstalled:

```Ruby
Rails.configuration.to_prepare do
  if defined?(SubtaskFieldCopier)
    # Register your custom issue fields here
    SubtaskFieldCopier.registered_fields << :vehicle
    SubtaskFieldCopier.registered_fields << :customer
    
    # Ensure there are no duplicates (useful for development hot-reloading)
    SubtaskFieldCopier.registered_fields.uniq!
  end
end
```

---

## License

> The MIT License (MIT)
>
> Copyright (c) 2026 Rick Barrette
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.