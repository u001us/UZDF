const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log("Checking for failed migrations in _prisma_migrations...");
  if (!process.env.DATABASE_URL) {
    console.log("No DATABASE_URL found, skipping migration repair.");
    return;
  }

  try {
    // Check if _prisma_migrations table exists
    const tableCheck = await prisma.$queryRawUnsafe(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = '_prisma_migrations'
      );
    `);
    
    if (tableCheck[0] && tableCheck[0].exists) {
      console.log("Deleting failed migration row...");
      const deletedCount = await prisma.$executeRawUnsafe(`
        DELETE FROM "_prisma_migrations" 
        WHERE "migration_name" = '20260610000000_add_course_features' 
        AND "finished_at" IS NULL;
      `);
      console.log(`Deleted ${deletedCount} failed migration row(s).`);
    } else {
      console.log("_prisma_migrations table does not exist yet.");
    }
  } catch (err) {
    console.error("Failed to repair migration:", err.message);
  } finally {
    await prisma.$disconnect();
  }
}

main();
