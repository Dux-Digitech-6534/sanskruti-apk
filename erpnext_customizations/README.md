# ERPNext Customizations

This folder contains the idempotent custom-field setup needed by the Android app.
It creates/updates these ERPNext custom fields without direct database hacks:

- Material Request: `custom_add_receipt`, `custom_category`, `custom_remark`
- Purchase Receipt: `custom_add_material`, `custom_add_invoice`,
  `custom_material_receipt_datetime`, `custom_material_invoice_datetime`

Recommended bench flow:

```bash
bench --site <site-name> console
```

Then import or paste `sanskruti_custom_fields.py` into an installed custom app and run:

```python
from your_custom_app.path.sanskruti_custom_fields import ensure_custom_fields
ensure_custom_fields()
```

After applying:

```bash
bench --site <site-name> migrate
bench --site <site-name> clear-cache
```

The local Windows workspace used for this APK build does not include a Frappe bench checkout, so this helper is provided as the backend migration artifact.
