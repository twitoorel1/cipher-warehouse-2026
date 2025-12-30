import bcrypt from "bcrypt";

export async function verifyPassword(plainPassword: string, passwordHash: string): Promise<boolean> {
  return bcrypt.compare(plainPassword, passwordHash);
}

// Test password hash generation
export async function hashPassword(plainPassword: string): Promise<string> {
  const saltRounds = 10;
  return bcrypt.hash(plainPassword, saltRounds);
}
// node -e "import('bcrypt').then(b=>b.default.hash('Ot2521ot',12).then(console.log))"
