/**
 * The function formats a given uptime in seconds into days, hours, minutes, and seconds.
 * @param {number} uptimeInSeconds - The number of seconds representing the uptime of a system or
 * process.
 * @returns a formatted string representing the uptime in days, hours, minutes, and seconds.
 */
export default function formatUptime(uptimeInSeconds: number) {
  const days = Math.floor(uptimeInSeconds / 86400);
  const hours = Math.floor((uptimeInSeconds % 86400) / 3600);
  const minutes = Math.floor((uptimeInSeconds % 3600) / 60);
  const seconds = Math.floor(uptimeInSeconds % 60);

  return `${days} days, ${hours} hours, ${minutes} minutes, ${seconds} seconds`;
}

export const formatDate = (dateString: string) => {
  if (!dateString) return "";
  const date = new Date(dateString);
  return date.toLocaleString("he-IL", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });
};