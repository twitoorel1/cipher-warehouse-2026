export enum Permissions {
  // =========================
  // Devices
  // =========================
  DEVICES_READ = "devices.read",
  DEVICES_CREATE = "devices.create",
  DEVICES_UPDATE = "devices.update",
  DEVICES_DELETE = "devices.delete",
  DEVICES_IMPORT = "devices.import",
  DEVICES_EXPORT = "devices.export",

  // =========================
  // Inventory / Counts
  // =========================
  INVENTORY_READ = "inventory.read",
  INVENTORY_COUNT_UPDATE = "inventory.count.update",
  INVENTORY_COUNT_APPROVE = "inventory.count.approve",
  INVENTORY_ADJUST = "inventory.adjust",

  // =========================
  // Users / Roles / Permissions
  // =========================
  USERS_READ = "users.read",
  USERS_CREATE = "users.create",
  USERS_UPDATE = "users.update",
  USERS_DEACTIVATE = "users.deactivate",
  ROLES_ASSIGN = "roles.assign",
  PERMISSIONS_OVERRIDE_MANAGE = "permissions.override.manage",

  // =========================
  // Reference Data
  // =========================
  UNITS_READ = "units.read",
  UNITS_UPDATE = "units.update",
  BATTALIONS_READ = "battalions.read",
  DIVISIONS_READ = "divisions.read",

  // =========================
  // Audit
  // =========================
  AUDIT_READ = "audit.read",

  // =========================
  // Tel100 Profiles
  // =========================
  TEL100_VOICE_PROFILE_READ = "tel100.voice.profile.read",
  TEL100_VOICE_PROFILE_UPDATE = "tel100.voice.profile.update",
  TEL100_VOICE_PROFILE_READ_SENSITIVE = "tel100.voice.profile.read_sensitive",

  TEL100_MODEM_PROFILE_READ = "tel100.modem.profile.read",
  TEL100_MODEM_PROFILE_UPDATE = "tel100.modem.profile.update",
  TEL100_MODEM_PROFILE_READ_SENSITIVE = "tel100.modem.profile.read_sensitive",
}
