const mongoose = require('mongoose');
require('dotenv').config();
async function run() {
  await mongoose.connect(process.env.MONGODB_URI);
  const users = await mongoose.connection.collection('users').find({}).toArray();
  console.log(users.map(u => ({ email: u.email, role: u.role, mc: u.minecraftUsername })));
  process.exit(0);
}
run();
