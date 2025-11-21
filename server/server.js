const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Store active users and their socket IDs
const activeUsers = new Map();

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // User joins a chat room
  socket.on('join_chat', (data) => {
    const { chatId, userId, userName } = data;
    socket.join(chatId);
    activeUsers.set(socket.id, { userId, userName, chatId });
    console.log(`${userName} joined chat: ${chatId}`);

    // Notify others in the room
    socket.to(chatId).emit('user_joined', {
      userId,
      userName,
      timestamp: new Date().toISOString()
    });
  });

  // Handle new messages
  socket.on('send_message', (data) => {
    const { chatId, message } = data;
    console.log(`Message in ${chatId}:`, message);

    // Broadcast message to all users in the chat room
    io.to(chatId).emit('receive_message', message);
  });

  // User starts typing
  socket.on('typing', (data) => {
    const { chatId, userName } = data;
    socket.to(chatId).emit('user_typing', { userName });
  });

  // User stops typing
  socket.on('stop_typing', (data) => {
    const { chatId } = data;
    socket.to(chatId).emit('user_stop_typing');
  });

  // Handle disconnection
  socket.on('disconnect', () => {
    const user = activeUsers.get(socket.id);
    if (user) {
      console.log(`${user.userName} disconnected`);
      socket.to(user.chatId).emit('user_left', {
        userId: user.userId,
        userName: user.userName,
        timestamp: new Date().toISOString()
      });
      activeUsers.delete(socket.id);
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Socket.IO server running on port ${PORT}`);
});
