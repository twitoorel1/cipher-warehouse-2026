export type InternalField =
"serial" |
"makat" |
"device_name" |
"current_unit_symbol" |
"device_type_code" |
"lifecycle_status" |
"storage_site_raw";


const aliasMap: Record<string, InternalField> = {
  "אתר אחסון": "storage_site_raw",

  "תיאור החומר": "device_name",
  "שם המכשיר": "device_name",
  device_name: "device_name",

  חומר: "makat",
  'מק"ט': "makat",
  "מק'ט": "makat",
  "מק׳ט": "makat",
  מקט: "makat",
  makat: "makat",

  "מספר סיריאלי": "serial",
  "מספר סריאלי": "serial",
  serial: "serial",
};
