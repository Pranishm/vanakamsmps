const mongoose = require('mongoose');
require('dotenv').config();

async function run() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    const users = await mongoose.connection.collection('users').find({}).toArray();
    console.log("Users in DB:");
    users.forEach(u => console.log(`- Email: ${u.email}, Role: ${u.role}, MC: ${u.minecraftUsername}`));
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

run();
