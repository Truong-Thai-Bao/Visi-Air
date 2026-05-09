require('dotenv').config();
const express = require('express');
const cors = require('cors');

// Import Route vừa tạo
const chatRoutes = require('./src/routes/routes'); 

const app = express();
const port = process.env.PORT || 3005;

app.use(cors());
app.use(express.json()); //Đọc json body

app.use('/api', chatRoutes); 

app.get('/', (req, res) => {
  res.send('Server VisiAir đang chạy!');
});

app.listen(port, () => {
  console.log(`Server đang chạy tại http://localhost:${port}`);
});