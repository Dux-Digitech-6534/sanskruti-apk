"""Idempotent ERPNext custom-field setup for the Sanskruti Flutter app.

Place this file inside an installed custom Frappe app (for example under a
patches or utilities module) and execute `ensure_custom_fields` with bench.
It uses Frappe's Custom Field API and avoids direct database updates.
"""

from __future__ import annotations


CUSTOM_FIELDS = {
    "Material Request": [
        {
            "fieldname": "custom_add_receipt",
            "label": "Add Receipt",
            "fieldtype": "Attach Image",
            "allow_on_submit": 1,
        },
        {
            "fieldname": "custom_category",
            "label": "Category",
            "fieldtype": "Data",
            "allow_on_submit": 1,
        },
        {
            "fieldname": "custom_remark",
            "label": "Remark",
            "fieldtype": "Small Text",
            "allow_on_submit": 1,
        },
    ],
    "Purchase Receipt": [
        {
            "fieldname": "custom_add_material",
            "label": "Material Receipt",
            "fieldtype": "Attach Image",
            "allow_on_submit": 1,
        },
        {
            "fieldname": "custom_add_invoice",
            "label": "Invoice Receipt",
            "fieldtype": "Attach Image",
            "allow_on_submit": 1,
        },
        {
            "fieldname": "custom_material_receipt_datetime",
            "label": "Material Receipt Datetime",
            "fieldtype": "Datetime",
            "read_only": 1,
            "allow_on_submit": 1,
        },
        {
            "fieldname": "custom_material_invoice_datetime",
            "label": "Invoice Receipt Datetime",
            "fieldtype": "Datetime",
            "read_only": 1,
            "allow_on_submit": 1,
        },
    ],
}


def ensure_custom_fields():
    import frappe
    from frappe.custom.doctype.custom_field.custom_field import (
        create_custom_fields,
    )

    create_custom_fields(CUSTOM_FIELDS, update=True)
    frappe.clear_cache(doctype="Material Request")
    frappe.clear_cache(doctype="Purchase Receipt")


def execute():
    ensure_custom_fields()
