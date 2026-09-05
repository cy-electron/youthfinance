from marshmallow import Schema, fields


class NotificationPreferenceSchema(Schema):
    emergency_fund_enabled = fields.Boolean(required=True)
