export type CoreDeviceRow = {
  id: number;
  serial: string;
  makat: string;
  device_name: string;
  current_unit_symbol: string;
  device_type_id: DeviceTypeRow;
  encryption_profile_id: EncryptionProfileRow;
  lifecycle_status: string;
  created_at: string;
  updated_at: string;
};

export type DeviceTypeRow = {
  id: number;
  code: string;
  display_name: string;
};

export type EncryptionProfileRow = {
  id: number;
  profile_name: string;
};
